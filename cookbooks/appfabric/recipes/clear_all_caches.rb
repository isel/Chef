powershell "Clearing caches" do
  parameters({ 'APPFABRIC_CACHES' => node[:caches] })
  powershell_script = <<'POWERSHELL_SCRIPT'
  import-module AppFabricPowershell

  foreach ($cache in $APPFABRIC_CACHES.split(',')) {
    write-output "Clearing cache $cache"
    Clear-Cache -CacheName $cache -SecurityMode "None" -Server "localhost" -Port 22233
  }
POWERSHELL_SCRIPT
   source(powershell_script)
end