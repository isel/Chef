ruby_scripts_dir = '/RubyScripts'

template "#{ruby_scripts_dir}/provision.rb" do
  source 'scripts/provision.erb'
  variables(
    :db_server => node[:deploy][:db_server],
    :sarmus_port => node[:deploy][:sarmus_port]
  )
end

powershell "Provisioning data" do
  source("ruby #{ruby_scripts_dir}/provision.rb")
end
