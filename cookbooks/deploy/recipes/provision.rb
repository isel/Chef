ruby_scripts_dir = '/RubyScripts'

template "#{ruby_scripts_dir}/provision.rb" do
  source 'scripts/provision.erb'
  variables(
    :cache_server => node[:deploy][:cache_server],
    :db_server => node[:deploy][:db_server],
    :sarmus_port => node[:deploy][:sarmus_port]
  )
end

powershell "Provisioning data" do
  source("ruby #{ruby_scripts_dir}/provision.rb")
end

remote_recipe 'Tag data version on mongo server' do
  recipe 'deploy::tag_data_version'
  recipients_tags ['server:type=db']
end