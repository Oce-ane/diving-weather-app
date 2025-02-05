require 'rspec'
require 'rack/test'
require 'sinatra/activerecord'
require_relative '../app'

ENV['RACK_ENV'] = 'test'
set :environment, :test

ActiveRecord::Base.logger.level = Logger::WARN # Show only warnings and errors

RSpec.describe 'Diving Weather App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  describe 'Diving Weather App' do
    it 'loads successfully' do
      get '/'
      expect(last_response).to be_ok
      expect(last_response.body).to include('Diving Weather App')
    end
  end

  describe 'Search' do
    it 'returns results for a valid dive site search' do
      get '/search', query: 'Thomas Reef Canyon'
      expect(last_response).to be_ok

      json = JSON.parse(last_response.body)
      expect(json).to have_key('results')
      expect(json['results'].first).to have_key('name')
      expect(json['results'].first['name']).to eq('Thomas Reef Canyon')
    end
  end

  describe 'Diving Conditions Evaluation' do
    it 'returns a rating based on marine data conditions' do
      result = evaluate_diving_conditions(1.2, 10, 26, 0.8, 5)
      expect(result).to eq('Do you have better to do?')
    end
  end
end
