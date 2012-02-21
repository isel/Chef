powershell "Install AppFabric" do
  parameters (
    {
      'APPFABRIC_SHARED_FOLDER' => node[:deploy][:appfabric_shared_folder]
    }
  )
  powershell_script = <<POWERSHELL_SCRIPT
if (Test-Path $env:APPFABRIC_SHARED_FOLDER\ClusterConfig.xml)
{
  Write-Output 'AppFabric already installed'
  exit 0
}

cd "$env:RS_ATTACH_DIR"

cmd /c "WindowsServerAppFabricSetup_x64_6.1.exe /i /SkipUpdates /l c:\installs\appfabric.log"

cmd /c "sc config AppFabricWorkflowManagementService start= disabled"
POWERSHELL_SCRIPT
  source(powershell_script)
end

powershell "Setup AppFabric shared folder" do
  parameters (
    {
      'APPFABRIC_SECURITY' => node[:deploy][:appfabric_security],
      'APPFABRIC_SERVICE_USER' => node[:deploy][:appfabric_service_user],
      'APPFABRIC_SERVICE_PASSWORD' => node[:deploy][:appfabric_service_password],
      'APPFABRIC_SHARED_DRIVE' => node[:deploy][:appfabric_shared_drive],
      'APPFABRIC_SHARED_FOLDER' => node[:deploy][:appfabric_shared_folder]
    }
  )
  powershell_script = <<POWERSHELL_SCRIPT
cd "$env:RS_ATTACH_DIR"

if (Test-Path $env:APPFABRIC_SHARED_FOLDER)
{
  Write-Output 'AppFabric shared folder already configured'
  exit 0
}

$host_name = $env:computername
$service_account = "$env:computername\$env:APPFABRIC_SERVICE_USER"

Write-Output "setup appfabric user"
cmd /c "net user $env:APPFABRIC_SERVICE_USER $env:APPFABRIC_SERVICE_PASSWORD /add /expires:never"
cmd /c "set_password_to_not_expire_for $env:APPFABRIC_SERVICE_USER"
cmd /c "ntrights +r SeServiceLogonRight -u $env:APPFABRIC_SERVICE_USER"
cmd /c "ntrights +r SeAuditPrivilege -u $env:APPFABRIC_SERVICE_USER"

Write-Output "setup shared drive"
New-Item $env:APPFABRIC_SHARED_FOLDER -type directory

cmd /c "net share $env:APPFABRIC_SHARED_DRIVE=$env:APPFABRIC_SHARED_FOLDER /Grant:everyone,FULL /Grant:$env:APPFABRIC_SERVICE_USER,FULL /unlimited"

Write-Output "give full control to $service_account"
$acl = Get-Acl $env:APPFABRIC_SHARED_FOLDER
$permission = "$service_account","FullControl","Allow"
$accessRule = new-object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.SetAccessRule($accessRule)
$acl | Set-Acl $env:APPFABRIC_SHARED_FOLDER

Write-Output "give full control to administrator"
$acl = Get-Acl $env:APPFABRIC_SHARED_FOLDER
$permission = "$host_name\administrator","FullControl","Allow"
$accessRule = new-object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.SetAccessRule($accessRule)
$acl | Set-Acl $env:APPFABRIC_SHARED_FOLDER
POWERSHELL_SCRIPT
  source(powershell_script)
end

powershell "Configure AppFabric" do
  parameters(
    {
      'APPFABRIC_CACHES' => node[:deploy][:appfabric_caches],
      'APPFABRIC_SECURITY' => node[:deploy][:appfabric_security],
      'APPFABRIC_SERVICE_USER' => node[:deploy][:appfabric_service_user],
      'APPFABRIC_SERVICE_PASSWORD' => node[:deploy][:appfabric_service_password],
      'APPFABRIC_SHARED_DRIVE' => node[:deploy][:appfabric_shared_drive],
      'APPFABRIC_SHARED_FOLDER' => node[:deploy][:appfabric_shared_folder]
    }
  )
  powershell_script = <<POWERSHELL_SCRIPT
