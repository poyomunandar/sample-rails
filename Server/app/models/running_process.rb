class RunningProcess < ActiveRecord::Base

  validates_presence_of :server_ip, :total_process

  self.table_name = 'process'
end