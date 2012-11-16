rightscale_marker :begin

template "#{node[:ruby_scripts_dir]}/local_app.rb" do
  source 'scripts/local_app.erb'
  variables(
    :app_server => node[:deploy][:app_server],
    :db_server => node[:deploy][:db_server],
    :server_type => node[:core][:server_type]
  )
end

powershell "Running local smoke tests" do
  source("rake --rakefile #{node[:ruby_scripts_dir]}/local_app.rb")
end

rightscale_marker :end