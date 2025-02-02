require 'sinatra'
require 'httparty'
require 'json'

STORM_GLASS_API_KEY = '***REMOVED***-41e69b32-dd77-11ef-9159-0242ac130003'
OPEN_WEATHER_API_KEY = '***REMOVED***'
OPEN_CAGE_API_KEY = '***REMOVED***'

get '/' do
  erb :home
end

# get '/weather/:location' do
#   location = params[:location]
#   api_url = "https://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{OPEN_WEATHER_API_KEY}&units=metric"

#   response = HTTParty.get(api_url)
#   if response.code == 200
#     weather_data = JSON.parse(response.body)
#     temp = weather_data['main']['temp']
#     wind_speed = weather_data['wind']['speed']
#     "Location: #{location.capitalize}, Temp: #{temp}°C, Wind Speed: #{wind_speed} m/s"
#   else
#     "Error fetching weather data for #{location}. Please try again."
#   end
# end

get '/autocomplete' do
  query = params[:query]
  return "Query is required" if query.nil? || query.strip.empty?

  # OpenCage API URL for geocoding
  api_url = "https://api.opencagedata.com/geocode/v1/json?q=#{query}&key=#{OPEN_CAGE_API_KEY}&limit=5"

  # Fetch suggestions
  response = HTTParty.get(api_url)
  if response.code == 200
    data = JSON.parse(response.body)
    # Extract relevant location names
    suggestions = data['results'].map { |result| result['formatted'] }
    content_type :json
    { suggestions: suggestions }.to_json
  else
    status 500
    "Error fetching autocomplete suggestions"
  end
end

get '/weather' do
  location = params[:location]

  # Step 1: Geocode location to lat/lon
  geocode_url = "https://api.opencagedata.com/geocode/v1/json?q=#{location}&key=#{OPEN_CAGE_API_KEY}"
  geocode_response = HTTParty.get(geocode_url)

  if geocode_response.code == 200
    geocode_data = JSON.parse(geocode_response.body)
    if geocode_data['results'].any?
      lat = geocode_data['results'][0]['geometry']['lat']
      lon = geocode_data['results'][0]['geometry']['lng']

      # Step 2: Fetch weather data from Storm Glass
      stormglass_url = "https://api.stormglass.io/v2/weather/point?lat=#{lat}&lng=#{lon}&params=waveHeight,windSpeed,waterTemperature"
      stormglass_response = HTTParty.get(stormglass_url, headers: { 'Authorization' => STORM_GLASS_API_KEY })

      if stormglass_response.code == 200
        weather_data = JSON.parse(stormglass_response.body)

        wave_height = weather_data['hours'][0]['waveHeight']['sg']
        wind_speed = weather_data['hours'][0]['windSpeed']['sg']
        water_temp = weather_data['hours'][0]['waterTemperature']['sg']

        # Evaluate diving conditions
        conditions = evaluate_diving_conditions(wave_height, wind_speed, water_temp)
        "Location: #{location.capitalize},
        Wave Height: #{wave_height}m,
        Wind Speed: #{wind_speed} m/s,
        Water Temp: #{water_temp}°C. #{conditions}"
      else
        "Error fetching weather data from Storm Glass. Please try again."
      end
    else
      "Unable to find location. Please check the input and try again."
    end
  else
    "Error fetching geolocation data. Please try again."
  end
end

def evaluate_diving_conditions(wave_height, wind_speed, water_temp)
  if wave_height < 1 && wind_speed < 5 && water_temp > 20
    "Great conditions for diving! 🌊"
  elsif wave_height < 2 && wind_speed < 10
    "Okay conditions for diving. Proceed with caution."
  else
    "Poor conditions for diving. Consider rescheduling."
  end
end
