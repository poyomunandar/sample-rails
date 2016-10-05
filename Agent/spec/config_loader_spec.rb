require "spec_helper"

describe 'ConfigLoader' do
  let (:file_content) {double(:file_content)}
  it "should load the file at class initialization" do
    expect(File).to receive(:read).with(ConfigLoader::CONFIG_FILE_PATH).and_return(file_content)
    expect(YAML).to receive(:load).with(file_content)
    config_loader = ConfigLoader.new
  end
  
  it "should return array config of the agent" do
    config_loader = ConfigLoader.new
    agent = config_loader.config_for("agent")
    expect(agent['PORT']).to be_kind_of(Fixnum)
  end

end
