require 'rake'

['ActiveSTS', 'Models', 'Services', 'Services.Help'].each do |dir|
  directory "/Websites/#{dir}" do
    recursive true
    action :delete, :create
  end
end

FileUtils.cp_r('/DeployScripts/AppServer/Models', '/Websites')
FileUtils.cp_r('/DeployScripts/AppServer/Websites/UltimateSoftware.Gateway.Active/.', '/Websites/ActiveSTS')
FileUtils.cp_r('/DeployScripts/AppServer/Websites/UltimateSoftware.Services/.', '/Websites/Services')
FileUtils.cp_r('/DeployScripts/AppServer/Websites/UltimateSoftware.Services/.', '/Websites/Services.Help')
