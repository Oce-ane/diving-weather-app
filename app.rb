require 'sinatra'
require 'httparty'
require 'json'
require 'sinatra/activerecord'
require 'pg_search'
require './models/country'
require './models/dive_site'

set :database_file, File.expand_path('config/database.yml', __dir__)


get '/' do
  erb :home
end

get '/search' do
  query = params[:query]

  @results = Country.search_by_name(query) + DiveSite.search_by_name(query)

  response_data = {}

  if @results.any?
    lat = @results.first.latitude
    lon = @results.first.longitude

    # Fetch weather data from Storm Glass
    stormglass_url = "https://api.stormglass.io/v2/weather/point?lat=#{lat}&lng=#{lon}&params=waveHeight,windSpeed,waterTemperature,wavePeriod,precipitation"
    stormglass_response = HTTParty.get(stormglass_url, headers: { 'Authorization' => STORM_GLASS_API_KEY })

    # Check for rate-limiting (HTTP status code 403)
    if stormglass_response.code == 403
      response_data[:error] = 'Storm Glass API request limit reached. Please try again tomorrow.'
    elsif stormglass_response.code == 200
      weather_data = JSON.parse(stormglass_response.body)
      wave_height = weather_data['hours'][0]['waveHeight']['sg']
      wind_speed = weather_data['hours'][0]['windSpeed']['sg']
      water_temp = weather_data['hours'][0]['waterTemperature']['sg']
      wave_period = weather_data['hours'][0]['wavePeriod']['sg']
      precipitation = weather_data['hours'][0]['precipitation']['sg']

      # Evaluate diving conditions
      conditions = evaluate_diving_conditions(wave_height, wind_speed, water_temp, wave_period, precipitation)
      response_data[:results] = @results.map { |r| { name: r.name } }
      response_data[:conditions] = "Wave Height: #{wave_height}m, Wind Speed: #{wind_speed} m/s, Water Temp: #{water_temp}°C, Wave Period: #{wave_period}s, Precipitation: #{precipitation}mm. #{conditions}"
    else
      response_data[:error] = 'Error fetching weather data from Storm Glass. Please try again later.'
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

def evaluate_diving_conditions(wave_height, wave_period)
  if wave_height < 1 && wave_period < 9
    'These are dream diving conditions'
  elsif wave_height > 2.5 || wave_period > 17
    'Meh, could be better'
  elsif wave_height > 1.5 || wave_period > 13
    'Do you have better to do?'
  else
    'Not worth getting out of bed'
  end
end
