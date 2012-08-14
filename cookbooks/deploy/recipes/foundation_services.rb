require 'rake'
require 'fileutils'

ruby_scripts_dir = node['ruby_scripts_dir']
app_pools = 'ServicesAppPool,ActiveSTSAppPool,ServicesHelpAppPool'

powershell 'Setup websites in IIS' do
  parameters( { 'app_pools' => app_pools } )
  script = <<-EOF
    $services = 'C:\\WebSites\\Services'
    $servicesSite = 'IIS:\\Sites\\Default Web Site'

    $activeSTS = 'C:\\WebSites\\ActiveSTS'
    $activeSTSSite = 'IIS:\\Sites\\ActiveSTS'

    $servicesHelp = 'C:\\WebSites\\Services.Help'
    $servicesHelpSite = 'IIS:\\Sites\\Services.Help'

    import-module WebAdministration
    iis:

    if (get-item "$activeSTSSite" -ErrorAction SilentlyContinue)
    {
      Write-Output 'Web sites are already configured.  Exiting...'
      exit 0
    }

    $error.clear()

    Write-Output 'Configuring app pools'

    # see http://msdn.microsoft.com/en-us/library/aa347554(v=VS.90).aspx

    $app_pools = $env:app_pools.split(',')
    foreach ($pool in $app_pools){
        New-WebAppPool -name $pool
        Set-ItemProperty "iis:\\apppools\\$pool" -name processModel -value @{identityType="NetworkService"}
        Set-ItemProperty "iis:\\apppools\\$pool" -name managedRuntimeVersion -value v4.0
    }

    Write-Output 'Configuring web sites'

    mkdir "$services"
    mkdir "$activeSTS"
    mkdir "$servicesHelp"

    Set-ItemProperty "$servicesSite" -name physicalPath -value "$services"
    New-Item "$activeSTSSite" -physicalPath "$activeSTS" -bindings @{protocol="http";bindingInformation=":81:"}
    New-Item "$servicesHelpSite" -physicalPath "$servicesHelp" -bindings @{protocol="http";bindingInformation=":82:"}

    Set-ItemProperty "$servicesSite" -name applicationPool -value $app_pools[0]
    Set-ItemProperty "$activeSTSSite" -name applicationPool -value $app_pools[1]
    Set-ItemProperty "$servicesHelpSite" -name applicationPool -value $app_pools[2]
  EOF
  source(script)
end

powershell 'Stop application pools in IIS' do
  parameters( { 'app_pools' => app_pools } )
  script = <<-EOF
    import-module WebAdministration
    iis:

    $app_pools = $env:app_pools.split(',')
    foreach ($pool in $app_pools) { Stop-WebAppPool -name $pool }
  EOF
  source(script)
end

template "#{ruby_scripts_dir}/foundation_services.rb" do
  source 'scripts/foundation_services.erb'
  variables(
    :cache_server => node[:deploy][:cache_server],
    :db_port => node[:db_port],
    :db_server => node[:deploy][:db_server],
    :messaging_port => node[:messaging_port],
    :messaging_server => node[:deploy][:messaging_server],
    :search_port => node[:search_port],
    :search_server => node[:deploy][:search_server]
  )
end

template "#{node['binaries_directory']}/AppServer/Websites/UltimateSoftware.Gateway.Active/HealthCheck.html" do
  source 'health_check.erb'
end

template "#{node['binaries_directory']}/AppServer/Websites/UltimateSoftware.Services/HealthCheck.html" do
  source 'health_check.erb'
end

powershell "Updating foundation services" do
  source("ruby #{ruby_scripts_dir}/foundation_services.rb")
end

powershell 'Start application pools in IIS' do
  parameters( { 'app_pools' => app_pools } )
  script = <<-EOF
    import-module WebAdministration
    iis:

    $app_pools = $env:app_pools.split(',')
    foreach ($pool in $app_pools) { Start-WebAppPool -name $pool }
  EOF
  source(script)
end

powershell 'Launch websites' do
  script = <<-EOF
    foreach($port in @('80', '81', '82')) {
      $req = [system.net.WebRequest]::Create("http://localhost:$port")
      try{
        $response = $req.GetResponse()
      }
      catch [system.net.WebException] {
        $response = $_.Exception.Response
      }

      $status = [int]$response.StatusCode
      write-output "$port $status"
      $Error.Clear()
    }
  EOF
  source(script)
end


