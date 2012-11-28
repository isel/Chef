rightscale_marker :begin

require 'fileutils'

teamcity_path = 'd:\TeamCity'

cookbook_file "#{teamcity_path}\\lib\\jdbc\\jtds-1.2.5.jar" do
  source "jtds-1.2.5.jar"
end

template "#{teamcity_path}\\config\\database.properties" do
  source 'database.properties.erb'
  variables(
    :database_server => node[:teamcity][:database_server],
    :database_user => node[:teamcity][:database_user],
    :database_password => node[:teamcity][:database_password]
  )
end

template "#{teamcity_path}\\config\\license.keys" do
  source 'license.keys.erb'
end

class Chef::Resource
  include Configuration
end

powershell 'Install xml-simple' do
  script = <<'EOF'
  cd "c:\\Program Files (x86)\\RightScale\\RightLink\\sandbox\\ruby\\bin"
  cmd /c gem install xml-simple -v 1.1.1 --no-rdoc --no-ri
EOF
  source(script)
end

ruby_block 'Setup ldap' do
  block do
    config_file = "#{teamcity_path}\\config\\main-config.xml"
    change_authorization(config_file)
  end
  not_if { File.read("#{teamcity_path}\\config\\main-config.xml").include?('login-module') }
end

template "#{teamcity_path}\\config\\ldap-config.properties" do
  source 'ldap-config.properties.erb'
end

rightscale_marker :end