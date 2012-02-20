
powershell "Running local appfabric cache tests" do
  code <<-EOF
import-module HelpCache/AppfabricPS
import-module DistributedCacheAdministration
use-cachecluster

$cache_array = 'default,TokenStore,SaasPolicy,EntityModel,Securables,Messages,Views,Enumerations'.split(',')
$sleep_seconds = 15

function ensure_is_up([string]$cache) {
    $tries = 1
    $finished = $false
    write-output "cache: $cache ($(get-date))"
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
            write-output "Error with cache $cache, retrying again in $sleep_seconds seconds ($(get-date))"
            start-sleep -s $sleep_seconds
        }
    }
    until ($finished -or $tries -gt 5)

    if (!$finished) {
        write-output "Could not add/remove items the cache $cache after $tries retries"
        exit 1
    }
}

foreach ($cache in $cache_array) {
  ensure_is_up($cache)
}
EOF

end


