require 'will_paginate'
require 'prawn'
require 'prawn/table'
require 'will_paginate/array'
require 'config/config_loader'
# Controller class for statistics
class StatisticsController < ApplicationController
  
  PAGINATE_PER_PAGE = ConfigLoader.new.config_for("server")["PAGINATE_PER_PAGE"]

  # get all records from cpu table from given date range
  def cpu_usage

    @pfilter = params[:filter]
    if params[:commit] == 'Find Max Usage'
      @cpustemp = Cpu.select("max(cpu.cpu_usage) as cpu_usage, cpu.server_ip").group("cpu.server_ip")
    elsif params[:commit] == 'Find Min Usage'
      @cpustemp = Cpu.select("min(cpu.cpu_usage) as cpu_usage, cpu.server_ip").group("cpu.server_ip")
    else
      @cpus =  Cpu.select("cpu.server_ip, cpu.cpu_usage, cpu.created_at")
    end

    if @pfilter
      # show cpu usage that are started within a date range
      @pfilter[:start_time] = Time.zone.local(@pfilter['start_date(1i)'].to_i,
                                              @pfilter['start_date(2i)'].to_i,
                                              @pfilter['start_date(3i)'].to_i,
                                              @pfilter['start_date(4i)'].to_i,
                                              @pfilter['start_date(5i)'].to_i, 0)
      @pfilter[:end_time] = Time.zone.local(@pfilter['end_date(1i)'].to_i,
                                            @pfilter['end_date(2i)'].to_i,
                                            @pfilter['end_date(3i)'].to_i,
                                            @pfilter['end_date(4i)'].to_i,
                                            @pfilter['end_date(5i)'].to_i, 0)
      if @cpus.nil?
         @cpustemp = @cpustemp.where("cpu.created_at >= ? and  cpu.created_at <= ?",@pfilter[:start_time], @pfilter[:end_time])
      else
        @cpus = @cpus.where("cpu.created_at >= ? and  cpu.created_at <= ?",@pfilter[:start_time], @pfilter[:end_time])
      end
    else
      @pfilter = {}
    end
    @cpustemp.each_with_index do |cpu, index|
      if !cpu.nil? && (params[:commit] == 'Find Max Usage' || params[:commit] == 'Find Min Usage')
        if index == 0
          @cpus = Cpu.select("cpu.cpu_usage, cpu.server_ip, cpu.created_at").where("server_ip = ? AND CAST(cpu_usage as CHAR(50)) = ?", cpu.server_ip, cpu.cpu_usage.to_s).where("cpu.created_at >= ? and  cpu.created_at <= ?",@pfilter[:start_time], @pfilter[:end_time])
        else
          @cpus = @cpus.or(Cpu.select("cpu.cpu_usage, cpu.server_ip, cpu.created_at").where("server_ip = ? AND CAST(cpu_usage as CHAR(50)) = ?", cpu.server_ip, cpu.cpu_usage.to_s).where("cpu.created_at >= ? and  cpu.created_at <= ?",@pfilter[:start_time], @pfilter[:end_time]))
        end
      end
    end unless @cpustemp.nil?
    
    @cpus = @cpustemp if @cpus.nil? 
    @cpus = @cpus.order("cpu.server_ip, cpu.created_at")   
    @cpus = @cpus.paginate(page: params[:page], per_page: PAGINATE_PER_PAGE)

    respond_to do |format|
      format.html
      if params[:commit] == 'Export As PDF'
        send_data(pdf_cpu_usage(params[:data_to_print]), 
          filename: "cpu_usage.pdf",
          type: 'application/pdf',
          disposition: 'inline')
      end
    end

  end
  
  # get all records from disk table from given date range
  def disk_usage

    @pfilter = params[:filter]
    if params[:commit] == 'Find Max Usage'
      @diskstemp = Disk.select("max(disk.disk_usage) as disk_usage, disk.server_ip").group("disk.server_ip")
    elsif params[:commit] == 'Find Min Usage'
      @diskstemp = Disk.select("min(disk.disk_usage) as disk_usage, disk.server_ip").group("disk.server_ip")
    else
      @disks =  Disk.select("disk.server_ip, disk.disk_usage, disk.created_at")
    end

    if @pfilter
      # show disk usage that are started within a date range
      @pfilter[:start_time] = Time.zone.local(@pfilter['start_date(1i)'].to_i,
                                              @pfilter['start_date(2i)'].to_i,
                                              @pfilter['start_date(3i)'].to_i,
                                              @pfilter['start_date(4i)'].to_i,
                                              @pfilter['start_date(5i)'].to_i, 0)
      @pfilter[:end_time] = Time.zone.local(@pfilter['end_date(1i)'].to_i,
                                            @pfilter['end_date(2i)'].to_i,
                                            @pfilter['end_date(3i)'].to_i,
                                            @pfilter['end_date(4i)'].to_i,
                                            @pfilter['end_date(5i)'].to_i, 0)
                                          
      if @disks.nil?
        @diskstemp = @diskstemp.where("disk.created_at >= ? and  disk.created_at <= ?",@pfilter[:start_time], @pfilter[:end_time])
      else
        @disks = @disks.where("disk.created_at >= ? and  disk.created_at <= ?",@pfilter[:start_time], @pfilter[:end_time])
      end                                          
    else
      @pfilter = {}
    end        
    @diskstemp.each_with_index do |disk, index|
      if !disk.nil? && (params[:commit] == 'Find Max Usage' || params[:commit] == 'Find Min Usage')
        if index == 0
          @disks = Disk.select("disk.disk_usage, disk.server_ip, disk.created_at").where("server_ip=? AND CAST(disk_usage as CHAR(50)) = ?",disk.server_ip, disk.disk_usage.to_s).where("disk.created_at >= ? and  disk.created_at <= ?",@pfilter[:start_time], @pfilter[:end_time])
        else
          @disks = @disks.or(Disk.select("disk.disk_usage, disk.server_ip, disk.created_at").where("server_ip=? AND CAST(disk_usage as CHAR(50)) = ?",disk.server_ip, disk.disk_usage.to_s).where("disk.created_at >= ? and  disk.created_at <= ?",@pfilter[:start_time], @pfilter[:end_time]))
        end
      end
    end unless @diskstemp.nil?
    
    @disks = @diskstemp if @disks.nil?
    @disks = @disks.order("disk.server_ip, disk.created_at")
    @disks = @disks.paginate(page: params[:page], per_page: PAGINATE_PER_PAGE)

    respond_to do |format|
      format.html
      if params[:commit] == 'Export As PDF'
        send_data(pdf_disk_usage(params[:data_to_print]), 
          filename: "disk_usage.pdf",
          type: 'application/pdf',
          disposition: 'inline')
      end
    end

  end
  
  # get all records from disk table from given date range
  def running_process

    @pfilter = params[:filter]
    
    if params[:commit] == 'Find Max Running Process'
      @processestemp = RunningProcess.select("max(process.total_process) as total_process, process.server_ip").group("process.server_ip")
    elsif params[:commit] == 'Find Min Running Process'
      @processestemp = RunningProcess.select("min(process.total_process) as total_process, process.server_ip").group("process.server_ip")
    else
      @processes =  RunningProcess.select("process.server_ip, process.total_process, process.created_at")
    end
    if @pfilter
      # show running process that are started within a date range
      @pfilter[:start_time] = Time.zone.local(@pfilter['start_date(1i)'].to_i,
                                              @pfilter['start_date(2i)'].to_i,
                                              @pfilter['start_date(3i)'].to_i,
                                              @pfilter['start_date(4i)'].to_i,
                                              @pfilter['start_date(5i)'].to_i, 0)
      @pfilter[:end_time] = Time.zone.local(@pfilter['end_date(1i)'].to_i,
                                            @pfilter['end_date(2i)'].to_i,
                                            @pfilter['end_date(3i)'].to_i,
                                            @pfilter['end_date(4i)'].to_i,
                                            @pfilter['end_date(5i)'].to_i, 0)
      if @processes.nil?
        @processestemp = @processestemp.where("process.created_at >= ? and  process.created_at <= ?",@pfilter[:start_time], @pfilter[:end_time])
      else
        @processes = @processes.where("process.created_at >= ? and  process.created_at <= ?",@pfilter[:start_time], @pfilter[:end_time])
      end
      
    else
      @pfilter = {}
    end
    
    @processestemp.each_with_index do |process, index|
      if !process.nil? && (params[:commit] == 'Find Max Running Process' || params[:commit] == 'Find Min Running Process')
        if index == 0
          @processes = RunningProcess.select("process.total_process, process.server_ip, process.created_at").where(server_ip: process.server_ip, total_process: process.total_process.to_i).where("process.created_at >= ? and  process.created_at <= ?",@pfilter[:start_time], @pfilter[:end_time])
        else
          @processes = @processes.or(RunningProcess.select("process.total_process, process.server_ip, process.created_at").where(server_ip: process.server_ip, total_process: process.total_process.to_i).where("process.created_at >= ? and  process.created_at <= ?",@pfilter[:start_time], @pfilter[:end_time]))
        end
      end
    end unless @processestemp.nil?
    
    @processes = @processestemp if @processes.nil?
    @processes = @processes.order("process.server_ip, process.created_at")
    @processes = @processes.paginate(page: params[:page], per_page: PAGINATE_PER_PAGE)

    respond_to do |format|
      format.html
      if params[:commit] == 'Export As PDF'
        send_data(pdf_running_process(params[:data_to_print]), 
          filename: "running_process.pdf",
          type: 'application/pdf',
          disposition: 'inline')
      end
    end

  end

  def pdf_cpu_usage data
    two_dimensional_array = []
    data.split(';').each {|level1| two_dimensional_array << level1.split(',')}
    pdf = Prawn::Document.new
    pdf.text('CPU Usage')
    pdf.table(two_dimensional_array, :width => 500, :cell_style => { :inline_format => true })
    pdf.render
  end
  
  def pdf_disk_usage data
    two_dimensional_array = []
    data.split(';').each {|level1| two_dimensional_array << level1.split(',')}
    pdf = Prawn::Document.new
    pdf.text('Disk Usage')
    pdf.table(two_dimensional_array, :width => 500, :cell_style => { :inline_format => true })
    pdf.render
  end
  
  def pdf_running_process data
    two_dimensional_array = []
    data.split(';').each {|level1| two_dimensional_array << level1.split(',')}
    pdf = Prawn::Document.new
    pdf.text('Running Process')
    pdf.table(two_dimensional_array, :width => 500, :cell_style => { :inline_format => true })
    pdf.render
  end
  
  def configure_alert
    loader = ConfigLoader.new
    agent = loader.config_for("agent")
    if agent['MAX_CPU_USAGE']!= params[:limit_cpu_usage] && !params[:limit_cpu_usage].nil?
      agent['MAX_CPU_USAGE'] = params[:limit_cpu_usage]
    end
    if agent['MAX_DISK_USAGE']!= params[:limit_disk_usage] && !params[:limit_disk_usage].nil?
      agent['MAX_DISK_USAGE'] = params[:limit_disk_usage]
    end
    if agent['MAX_RUNNING_PROCESS']!= params[:limit_running_process] && !params[:limit_running_process].nil?
      agent['MAX_RUNNING_PROCESS'] = params[:limit_running_process]
    end
    @limit_cpu_usage = agent['MAX_CPU_USAGE']
    @limit_disk_usage = agent['MAX_DISK_USAGE']
    @limit_running_process = agent['MAX_RUNNING_PROCESS']
    loader.update
  end

end
