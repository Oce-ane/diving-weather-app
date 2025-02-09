require 'sinatra'
require 'dotenv/load'
require 'httparty'
require 'json'
require 'sinatra/activerecord'
require 'pg_search'
require './models/country'
require './models/dive_site'

Dotenv.load

set :database_file, File.expand_path('config/database.yml', __dir__)

api_key = ENV['STORM_GLASS_API_KEY']

get '/' do
  erb :home
end

get '/search' do
  query = params[:query]

  # Keeps only the dive site name to match db structure
  site_name = query.split('(').first.strip
  puts "Search term for dive site: #{site_name}"

  @results = DiveSite.search_by_name(site_name)
  response_data = {}

  if @results.any?
    lat = @results.first.latitude
    lon = @results.first.longitude
    puts "Coordinates for dive site: Latitude = #{lat}, Longitude = #{lon}"

    # Fetch the marine weather data with the Storm Glass API using the dive site coordinates
    stormglass_url = "https://api.stormglass.io/v2/weather/point?lat=#{lat}&lng=#{lon}&params=waveHeight,waterTemperature,precipitation,currentSpeed,swellPeriod"

    begin
      stormglass_response = HTTParty.get(stormglass_url, headers: { 'Authorization' => api_key })
      puts "Storm Glass API response status: #{stormglass_response.code}"

      case stormglass_response.code
      when 400
        response_data[:error] = 'Bad request. Please check your query parameters and try again.'
      when 401
        response_data[:error] = 'Unauthorized. Your API key is invalid. Please check your API key and try again.'
      when 402
        response_data[:error] = 'Payment required. Your account is over its limit or needs to be upgraded.'
      when 429
        response_data[:error] = 'Too many requests. You’ve reached your daily limit. Please try again tomorrow.'
      when 500
        response_data[:error] = 'Internal Server Error. There was an issue with Storm Glass. Please try again later.'
      when 503
        response_data[:error] = 'Service Unavailable. Storm Glass is temporarily offline for maintenance. Please try again later.'
      when 200
        weather_data = JSON.parse(stormglass_response.body)
        puts "Weather data successfully retrieved from Storm Glass."

        wave_height = weather_data['hours'][0]['waveHeight']['sg']
        water_temp = weather_data['hours'][0]['waterTemperature']['sg']
        wave_period = weather_data['hours'][0]['swellPeriod']['sg']
        current_speed = weather_data['hours'][0]['currentSpeed']['sg']
        precipitation = weather_data['hours'][0]['precipitation']['sg']

        puts "Weather data extracted: Wave Height = #{wave_height}, Water Temp = #{water_temp}, Wave Period = #{wave_period}, Current Speed = #{current_speed}, Precipitation = #{precipitation}"

        conditions = evaluate_diving_conditions(wave_height, wave_period, water_temp, current_speed, precipitation)

        response_data[:results] = @results.map { |r| { name: r.name } }
        response_data[:conditions] = {
          wave_height: wave_height,
          wave_period: wave_period,
          water_temp: water_temp,
          current_speed: current_speed,
          precipitation: precipitation,
          rating: conditions
        }
      else
        response_data[:error] = 'An unexpected error occurred. Please try again later.'
      end
    rescue HTTParty::Error => e
      # Catch HTTP errors related to the Storm Glass API request
      puts "HTTP error occurred: #{e.message}"
      response_data[:error] = 'There was an issue connecting to the Storm Glass API. Please try again later.'
    rescue StandardError => e
      # Catch any other unexpected errors and log details
      puts "Unexpected error: #{e.message}"
      puts e.backtrace.join("\n")
      response_data[:error] = 'An unexpected error occurred. Please try again later.'
    end
  else
    response_data[:error] = 'No results found. Please refine your search.'
  end

  content_type :json
  response_data.to_json
end

get '/autocomplete' do
  query = params[:query]
  @dive_sites = DiveSite.where('name ILIKE ?', "%#{query}%").limit(10)
  @dive_sites = @dive_sites.includes(:country).map do |site|
    {
      name: site.name,
      country_name: site.country.name
    }
  end
  content_type :json
  @dive_sites.to_json
end

def evaluate_diving_conditions(wave_height, wave_period, water_temp, current_speed, precipitation)
  # Rules to evaluate diving conditions accrding to my own preferences
  # Needs to be adjusted to match professional divers expectations
  if wave_height < 1 && wave_period < 9 && water_temp > 27 && precipitation == 0 && current_speed < 0.5
    'These are dream diving conditions'
  elsif wave_height < 1.5 && wave_period < 13
    'Do you have better to do?'
  elsif wave_height < 2.2 && wave_period < 15 && current_speed > 2
    'Meh, could be better'
  elsif wave_height > 2.9 && wave_period > 18 && water_temp < 20 && precipitation > 20
    'Not worth getting out of bed'
  else
    'Who even knows anything anymore about climate & weather'
  end
end
