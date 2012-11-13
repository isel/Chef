rightscale_marker :begin

require 'rake'

template "#{node[:ruby_scripts_dir]}/register_cache_hostname.rb" do
  source 'scripts/register_cache_hostname.erb'
  variables(
    :cache_server => node[:deploy][:cache_server],
    :deployment_name => node[:deploy][:deployment_name]
  )
end

powershell "Registering cache hostname and ip in hosts file" do
  source("ruby #{node[:ruby_scripts_dir]}/register_cache_hostname.rb")
end

rightscale_marker :end