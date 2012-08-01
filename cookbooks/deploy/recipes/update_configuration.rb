# update mule properties file with deployment specific information

ruby_scripts_dir = node['ruby_scripts_dir']

template "#{ruby_scripts_dir}/update_configuration_tokens.rb" do
  source 'scripts/update_configuration_tokens.erb'
  variables(

      :db_server => node[:deploy][:db_server],
      :db_port => node[:deploy][:db_port],
      :appserver => node[:deploy][:app_server],
      :app_server => node[:deploy][:app_server],
      :search_port => node[:deploy][:elastic_search_port],
      :search_server => node[:deploy][:search_server],
      :messaging_server_port => node[:deploy][:messaging_server_port],
      :engine_server => node[:deploy][:engine_server],
      :cache_server => node[:deploy][:cache_server],
      :messaging_server => node[:deploy][:messaging_server],
      :engine_port => node[:deploy][:engine_port],
      :web_server => node[:deploy][:web_server]
  # no trailing comma

  )
end

bash 'Updating tokens in Mule configuration' do
  code <<-EOF
     ruby #{ruby_scripts_dir}/update_configuration_tokens.rb
  EOF
end
log "updated tokens in Mule configuration"