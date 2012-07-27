ruby_scripts_dir = node['ruby_scripts_dir']

template "#{ruby_scripts_dir}/global.rb" do
  source 'scripts/global.erb'
  variables(
      :app_server => node[:deploy][:app_server],
      :db_server => node[:deploy][:db_server],
      :engine_server => node[:deploy][:engine_server],
      :db_port => node[:deploy][:db_port],
      :messaging_server_port => node[:deploy][:messaging_server_port],
      :messaging_server => node[:deploy][:messaging_server],
      :tenant => node[:deploy][:tenant],
      :server_type => node[:core][:server_type]
  )
end

powershell "Running global smoke tests" do
  source("rake --rakefile #{ruby_scripts_dir}/global.rb")
end