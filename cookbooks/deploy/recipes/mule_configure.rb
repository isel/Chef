template "#{node[:ruby_scripts_dir]}/update_configuration_tokens.rb" do
  source 'scripts/update_configuration_tokens.erb'
  variables(
    :app_server => node[:deploy][:app_server],
    :cache_server => node[:deploy][:cache_server],
    :db_server => node[:deploy][:db_server],
    :engine_server => node[:deploy][:engine_server],
    :messaging_server => node[:deploy][:messaging_server],
    :search_server => node[:deploy][:search_server],
    :tenant => node[:deploy][:tenant],
    :web_server => node[:deploy][:web_server]
  )
end

bash('Updating tokens in Mule configuration') { code "ruby #{node[:ruby_scripts_dir]}/update_configuration_tokens.rb" }