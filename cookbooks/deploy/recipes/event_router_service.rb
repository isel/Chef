require 'rake'
require 'fileutils'
require 'yaml'

ruby_scripts_dir = node[:ruby_scripts_dir]
Dir.mkdir(ruby_scripts_dir) unless File.exist? ruby_scripts_dir

template "#{ruby_scripts_dir}/event_router_service.rb" do
  source 'scripts/event_router_service.erb'
  variables(
    {
      :binaries_directory => node[:binaries_directory],
      :cache_server => node[:deploy][:cache_server],
      :db_server => node[:deploy][:db_server],
      :install_directory => File.join(ENV['ProgramData'], 'Windows Services\Messaging Event Router').gsub(/\\/, '/'),
      :messaging_server => node[:deploy][:messaging_server],
      :service_assembly_filename => 'UltimateSoftware.Foundation.Messaging.EventRouter.exe',
      :service_change_timeout => 30,
      :service_launch_timeout => 300,
      :service_query_timeout => 5,
      :service_display_name => 'Ultimate Software Event Router Service',
      :source_directory => File.join(node[:binaries_directory], 'AppServer/Services/Messaging.EventRouter').gsub(/\\/, '/'),
      :staging_directory => File.join(ENV['TEMP'], 'AppServer/Services/Messaging.EventRouter').gsub(/\\/, '/')
    }
  )
end

powershell 'Install Event Router Service.' do
  source("ruby #{ruby_scripts_dir}/event_router_service.rb")
end





