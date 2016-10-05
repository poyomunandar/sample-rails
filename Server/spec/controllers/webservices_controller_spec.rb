require 'spec_helper'

describe 'cpu_usage' , type: :request do
  it 'should deny call without credentials' do
    get '/webservices/cpu_usage'
    expect(response.body).to match(/(user|password) parameter is blank/)
  end
end

describe 'disk_usage' , type: :request do
  it 'should deny call without credentials' do
    get '/webservices/cpu_usage'
    expect(response.body).to match(/(user|password) parameter is blank/)
  end
end

describe 'running_process' , type: :request do
  it 'should deny call without credentials' do
    get '/webservices/cpu_usage'
    expect(response.body).to match(/(user|password) parameter is blank/)
  end
end
