module Agent
  require_relative '../config_loader'
  class Server
    def cpu_usage
      return `ps -aux  | awk 'BEGIN { sum = 0 }  { sum += $3 } END { print sum }'`
    end   
    
    def disk_usage
      return `df -hl | awk '/^\\/dev\\// { sumusage+=$3;sumtotal+=$2 } END { print sumusage/sumtotal*100 }'`      
    end
    
    def running_process      
      return `ps -Al | wc -l`
    end
    
    def alert message
      log_filename = ConfigLoader.new.config_for("agent")["ALERT_FILENAME"].to_s
      File.open(log_filename, 'a+b') do |file|
        file.write "#{Time.now}       #{message}\n"
      end
    end
  end
end