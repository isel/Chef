require 'rake'

FileList['/Websites/**'].each do |f|
  FileUtils.remove_entry(f, true)
end

#['ActiveSTS', 'Models', 'Services', 'Services.Help'].each do |dir|
#  directory "/Websites/#{dir}" do
#    action :create
#  end
#end

#FileUtils.cp_r('/DeployScripts/AppServer/Models', '/Websites')
#FileUtils.cp_r('/DeployScripts/AppServer/Websites/UltimateSoftware.Gateway.Active/.', '/Websites/ActiveSTS')
#FileUtils.cp_r('/DeployScripts/AppServer/Websites/UltimateSoftware.Services/.', '/Websites/Services')
#FileUtils.cp_r('/DeployScripts/AppServer/Websites/UltimateSoftware.Services/.', '/Websites/Services.Help')
