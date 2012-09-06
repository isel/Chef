powershell "Clearing caches" do
  parameters(
    {
      'APPFABRIC_SECURITY' => node[:appfabric][:security],
      'APPFABRIC_CACHES' => node[:caches]
    }
  )
  powershell_script = <<'POWERSHELL_SCRIPT'
  import-module AppFabricPowershell

  $caches = $env:APPFABRIC_CACHES.split(',')
  foreach ($cache in $caches) {
    write-output "Clearing cache $cache"
    Clear-Cache -CacheName $cache -SecurityMode $env:APPFABRIC_SECURITY -Server "localhost" -Port 22233
  }
POWERSHELL_SCRIPT
   source(powershell_script)
end