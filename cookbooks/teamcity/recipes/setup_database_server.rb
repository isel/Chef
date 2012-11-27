rightscale_marker :begin

require 'fileutils'

teamcity_path = 'd:\TeamCity'

FileUtils.mkdir_p("#{teamcity_path}\\lib\\jdbc")

cookbook_file "#{"#{teamcity_path}\\lib\\jdbc"}\\jtds-1.2.5.jar" do
  source "jtds-1.2.5.jar"
end

template "#{teamcity_path}\\config\\database.properties" do
  source 'database.properties'
  variables(
    :database_server => node[:teamcity][:database_server],
    :database_user => node[:teamcity][:database_user],
    :database_password => node[:teamcity][:database_password]
  )
end

rightscale_marker :end