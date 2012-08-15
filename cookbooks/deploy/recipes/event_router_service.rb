require 'rake'
require 'fileutils'
require 'yaml'

ruby_scripts_dir = node['ruby_scripts_dir']

#  why does one still need to mix ruby with powershell in this recipe?
#  because of "change_app_setting" library call

target_directory = File.join(ENV['TEMP'], 'AppServer/Services/Messaging.EventRouter').gsub(/\\/, '/')
install_path = File.join(ENV['ProgramData'], 'Windows Services\Messaging Event Router').gsub(/\\/, '/')
installutil_command_fullpath= 'c:\Windows\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe'

windows_service_change_completion_delay = 30

service_assembly_filename=  'UltimateSoftware.Foundation.Messaging.EventRouter.exe'
service_display_name = 'Ultimate Software Event Router Service'


if File.exist?(target_directory) || File.exists?(install_path)

  # Cleanup block : powershell
  # 1. issues a service stop request to Windows service
  # 2. uninstalls assembly from .Net 4.x 32 bit GAC
  # 3. confirms there is no longer

  powershell 'Stopping,Uninstalling and removing Event Router Service' do
    parameters (
                   {
                       'DELAY' => windows_service_change_completion_delay,
                       'INSTALL_PATH' => install_path.gsub('/', '\\'),
                       'INSTALLUTIL_COMMAND_FULLPATH' => installutil_command_fullpath,
                       'SERVICE_DISPLAY_NAME' => service_display_name,
                       'SERVICE_ASSEMBLY_FILENAME' => service_assembly_filename,
                       'SOURCE_PATH' => target_directory.gsub('/', '\\'),
                   }
               )

    powershell_script = <<-'EOF'

$assemblyFileName =  "$Env:SERVICE_ASSEMBLY_FILENAME"
$installPath = "$Env:INSTALL_PATH"
$installutil_command_fullpath = "$Env:INSTALLUTIL_COMMAND_FULLPATH"
$windowsServiceChangeCompletionDelay = $Env:DELAY

$serviceDisplayName = "$Env:SERVICE_DISPLAY_NAME"

$sourcePath = "$Env:SOURCE_PATH"
$uninstall_logFile = 'service_uninstall.log'

Write-Output "Stop the service $serviceDisplayName"
cmd /c sc.exe stop """${serviceDisplayName}"""

Start-Sleep $windowsServiceChangeCompletionDelay
$Error.clear()

# Repeat trhe last action
Write-Output "Stop the service ""$serviceDisplayName"""
cmd /c sc.exe stop """${serviceDisplayName}"""
$Error.clear()

Write-Output "Uninstall the service ""$serviceDisplayName""."
remove-item -path "${installPath}\${uninstall_logFile}" -ErrorAction SilentlyContinue



chdir $installPath

Write-Output "cmd /c ${installutil_command_fullpath} ""/LogFile=${uninstall_logFile}"" /uninstall  ${assemblyFileName}"
cmd /c ${installutil_command_fullpath} "/LogFile=${uninstall_logFile}" /uninstall $assemblyFileName

Start-Sleep $windowsServiceChangeCompletionDelay

Write-Output '------------------------'
Get-Content -Path $uninstall_logFile
Write-Output '------------------------'

Write-Output "Removing directory ""${installPath}"""
Remove-Item -Path """${installPath}""" -Recurse  -Force -ErrorAction SilentlyContinue
# TODO -  confirm the directories are blank
Write-Output "directory ""${installPath}"" should be empty"
Get-ChildItem -path """${installPath}"""
Get-ChildItem -path "${installPath}"


Write-Output "Removing directory ""${sourcePath}"""
Remove-Item -Path "${sourcePath}" -Recurse -Force -ErrorAction SilentlyContinue

# TODO -  confirm the directories are blank
Write-Output "directory ""${sourcePath}"" should be empty"
Get-ChildItem -path "${sourcePath}"

# TODO - inspect the assembly is no longer in the GAC
# Note - gacutil.exe is not found on WK8R2.
$Error.clear()

    EOF
    source(powershell_script)

  end
else
  puts 'Event Router Service not installed on the system'

end

puts "Copying Event Router Service to #{target_directory} and updating configurations"

