
powershell "Ensuring AppFabric caches are available" do
  parameters(
    {
      'APPFABRIC_CACHES' => node[:deploy][:appfabric_caches]
    }
  )
  powershell_script = <<'POWERSHELL_SCRIPT'
import-module AppFabricPowershell
import-module DistributedCacheAdministration
use-cachecluster

$cache_array = $env:APPFABRIC_CACHES.split(',')
$sleep_seconds = 20

function ensure_is_up([string]$cache) {
    $tries = 1
    $finished = $false
    write-host "cache: $cache ($(get-date))"
    do {
        try {
            Add-CacheItem -CacheName $cache -ItemKey "1" -ItemValue "value" -SecurityMode "None" -Server "localhost" -Port 22233
            if ((Get-CacheStatistics -CacheName $cache).ItemCount -gt 0) {
                Remove-CacheItem -CacheName $cache -ItemKey "1" -Server "localhost" -Port 22233 -SecurityMode "None"
            }
            $finished = $true
        }
        catch {
            $tries += 1
            write-host "Error with cache $cache, retrying again in $sleep_seconds seconds ($(get-date))"
            Get-CacheClusterHealth
            start-sleep -s $sleep_seconds
        }
    }
    until ($finished -or $tries -gt 5)

    if (!$finished) {
        write-host "Could not add/remove items the cache $cache after $tries retries"
        exit 1
    } else {
        $Error.clear()
    }
}

foreach ($cache in $cache_array) {
  ensure_is_up($cache)
}
POWERSHELL_SCRIPT
   source(powershell_script)
end


