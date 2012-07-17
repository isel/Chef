ruby_scripts_dir = node['ruby_scripts_dir']
template "#{ruby_scripts_dir}/local_messaging.rb" do
  source 'scripts/local_messaging.erb'
  variables(
    :mule_port => node[:deploy][:mule_port],
    :activemq_port => node[:deploy][:activemq_port],
    :server_type => node[:core][:server_type]
  )
end

bash 'Running local smoke tests' do
   code <<-EOF
    rake --rakefile #{ruby_scripts_dir}/local_messaging.rb
  EOF
end

# new smoke tests. currently inline.

token_values = {'cache_server' => node[:deploy][:cache_server],
                'db_server' => node[:deploy][:db_server],
                'db_port' => node[:deploy][:db_port],
                'appserver' => node[:deploy][:app_server],
                'app_server' => node[:deploy][:app_server],
                'search_port' => node[:deploy][:elastic_search_port],
                'search_server' => node[:deploy][:search_server],
                'messaging_server_port' => node[:deploy][:messaging_server_port],
                #  new inputs
                'messaging_server' => node[:deploy][:messaging_server],
                'engine_server' => node[:deploy][:engine_server],
                'engine_port' => node[:deploy][:engine_port],
                'web_server' => node[:deploy][:web_server],
}

