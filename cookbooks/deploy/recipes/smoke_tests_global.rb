ruby_scripts_dir = node['ruby_scripts_dir']

template "#{ruby_scripts_dir}/smoke_tests_global.rb" do
  source 'scripts/smoke_tests_global.erb'
  variables(
    :app_server => node[:deploy][:app_server],
    :db_server => node[:deploy][:db_server],
    :sarmus_port => node[:deploy][:sarmus_port],
    :tenant => node[:deploy][:tenant],
    :server_type => node[:core][:server_type]
  )
end

powershell "Running global smoke tests" do
  source("rake --rakefile #{ruby_scripts_dir}/smoke_tests_global.rb")
end