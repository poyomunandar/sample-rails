Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'statistics#cpu_usage'
  get 'webservices/cpu_usage', :to => 'webservices#cpu_usage'
  get 'webservices/disk_usage', :to => 'webservices#disk_usage'
  get 'webservices/running_process', :to => 'webservices#running_process'
  get 'cpu_usage', :to => 'statistics#cpu_usage'
  get 'disk_usage', :to => 'statistics#disk_usage'
  get 'running_process', :to => 'statistics#running_process'
  get 'configure_alert', :to => 'statistics#configure_alert'
end
