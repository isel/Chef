ruby_scripts_dir = node['ruby_scripts_dir']

template "#{ruby_scripts_dir}/provision.rb" do
  source 'scripts/provision.erb'
  variables(
    :app_server => node[:deploy][:app_server],
    :db_server => node[:deploy][:db_server],
    :db_port => node[:deploy][:db_port],
    :force_provision => node[:deploy][:force_provision],
    :tenant => node[:deploy][:tenant]
  )
end

powershell "Provisioning data" do
  source("ruby #{ruby_scripts_dir}/provision.rb")
end