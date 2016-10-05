class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  require 'config/config_loader'
  def authenticate(username, password)
    if username == ConfigLoader.new.config_for("server")["API_USERNAME"] && 
        password == ConfigLoader.new.config_for("server")["API_PASSWORD"]
      return true
    else
      return false
    end
  end
end
