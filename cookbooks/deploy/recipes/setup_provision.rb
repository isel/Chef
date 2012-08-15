ruby_scripts_dir = node['ruby_scripts_dir']

template "#{ruby_scripts_dir}/setup_provision.rb" do
  source 'scripts/setup_provision.erb'
  variables(
    :db_server => node[:deploy][:db_server]
  )
end

powershell "Setup Provisioning data" do
  source("ruby #{ruby_scripts_dir}/setup_provision.rb")
end