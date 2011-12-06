require 'rake'

['ActiveSTS', 'Apps', 'Models', 'Services', 'Services.Help'].each do |dir|
  directory "/Websites/#{dir}" do
    recursive true
    action :delete, :create
  end
end

FileUtils.cp_r('/DeployScripts/Models', '/Websites')
FileUtils.cp_r('/DeployScripts/AppServer/.', '/Websites')
