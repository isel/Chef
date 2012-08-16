require 'rake'
require 'fileutils'

ruby_scripts_dir = node['ruby_scripts_dir']

template "#{ruby_scripts_dir}/event_router_service.rb" do

  source 'scripts/event_router_service.erb'
  variables(
    :binaries_directory => node[:binaries_directory],
    :db_server  => node[:deploy][:db_server],
    :messaging_port  => node[:messaging_port],
    :messaging_server  => node[:deploy][:messaging_server],
    :source_directory  => File.join( node[:binaries_directory] , 'AppServer/Services/Messaging.EventRouter').gsub(/\\/,'/'),
    :target_directory => File.join( ENV['TEMP'], 'AppServer/Services/Messaging.EventRouter' ).gsub(/\\/,'/')
  )
end

powershell 'copy the application files to intermediate directory and update application configuration.' do
  source("ruby #{ruby_scripts_dir}/event_router_service.rb" )
end
# Install block : powershell
powershell 'Install Event Router Service' do
  parameters (
    {
      'SOURCE_PATH' => File.join( ENV['TEMP'], 'AppServer/Services/Messaging.EventRouter' ).gsub('/','\\'),
      'SERVER_MANAGER_FEATURES' => node[:msmq_features],
      'SERVICE_PORT' => node[:event_router_port]
    }
  )

powershell_script = <<-'EOF'

# Installs a .net 4.x 32 bit assembly
# and starts it as  windows service

$serviceDisplayName = "Ultimate Software Event Router Service"

write-output "REBOOT=${Env:RS_REBOOT}"

$install_logFile = 'service_install.log'
$uninstall_logFile = 'service_uninstall.log'
$sourcePath = "$Env:SOURCE_PATH"
$installPath = "${Env:\ProgramData}\Windows Services\Messaging Event Router"
$assemblyFileSet = '*.*'
$assemblyFileName = 'UltimateSoftware.Foundation.Messaging.EventRouter.exe'

Write-Output "creating directory ""${sourcePath}"""
New-Item -Path "${sourcePath}" -Type Directory -Force -ErrorAction SilentlyContinue
Write-Output "creating directory ""${installPath}"""
New-Item -Path "${installPath}" -Type Directory -Force -ErrorAction SilentlyContinue

chdir "${sourcePath}"
Get-ChildItem

Write-Output "Check if prerequisite Windows Feature set is installed"

$features_array = $Env:SERVER_MANAGER_FEATURES -split ','
$installutil_command_fullpath = 'c:\Windows\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe'

$scInterval = 30
Write-Output "Using sleep time: $scInterval"

Import-Module ServerManager

foreach ($feature in $features_array) {
  $test = get-WindowsFeature -Name $feature | Where-Object { $_.Installed -eq $true }

  if ($test -eq $null) {
    Write-Output "One of Required MSMQ Features [${feature}] is not available on the system"
    exit 1;
  }
  Write-Output $test
}

Write-Output "Confirm that message queue service is running."

$test = Get-Service | where { $_.displayname -match 'message*' -and $_.status -match 'running' }
Write-Output $test

Write-Output "Stop the service $serviceDisplayName"
cmd /c sc.exe stop """${serviceDisplayName}"""

Start-Sleep $scInterval
$Error.clear()

Write-Output "Uninstall the service ""$serviceDisplayName""."
remove-item -path "${installPath}\${uninstall_logFile}"
Write-Output "cmd /c ${installutil_command_fullpath} ""/LogFile=${uninstall_logFile}"" /uninstall  ${assemblyFileName}"
cmd /c ${installutil_command_fullpath} "/LogFile=${uninstall_logFile}" /uninstall $assemblyFileName

Start-Sleep $scInterval

# Get-Content -Path $uninstall_logFile

write-Output "Clean the $installPath"

chdir $installPath
remove-item -path '*' -Recurse -force

Write-Output "Copy / overwrite the service files $sourcePath to $installPath"

Copy-Item -Path (Join-Path $sourcePath "$assemblyfileSet") -Destination $installPath -Recurse -Force


chdir $installPath
Get-ChildItem

# need to verify if the files are in place. 

Write-Output "Install the service ""$serviceDisplayName"""
remove-item -path "${installPath}\${install_logFile}" -ErrorAction SilentlyContinue


Write-Output "cmd /c ${installutil_command_fullpath} ""/InstallStateDir=${installPath}"" ""/LogFile=${install_logFile}"" ${assemblyFileName}"
cmd /c ${installutil_command_fullpath} "/InstallStateDir=${installPath}" "/LogFile=${install_logFile}" ${assemblyFileName}


Start-Sleep $scInterval
# Get-Content -Path $install_logFile

<#

* Core netsh documentation:
http://msdn.microsoft.com/en-us/library/windows/desktop/cc307245%28v=vs.85%29.aspx

* specific configuration :
http://www.beautyandthebaud.com/http-could-not-register-url-http8000-your-process-does-not-have-access-rights-to-this-namespace/ -

#>

write-output "Configure the new security settings in Windows for EventRouter on port ${env:SERVICE_PORT}"
$url_expression = "http://+:${env:SERVICE_PORT}/EventRouter/"

$check_urlacl =  ( netsh http show urlacl ) | where-object {$_ -match "$env:SERVICE_PORT"}
# cannot currently distinguish if there was a correct or a wrong ACL
if ($check_urlacl -ne $null){
  netsh http delete urlacl url=$url_expression
}
netsh http add urlacl url=$url_expression user="NETWORK SERVICE"

# display the settings
netsh http show urlacl "url=${url_expression}"


Write-Output "Start the service ""$serviceDisplayName"""
cmd /c sc.exe start """${serviceDisplayName}"""
Start-Sleep $scInterval

Write-Output "Confirm the service ""$serviceDisplayName"" is  operational"
$test = Get-Service | where { $_.displayname -match $serviceDisplayName -and $_.status -match 'running' }
Write-Output $test

$Error.clear()

EOF
  source(powershell_script)
end
