class Disk < ActiveRecord::Base

  validates_presence_of :server_ip, :disk_usage

  self.table_name = 'disk'
end