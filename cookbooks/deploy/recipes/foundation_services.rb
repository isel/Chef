require 'rake'

FileList['/Websites/**'].each do |f|
  FileUtils.remove_entry(f, true)
end

FileUtils.cp_r('/DeployScripts/AppServer/Models', '/Websites')
FileUtils.cp_r('/DeployScripts/AppServer/Websites/UltimateSoftware.Gateway.Active/.', '/Websites/ActiveSTS')
FileUtils.cp_r('/DeployScripts/AppServer/Websites/UltimateSoftware.Services/.', '/Websites/Services')
FileUtils.cp_r('/DeployScripts/AppServer/Websites/UltimateSoftware.Services/.', '/Websites/Services.Help')

ruby_scripts_dir = '/RubyScripts'

template "#{ruby_scripts_dir}/update_configurations.rb" do
  source 'scripts/update_configurations.erb'
  #variables(
  #  :db_port => node[:deploy][:revision]
  #)
end

powershell "Updating configurations" do
  source("ruby #{ruby_scripts_dir}/update_configurations.rb")
end