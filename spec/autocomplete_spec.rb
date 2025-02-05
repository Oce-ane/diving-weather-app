require 'capybara/rspec'
require 'selenium/webdriver'
require 'rack/test'
require 'sinatra/activerecord'
require_relative '../app'

ENV['RACK_ENV'] = 'test'
set :environment, :test

ActiveRecord::Base.logger.level = Logger::WARN # Show only warnings and errors

Capybara.default_driver = :selenium_headless

Capybara.app = Sinatra::Application

RSpec.describe 'Diving Weather App', type: :feature do
  include Rack::Test::Methods
  include Capybara::DSL

  def app
    Sinatra::Application
  end

  scenario 'Autocomplete shows suggestions when typing' do
    visit '/'
    fill_in 'dive-site-search', with: 'can'

    expect(page).to have_css('#suggestions .suggestion', wait: 2)
    suggestions = page.all('#suggestions .suggestion')
    expect(suggestions).not_to be_empty
  end
end
