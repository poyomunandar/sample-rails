# encoding: utf-8

require 'yaml'

class ConfigLoader
  
  CONFIG_FILE_PATH = 'config/config.yml'
  
  def initialize
    load_config_data
  end

  def [](name)
    config_for(name)
  end

  def config_for(name)
    @config_data[name]
  end
  
  def update
    File.open(CONFIG_FILE_PATH, 'wb') { |f| YAML.dump(@config_data, f) }
  end

  private

  def load_config_data    
    begin
      config_file_contents = File.read(CONFIG_FILE_PATH)
    rescue Errno::ENOENT
      $stderr.puts "missing config file"
      raise
    end
    @config_data = YAML.load(config_file_contents)
  end
end