if (Test-Path "$env:APPFABRIC_SHARED_FOLDER\ClusterConfig.xml")
{
  Write-Output 'AppFabric already configured'
  exit 0
}

Import-Module DistributedCacheAdministration
Import-Module DistributedCacheConfiguration

$provider = "XML"
$host_name = $env:computername
$service = 'AppFabricCachingService'
$service_account = "$host_name\$env:APPFABRIC_SERVICE_USER"

$connection_string = "\\$host_name\$env:APPFABRIC_SHARED_DRIVE"

$cluster_size = "Small"
$starting_port = 22233
$cache_port = $starting_port + 0
$cluster_port = $starting_port + 1
$arbitration_port = $starting_port + 2
$replication_port = $starting_port + 3

Write-Output "New-CacheHost"
New-CacheCluster -Provider $provider -ConnectionString $connection_string -Size $cluster_size

try
{
  Write-Output "Register-CacheHost"
  Register-CacheHost -Provider $provider -ConnectionString $connection_string -Account `
     $service_account -CachePort $cache_port -ClusterPort $cluster_port -ArbitrationPort `
     $arbitration_port -ReplicationPort $replication_port `
     -HostName $host_name
}
catch
{
  Write-Output "Error registering cache host"
  $Error.Clear()
}

Write-Output "Fixing security permissions for shared folder"
$user = "everyone"
$path = $env:APPFABRIC_SHARED_FOLDER.replace("\", "\\")
$SD = ([WMIClass] "Win32_SecurityDescriptor").CreateInstance()
$ace = ([WMIClass] "Win32_ace").CreateInstance()
$Trustee = ([WMIClass] "Win32_Trustee").CreateInstance()
$SID = (new-object security.principal.ntaccount $user).translate([security.principal.securityidentifier])
[byte[]] $SIDArray = ,0 * $SID.BinaryLength
$SID.GetBinaryForm($SIDArray,0)
$Trustee.Name = $user
$Trustee.SID = $SIDArray
$ace.AccessMask =
[System.Security.AccessControl.FileSystemRights]"FullControl"
$ace.AceFlags = "0x67"
$ace.AceType = 0
$ace.Trustee = $trustee
$oldDACL = (gwmi Win32_LogicalFileSecuritySetting -filter "path='$path'").GetSecurityDescriptor().Descriptor.DACL
$SD.DACL = $oldDACL
$SD.DACL += @($ace.psobject.baseobject)
$SD.ControlFlags="0x4"
$folder = gwmi Win32_LogicalFileSecuritySetting -filter "path='$path'"
$folder.setsecuritydescriptor($SD)

Write-Output "Add-CacheHost"
Add-CacheHost -Provider $provider -ConnectionString $connection_string -Account $service_account

Write-Output "Add-CacheAdmin"
Add-CacheAdmin -Provider $provider -ConnectionString $connection_string

Use-CacheCluster

if ($env:APPFABRIC_SECURITY -eq 'none') {
  Write-Output "Setting security to none"
  Set-CacheClusterSecurity -SecurityMode None -ProtectionLevel None
}
else {
  Write-Output "Grant-CacheAllowedClientAccount"
  Grant-CacheAllowedClientAccount administrator
  Grant-CacheAllowedClientAccount "NT Authority\Network Service"
}

Write-Output "New-Cache"
$cache_array = $env:APPFABRIC_CACHES.split(',')
foreach ($cache in $cache_array){
  New-Cache  -CacheName  $cache  -Secondaries  0  -Eviction  LRU  -Expirable  True  -TimeToLive  10  -NotificationsEnabled  False
}

Write-Output "Setting up AppFabric Service"
cmd /c "sc.exe config $service obj= $service_account password= $env:APPFABRIC_SERVICE_PASSWORD"
cmd /c "sc config $service start= auto"
cmd /c "net start $service"
POWERSHELL_SCRIPT
   source(powershell_script)
end


