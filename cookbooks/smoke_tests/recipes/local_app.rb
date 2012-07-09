ruby_scripts_dir = node['ruby_scripts_dir']

template "#{ruby_scripts_dir}/local_app.rb" do
  source 'scripts/local_app.erb'
  variables(
    :app_server => node[:deploy][:app_server],
    :db_server => node[:deploy][:db_server],
    :db_port => node[:deploy][:db_port],
    :search_server => node[:deploy][:search_server],
    :elastic_search_port => node[:deploy][:elastic_search_port],
    :server_type => node[:core][:server_type]
  )
end

powershell "Running local smoke tests" do
  source("rake --rakefile #{ruby_scripts_dir}/local_app.rb")
end