
powershell "Ensuring AppFabric caches are available" do
  parameters(
    {
      'APPFABRIC_CACHES' => node[:deploy][:appfabric_caches]
    }
  )
  powershell_script = <<'POWERSHELL_SCRIPT'

write-output 'Skipping appfabric caches check'
exit 0

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
            $to_mega = 1024

            write-output "CPU utilization: $($(gwmi -class Win32_Processor).LoadPercentage) %"

            $mem = Get-WmiObject -Class Win32_OperatingSystem -Namespace root/cimv2 -ComputerName .
            write-output "Total Virtual Memory Size: $($mem.TotalVirtualMemorySize / $to_mega)"
            write-output "Total Visible Memory Size: $($mem.TotalVisibleMemorySize / $to_mega)"
            write-output "Free Physical Memory: $($mem.FreePhysicalMemory / $to_mega)"
            write-output "Free Virtual Memory: $($mem.FreeVirtualMemory / $to_mega)"
            write-output "Free Space In Paging Files: $($mem.FreeSpaceInPagingFiles / $to_mega)"

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


