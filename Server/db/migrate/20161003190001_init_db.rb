class InitDb < ActiveRecord::Migration
  def self.up
    create_table :cpu do |t|
      t.float  "cpu_usage"
      t.string  "server_ip"
      t.timestamps
    end
    
    create_table :disk do |t|
      t.float  "disk_usage"
      t.string  "server_ip"
      t.timestamps
    end
    
    create_table :process do |t|
      t.integer  "total_process"
      t.string  "server_ip"
      t.timestamps
    end
  end
end
    