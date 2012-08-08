# update mule properties file with deployment specific information

ruby_scripts_dir = node['ruby_scripts_dir']

template "#{ruby_scripts_dir}/update_configuration_tokens.rb" do
  source 'scripts/update_configuration_tokens.erb'
  variables(
    :app_server => node[:deploy][:app_server],
    :cache_server => node[:deploy][:cache_server],
    :db_port => node[:db_port],
    :db_server => node[:deploy][:db_server],
    :engine_port => node[:engine_port],
    :engine_server => node[:deploy][:engine_server],
    :messaging_port => node[:messaging_port],
    :messaging_server => node[:deploy][:messaging_server],
    :search_port => node[:search_port],
    :search_server => node[:deploy][:search_server],
    :web_server => node[:deploy][:web_server]
  )
end

bash 'Updating tokens in Mule configuration' do
  code <<-EOF
     ruby #{ruby_scripts_dir}/update_configuration_tokens.rb
  EOF
end
log "updated tokens in Mule configuration"