template "#{ruby_scripts_dir}/event_router_service.rb" do

  source 'scripts/event_router_service.erb'
  variables(
      :binaries_directory => node[:binaries_directory],
      :db_port => node[:db_port],
      :db_server => node[:deploy][:db_server],
      :messaging_port => node[:messaging_port],
      :messaging_server => node[:deploy][:messaging_server],
      :source_directory => File.join(node[:binaries_directory], 'AppServer/Services/Messaging.EventRouter').gsub(/\\/, '/'),
      :target_directory => target_directory
  )
end

powershell 'Copy the application files to intermediate directory and update application configuration.' do
  source("ruby #{ruby_scripts_dir}/event_router_service.rb")
end

# Install block : powershell
powershell 'Install Event Router Service' do
  parameters (
                 {
                     'DELAY' => windows_service_change_completion_delay,

                     'INSTALL_PATH' => install_path.gsub('/', '\\'),
                     'INSTALLUTIL_COMMAND_FULLPATH' => installutil_command_fullpath,
                     'SERVICE_ASSEMBLY_FILENAME' => service_assembly_filename,
                     'SERVICE_DISPLAY_NAME' => service_display_name,
                     'SERVICE_PORT' => node[:event_router_port],
                     'SERVER_MANAGER_FEATURES' => node[:msmq_features],
                     'SOURCE_PATH' => target_directory.gsub('/', '\\')
                 }
             )

  powershell_script = <<-'EOF'

# Installs assembly into .Net 4.x 32 bit GAC
# issues start command to Windows service

$serviceDisplayName = "$Env:SERVICE_DISPLAY_NAME"

write-output "REBOOT=${Env:RS_REBOOT}"

$assemblyFileName =  "$Env:SERVICE_ASSEMBLY_FILENAME"
$assemblyFileSet = '*.*'
$install_logFile = 'service_install.log'
$installPath = "$Env:INSTALL_PATH"
$installutil_command_fullpath = "$Env:INSTALLUTIL_COMMAND_FULLPATH"

$windowsServiceChangeCompletionDelay = $Env:DELAY

$sourcePath = "$Env:SOURCE_PATH"

Write-Output "creating directory ""${installPath}"""
New-Item -Path "${installPath}" -Type Directory -Force -ErrorAction SilentlyContinue

chdir "${sourcePath}"
Get-ChildItem

Write-Output "Check if prerequisite Windows Feature set is installed"

$features_array = $Env:SERVER_MANAGER_FEATURES -split ','

Write-Output "Using sleep time: $windowsServiceChangeCompletionDelay"

Import-Module ServerManager

foreach ($feature in $features_array) {
  $test = get-WindowsFeature -Name $feature | Where-Object { $_.Installed -eq $true }

  if ($test -eq $null) {
    Write-Output "One of Required MSMQ Features [${feature}] is not available on the system"
    exit 1;
  }
  Write-Output $test
}

Write-Output "Confirm that MSMQ service is running."

$test = Get-Service | where { $_.displayname -match 'message*' -and $_.status -match 'running' }
Write-Output $test

chdir $installPath

Write-Output "Copy / overwrite the service files $sourcePath to $installPath"

Copy-Item -Path (Join-Path $sourcePath "$assemblyfileSet") -Destination $installPath -Recurse -Force

Get-ChildItem

# need to verify if the files are in place. 

Write-Output "Install the service ""$serviceDisplayName"""
remove-item -path "${installPath}\${install_logFile}" -ErrorAction SilentlyContinue

Write-Output "cmd /c ${installutil_command_fullpath} ""/InstallStateDir=${installPath}"" ""/LogFile=${install_logFile}"" ${assemblyFileName}"
cmd /c ${installutil_command_fullpath} "/InstallStateDir=${installPath}" "/LogFile=${install_logFile}" ${assemblyFileName}


Start-Sleep $windowsServiceChangeCompletionDelay
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
netsh.exe http add urlacl url=$url_expression user="NETWORK SERVICE"

# display the settings
netsh.exe http show urlacl "url=${url_expression}"


Write-Output "Start the service ""$serviceDisplayName"""
cmd /c sc.exe start """${serviceDisplayName}"""
Start-Sleep $windowsServiceChangeCompletionDelay

Write-Output "Confirm the service ""$serviceDisplayName"" is  operational"
$test = Get-Service | where { $_.displayname -match $serviceDisplayName -and $_.status -match 'running' }
Write-Output $test

$Error.clear()

  EOF
  source(powershell_script)
end
