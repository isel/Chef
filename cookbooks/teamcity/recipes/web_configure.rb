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

ruby_block 'Setup ldap' do
  block do
    config_file = "#{teamcity_path}\\config\\main-config.xml"
    target = <<-'eof'
  <auth-type>
    <login-module class="jetbrains.buildServer.serverSide.impl.auth.LDAPLoginModule" />
    <login-description />
    <guest-login allowed="true" guest-username="guest" />
    <free-registration allowed="false" />
  </auth-type>
</server>
    eof

    text = File.read(config_file)
    modified = text.gsub(/'<\/server>'/, target)
    File.open(config_file, 'w') { |f| f.puts(modified) }
  end
  #not_if { File.read("#{teamcity_path}\\config\\main-config.xml").include?('<auth-type>') }
end

template "#{teamcity_path}\\config\\ldap-config.properties" do
  source 'ldap-config.properties.erb'
end

rightscale_marker :end