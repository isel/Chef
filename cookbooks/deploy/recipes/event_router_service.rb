require 'rake'
require 'fileutils'
require 'yaml'

ruby_scripts_dir = node['ruby_scripts_dir']

target_directory = File.join(ENV['TEMP'], 'AppServer/Services/Messaging.EventRouter').gsub(/\\/, '/')
install_path = File.join(ENV['ProgramData'], 'Windows Services\Messaging Event Router').gsub(/\\/, '/')
installutil_command_fullpath= 'c:\Windows\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe'

windows_service_change_completion_delay = 30

service_assembly_filename= 'UltimateSoftware.Foundation.Messaging.EventRouter.exe'
service_display_name = 'Ultimate Software Event Router Service'

if File.exist?(target_directory) || File.exists?(install_path)
  # Cleanup block : Powershell
  # 1. issues a service stop request to Windows service
  # 2. uninstalls assembly from .Net 4.x 32 bit GAC
  # 3. confirms the target_directory and install_path no longer exist
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

      chdir ${Env:TEMP}
      if ((get-item -path "${installPath}") -ne $null) {
        Write-Output "Removing directory ""${installPath}"""
        Remove-Item -Path "${installPath}" -Recurse  -Force
        Write-Output "directory ""${installPath}"" should be empty"
        Get-ChildItem -path ${installPath} -ErrorAction SilentlyContinue
      }

      if ((get-item -path "${sourcePath}") -ne $null) {
        Write-Output "Removing directory ""${sourcePath}"""
        Remove-Item -Path "${sourcePath}" -Recurse -Force
        Write-Output "directory ""${sourcePath}"" should be empty"
        Get-ChildItem -path "${sourcePath}" -ErrorAction SilentlyContinue
      }

      # TODO - inspect the assembly is no longer in the GAC
      # Note - gacutil.exe is no longer part of .NET redistributable
      # http://stackoverflow.com/questions/2660355/net-4-0-has-a-new-gac-why

      $Error.clear()
    EOF
    source(powershell_script)
  end
else
  puts 'Event Router Service was not installed on the system'
end

puts "Copying Event Router Service to #{target_directory} and updating configurations"

template "#{ruby_scripts_dir}/event_router_service.rb" do
  source 'scripts/event_router_service.erb'
  variables(
    :binaries_directory => node[:binaries_directory],
    :cache_server => node[:deploy][:cache_server],
    :db_server => node[:deploy][:db_server],
    :messaging_server => node[:deploy][:messaging_server],
    :source_directory => File.join(node[:binaries_directory], 'AppServer/Services/Messaging.EventRouter').gsub(/\\/, '/'),
    :target_directory => target_directory
  )
end

powershell 'Copy the application files to intermediate directory and update application configuration.' do
  source("ruby #{ruby_scripts_dir}/event_router_service.rb")
end

# Install block : powershell
# Installs assembly into .Net 4.x 32 bit GAC
# issues start command to Windows service
powershell 'Install Event Router Service' do
  parameters (
    {
      'DELAY' => windows_service_change_completion_delay,
      'INSTALL_PATH' => install_path.gsub('/', '\\'),
      'INSTALLUTIL_COMMAND_FULLPATH' => installutil_command_fullpath,
      'SERVICE_ASSEMBLY_FILENAME' => service_assembly_filename,
      'SERVICE_DISPLAY_NAME' => service_display_name,
      'SOURCE_PATH' => target_directory.gsub('/', '\\')
    }
  )
  powershell_script = <<-'EOF'
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

Write-Output "Check if prerequisite Windows Feature set is installed"

Import-Module ServerManager

Write-Output "Confirm that MSMQ service is running."

$test = Get-Service | where { $_.displayname -match 'message*' -and $_.status -match 'running' }
Write-Output $test

chdir $installPath

Write-Output "Copy the service build artifacts from $sourcePath to $installPath"

Copy-Item -Path (Join-Path $sourcePath "$assemblyfileSet") -Destination $installPath -Recurse -Force

Get-ChildItem

# need to verify if the files are in place. 

