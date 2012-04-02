require 'rake'
require 'fileutils'

ruby_scripts_dir = node['ruby_scripts_dir']

template "#{ruby_scripts_dir}/foundation_services.rb" do
  source 'scripts/foundation_services.erb'
  variables(
    :cache_server => node[:deploy][:cache_server],
    :db_server => node[:deploy][:db_server],
    :elastic_search_port => node[:deploy][:elastic_search_port],
    :db_port => node[:deploy][:db_port]
  )
end

template "#{node['binaries_directory']}/AppServer/Websites/UltimateSoftware.Gateway.Active/HealthCheck.html" do
  source 'health_check.erb'
end

template "#{node['binaries_directory']}/AppServer/Websites/UltimateSoftware.Services/HealthCheck.html" do
  source 'health_check.erb'
end

powershell "Updating foundation services" do
  source("ruby #{ruby_scripts_dir}/foundation_services.rb")
end


