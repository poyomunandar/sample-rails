class Cpu < ActiveRecord::Base

  validates_presence_of :server_ip, :cpu_usage

  self.table_name = 'cpu'
end