require 'spec_helper'

describe 'Dive Weather App' do
  it 'loads the homepage' do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to include("Welcome")
  end

  it 'returns search results' do
    get '/search?query=Maldives'
    expect(last_response).to be_ok
    expect(last_response.body).to include("Maldives")
  end
end
