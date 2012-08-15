require 'rake'

ruby_scripts_dir = node['ruby_scripts_dir']

template "#{ruby_scripts_dir}/register_cache_hostname.rb" do
  source 'scripts/register_cache_hostname.erb'
  variables(
    :cache_server => node[:deploy][:cache_server],
    :deployment_name => node[:core][:deployment_name]
  )
end

powershell "Registering cache hostname and ip in hosts file" do
  source("ruby #{ruby_scripts_dir}/register_cache_hostname.rb")
end