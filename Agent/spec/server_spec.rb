require "spec_helper"
require 'agent/server'

describe 'Server' do
  let (:file) {double(:file)}
  let (:config) {double(:config)}
  let (:config_array) {double(:config_array)}
  it "should read configuration file" do
    message = 'hello'
    expect(ConfigLoader).to receive(:new).and_return(config)
    expect(config).to receive(:config_for).with("agent").and_return(config_array)
    expect(config_array).to receive(:[]).with("ALERT_FILENAME")
    File.stub(:open)
    server = Agent::Server.new
    server.alert(message)
  end
  
  it "should open log file with permission a+b" do
    message = 'hello'
    log_filename = ConfigLoader.new.config_for("agent")["ALERT_FILENAME"].to_s
    expect(File).to receive(:open).with(log_filename,'a+b')
    server = Agent::Server.new
    server.alert(message)
  end

end
