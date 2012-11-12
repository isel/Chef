rightscale_marker :begin

script = "#{node[:ruby_scripts_dir]}/get_deployment_settings.rb"

template script do
  source 'scripts/update_configuration.erb'
  variables(
    :api_infrastructure_url => node['core']['api_infrastructure_url'],
    :deployment_uri => node['core']['deployment_uri']
  )
end

if node[:platform] == "ubuntu"
  bash('Getting deployment settings') { code "ruby #{script}" }
else
  powershell('Getting deployment settings') { source("ruby #{script}") }
end

rightscale_marker :end