Write-Output "Install the service ""$serviceDisplayName"""
remove-item -path "${installPath}\${install_logFile}" -ErrorAction SilentlyContinue

Write-Output "cmd /c ${installutil_command_fullpath} ""/InstallStateDir=${installPath}"" ""/LogFile=${install_logFile}"" ${assemblyFileName}"
cmd /c ${installutil_command_fullpath} "/InstallStateDir=${installPath}" "/LogFile=${install_logFile}" ${assemblyFileName}


Start-Sleep $windowsServiceChangeCompletionDelay

Write-Output '------------------------'
Get-Content -Path $install_logFile
Write-Output '------------------------'

<#

* Core netsh documentation:
http://msdn.microsoft.com/en-us/library/windows/desktop/cc307245%28v=vs.85%29.aspx

* specific configuration :
http://www.beautyandthebaud.com/http-could-not-register-url-http8000-your-process-does-not-have-access-rights-to-this-namespace/ -

#>

[xml]$settings = Get-Content C:\RubyScripts\deployment_settings.xml
$service_port = $settings.hash['platform-event-router-port'].InnerText

write-output "Configure the new security settings in Windows for EventRouter on port ${service_port}"
$url_expression = "http://+:${service_port}/EventRouter/"

$check_urlacl =  ( netsh http show urlacl ) | where-object {$_ -match "$service_port"}
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

template "#{ruby_scripts_dir}/event_router_launch_check.rb" do
  puts  'Confirming Event Router Service started'
  source 'scripts/event_router_launch_check.erb'
  variables(
    :service_display_name => service_display_name,
    :launch_wait_timeout => 300)
end

powershell 'Copy the application files to intermediate directory and update application configuration.' do
  source("ruby #{ruby_scripts_dir}/event_router_service.rb")
end


puts 'Event Router Service installed'

powershell 'Confirming Event Router Service started' do
  parameters (
    {
      'SERVICE_DISPLAY_NAME' => service_display_name
  'TIMEOUT' => 300
  }
  )
  powershell_script = <<-'EOF'
Function wmi_query{
  $timeout = $args[1]
  $query = $args[0]
  $erroractionpreference = "SilentlyContinue"
  $system = "$Env:COMPUTERNAME"
  $NameSpace = "Root\CIMV2"
  $wmi = [WMISearcher]""
  $wmi.scope.path = "\\$system\$NameSpace"
  $wmi.options.timeout = $timeout
  $wmi.query = $query
  Try{
    $result = $wmi.Get()
    $summary = ''
    foreach ($row in $result){
      $name = $row.name
      $processId = $row.processid
      $status = $row.status
      $startName = $row.startname
      $summary = "Service ""{0}"" status is {1}" -f $name,$status
      # Write-error "$summary" -ForegroundColor Green
    }
  } Catch {
    Write-error "WMI error: $_"
    throw
  }
  $summary
}
$Env:TIMEOUT = 100
$Env:SERVICE_DISPLAY_NAME = 'Ultimate Software Event Router Service'
$max_cnt = 3
$cnt = 0
$timeout = 10
$cumulative_wait_time = 0
$expected_description = "'Service ${Env:SERVICE_DISPLAY_NAME} running'"
while ($cumulative_wait_time -lt ${Env:TIMEOUT}){
  $cnt ++
  $result  = wmi_query "SELECT name, startname, processid, status FROM win32_service WHERE state = 'Running' AND startName = 'localsystem' AND name ='$Env:SERVICE_DISPLAY_NAME'"  '0:0:30'
  if ($result -match 'OK' ){
    write-host "${expected_description} detected."
    break
  } else {
    $cumulative_wait_time = $cumulative_wait_time + $timeout
    write-host "${expected_description} not observed for ${cumulative_wait_time} sec. Retry after $timeout sec."
    start-sleep  $timeout
  }
}

if ( -not $result  -match 'OK' ){
  throw "${expected_description} not observed for ${cumulative_wait_time} sec."
}
$Error.clear()
  EOF
  source(powershell_script)
end


