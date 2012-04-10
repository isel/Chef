powershell 'Install Event Router Service' do
  parameters (
    {
      'SOURCE_PATH' => node[:binaries_directory].gsub('/','\\'),
      'SERVER_MANAGER_FEATURES' => node[:deploy][:server_manager_features],
      'SERVICE_PORT' => node[:deploy][:service_port]

    }
  )

powershell_script = <<-'EOF'

# Installs a .net 4.x 32 bit assembly
# and starts it as  windows service

$serviceDisplayName = "Ultimate Software Event Router Service"

if ( ${Env:RS_REBOOT} -ne $null )  {
  write-output  "Skipping installation of ${serviceDisplayName} execution on reboot."
  exit 0;
}

$install_logFile = 'service_install.log'
$uninstall_logFile = 'service_uninstall.log'
$attachment_dir = "$env:RS_ATTACH_DIR"
$sourcePath = Join-Path  "$env:SOURCE_PATH" 'AppServer\Services\Messaging\Messaging.EventRouter\bin'
$installPath = "${Env:\ProgramData}\installdir"

$assemblyFileSet = "*.*"
$assemblyFileName = "UltimateSoftware.Foundation.Messaging.EventRouter.exe"
$assemblyPackageName = "UltimateSoftware.Foundation.Messaging.EventRouter.zip"

# Choose the proper installer or the 32 bit .net 4.x runtime
$installer_tools = @{
  'v4.0_x86' = 'c:\Windows\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe';
  'v4.0_x64' = 'c:\Windows\Microsoft.NET\Framework64\v4.0.30319\InstallUtil.exe';
  'v2.0_x86' = 'c:\Windows\Microsoft.NET\Framework\v2.0.50727\InstallUtil.exe';
  'v2.0_x64' = 'c:\Windows\Microsoft.NET\Framework64\v2.0.50727\InstallUtil.exe'
}

Write-Output "creating directory ""${sourcePath}"""
New-Item -Path "${sourcePath}" -Type Directory -Force -ErrorAction SilentlyContinue
Write-Output "creating directory ""${installPath}"""
New-Item -Path "${installPath}" -Type Directory -Force -ErrorAction SilentlyContinue


chdir "${sourcePath}"
Get-ChildItem
# need to verify if the files are in place.


Write-Output "Check if prerequisite Windows Feature set is installed"

$features_array = $Env:SERVER_MANAGER_FEATURES -split ';'
$installutil_command_fullpath = $installer_tools['v4.0_x86']

$scInterval = 5

# origin
# http://msdn.microsoft.com/en-us/library/50614e95(v=vs.80).aspx
# http://msdn.microsoft.com/en-us/library/windows/desktop/ms682053%28v=vs.85%29.aspx
# http://web.me.com/stefsewell/TechEd2010/ASI02-INT/Entries/2010/9/19_Part_2_-_Installing_a_new_service.html

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

Write-Output "Start the service ""$serviceDisplayName"""
cmd /c sc.exe start """${serviceDisplayName}"""
Start-Sleep $scInterval

Write-Output "Confirm the service ""$serviceDisplayName"" is  operational"
$test = Get-Service | where { $_.displayname -match $serviceDisplayName -and $_.status -match 'running' }
Write-Output $test


write-output "Configure the new security settings in Windows for EventRouter on port ${env:SERVICE_PORT}"
<#

* Core netsh documentation:
http://msdn.microsoft.com/en-us/library/windows/desktop/cc307245%28v=vs.85%29.aspx

* specific configuration :
http://www.beautyandthebaud.com/http-could-not-register-url-http8000-your-process-does-not-have-access-rights-to-this-namespace/ -

#>

write-output "Configure the new security settings in Windows for EventRouter on port ${env:SERVICE_PORT}"
<#

* Core netsh documentation:
http://msdn.microsoft.com/en-us/library/windows/desktop/cc307245%28v=vs.85%29.aspx

* specific configuration :
http://www.beautyandthebaud.com/http-could-not-register-url-http8000-your-process-does-not-have-access-rights-to-this-namespace/ -

#>
$url_expression = "http://+:${env:SERVICE_PORT}/EventRouter/"

$check_urlacl =  ( netsh http show urlacl ) | where-object {$_ -match "$env:SERVICE_PORT"}
# cannot currently distinguish if there was a correct or a wrong ACL
if ($check_urlacl -ne $null){
  netsh http delete urlacl url=$url_expression
}
netsh http add urlacl url=$url_expression user="NETWORK SERVICE"

# display the settings
netsh http show urlacl "url=${url_expression}"





$Error.clear()

EOF
  source(powershell_script)
end
