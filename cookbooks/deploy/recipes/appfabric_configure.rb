
powershell "Configuring AppFabric" do
  powershell_script = <<"POWERSHELL_SCRIPT"
if (Test-Path #{node[:deploy]['appfabric_shared_folder']}\ClusterConfig.xml)
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
$cache_array = $env:CACHES.split(',')
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


