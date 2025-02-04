require 'rspec'
require 'rack/test'
require_relative '../app'

ENV['RACK_ENV'] = 'test'

RSpec.describe 'Diving Weather App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  context 'Homepage' do
    it 'loads successfully' do
      get '/'
      expect(last_response).to be_ok
      expect(last_response.body).to include('Diving Weather') # Adjust to match your homepage content
    end
  end

  context 'Autocomplete' do
    it 'returns suggestions for a given query' do
      # Simulate a mock result to avoid querying the actual database
      allow(DiveSite).to receive(:where).and_return([double(name: 'Bassins', country_name: 'Reunion Island')])

      get '/autocomplete', query: 'bassins'
      expect(last_response).to be_ok

      json = JSON.parse(last_response.body)
      expect(json).to be_an(Array)
      expect(json.first).to have_key('name')
      expect(json.first).to have_key('country_name')
      expect(json.first['name']).to eq('Bassins')
      expect(json.first['country_name']).to eq('Reunion Island')
    end
  end

  context 'Search' do
    it 'returns results for a valid dive site search' do
      # Simulate a search result, no need for real database query
      allow(DiveSite).to receive(:search_by_name).and_return([double(name: 'Thomas Reef Canyon', latitude: 0, longitude: 0)])

      get '/search', query: 'Thomas Reef Canyon'
      expect(last_response).to be_ok

      json = JSON.parse(last_response.body)
      expect(json).to have_key('results')
      expect(json['results'].first).to have_key('name')
      expect(json['results'].first['name']).to eq('Thomas Reef Canyon')
    end
  end

  context 'Diving Conditions Evaluation' do
    it 'returns a rating based on marine data conditions' do
      result = evaluate_diving_conditions(1.2, 10, 26, 0.8, 5)
      expect(result).to eq('Do you have better to do?')
    end
  end
end
