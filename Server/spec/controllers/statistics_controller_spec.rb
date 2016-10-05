require 'spec_helper'

describe 'cpu_usage' , type: :request do
  it 'should display cpu usage page' do
    get '/cpu_usage'
    expect(response.body).to match("<center><h1>CPU Usage</h1></center>")
  end
end

describe 'disk_usage' , type: :request do
  it 'should display disk usage page' do
    get '/disk_usage'
    expect(response.body).to match("<center><h1>Disk Usage</h1></center>")
  end
end

describe 'running_process' , type: :request do
  it 'should display total running process page' do
    get '/running_process'
    expect(response.body).to match("<center><h1>Running Process</h1></center>")
  end
end