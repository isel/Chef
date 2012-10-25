ruby_scripts_dir = node[:ruby_scripts_dir]

template "#{ruby_scripts_dir}/global.rb" do
  source 'scripts/global.erb'
  variables(
      :app_server => node[:deploy][:app_server],
      :db_server => node[:deploy][:db_server],
      :messaging_server => node[:deploy][:messaging_server],
      :tenant => node[:deploy][:tenant],
      :server_type => node[:core][:server_type]
  )
end

#todo: register errors on smoke tests using the api service
powershell "Running global smoke tests" do
  source("rake --rakefile #{ruby_scripts_dir}/global.rb")
end