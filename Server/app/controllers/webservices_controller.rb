# Controller class for Web services
class WebservicesController < ApplicationController
  require 'httparty'
  require 'config/config_loader'
  # API to get CPU usage for specific server
  def cpu_usage
    %w(agent_ip user password).each do |input|
      if params[input].blank?
        @error = "#{ input } parameter is blank"
      end
    end
    if @error.nil?
      @error = "Wrong username or password" unless authenticate(params['user'], params['password'])
    end
    if @error
      render json: { error: @error }
    elsif params['value']
      Cpu.create(cpu_usage: params['value'].to_f,server_ip: params['agent_ip'])
      limit = ConfigLoader.new.config_for("agent")["MAX_CPU_USAGE"]
      if !limit.nil? and limit.to_i < params['value'].to_i
        render plain: 'Cpu usage already reached the limit', status: 500
      else
        render plain: 'success', status: 200
      end
    else
      agent_port = ConfigLoader.new.config_for("agent")["PORT"].to_s
      response = HTTParty.get("http://#{params['agent_ip']}:#{agent_port}/cpu_usage")
      render json: { cpu_usage: response.gsub(/\n/,'') }
    end
  end
  # API to get Disk usage for specific server
  def disk_usage
    %w(agent_ip user password).each do |input|
      if params[input].blank?
        @error = "#{ input } parameter is blank"
      end    
    end
    if @error.nil?
      @error = "Wrong username or password" unless authenticate(params['user'], params['password'])
    end
    if @error
      render json: { error: @error }
    elsif params['value']
      Disk.create(disk_usage: params['value'].to_f,server_ip: params['agent_ip'])
      limit = ConfigLoader.new.config_for("agent")["MAX_DISK_USAGE"]
      if !limit.nil? and limit.to_i < params['value'].to_i
        render plain: 'Disk usage already reached the limit', status: 500
      else
        render plain: 'success', status: 200
      end
    else
      agent_port = ConfigLoader.new.config_for("agent")["PORT"].to_s
      response = HTTParty.get("http://#{params['agent_ip']}:#{agent_port}/disk_usage")
      render json: { disk_usage: response.gsub(/\n/,'') }
    end
  end
  # API to get total process for specific server
  def running_process
    %w(agent_ip user password).each do |input|
      if params[input].blank?
        @error = "#{ input } parameter is blank"
      end    
    end
    if @error.nil?
      @error = "Wrong username or password" unless authenticate(params['user'], params['password'])
    end
    if @error
      render json: { error: @error }
    elsif params['value']
      RunningProcess.create(total_process: params['value'].to_i,server_ip: params['agent_ip'])
      limit = ConfigLoader.new.config_for("agent")["MAX_RUNNING_PROCESS"]
      if !limit.nil? and limit.to_i < params['value'].to_i
        render plain: 'Total running processes already reached the limit', status: 500
      else
        render plain: 'success', status: 200
      end
    else
      agent_port = ConfigLoader.new.config_for("agent")["PORT"].to_s
      response = HTTParty.get("http://#{params['agent_ip']}:#{agent_port}/running_process")
      render json: { running_process: response.gsub(/\n/,'') }
    end
  end

end