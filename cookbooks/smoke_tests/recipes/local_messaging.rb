ruby_scripts_dir = node[:ruby_scripts_dir]

template "#{ruby_scripts_dir}/local_messaging.rb" do
  source 'scripts/local_messaging.erb'
  variables(
    :activemq_console_port => node[:activemq_console_port],
    :app_server => node[:deploy][:app_server],
    :cache_server => node[:deploy][:cache_server],
    :db_server => node[:deploy][:db_server],
    :engine_server => node[:deploy][:engine_server],
    :messaging_server => node[:deploy][:messaging_server],
    :search_server => node[:deploy][:search_server],
    :server_type => node[:core][:server_type] ,
    :web_server => node[:deploy][:web_server]
  )
end

bash 'Running local smoke tests' do
   code <<-EOF
    rake --rakefile #{ruby_scripts_dir}/local_messaging.rb
  EOF
end
