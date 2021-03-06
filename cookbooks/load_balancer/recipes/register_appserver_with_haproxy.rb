rightscale_marker :begin

template "#{node[:ruby_scripts_dir]}/wait_for_load_balancers.rb" do
  source 'scripts/wait_for_load_balancers.erb'
  variables(
    :deployment_name => node[:deploy][:deployment_name],
    :timeout => '30*60'
  )
end

powershell 'Waiting for load balancers to be operational' do
  source("ruby #{node[:ruby_scripts_dir]}/wait_for_load_balancers.rb")
  only_if { node[:load_balancer][:should_register_with_lb] == 'true' }
end

powershell 'Register app server with HAProxy' do
  parameters (
    {
      'SHOULD_REGISTER_WITH_LB' => node[:load_balancer][:should_register_with_lb],
      'LB_APPLISTENER_NAMES' => node[:app_listener_names],
      'LB_BACKEND_NAME' => node[:load_balancer][:backend_name],
      'LB_HOSTNAME' => "#{node[:load_balancer][:prefix]}.#{node[:load_balancer][:domain]}",
      'MAX_CONN_PER_SERVER' => node[:max_connections_per_lb],
      'HEALTH_CHECK_URI' => node[:health_check_uri],
      'PRIVATE_SSH_KEY' => node[:load_balancer][:private_ssh_key],
      'APP_SERVER_PORTS' => node[:app_server_ports],
      'OPT_SESSION_STICKINESS' => node[:session_stickiness],
      'IP_ADDRESS' => node[:deploy][:app_server],
      'RUBY187' => node[:ruby187]
    }
  )

  script = <<-'EOF'
# Stop and fail script when a command fails
$ErrorActionPreference="Stop"

if($env:SHOULD_REGISTER_WITH_LB -eq 'false')
{
  Write-Host "No load balancer to connect to - exiting."
  exit 0
}

Write-Host "Host name: $env:LB_HOSTNAME"

function register_with_load_balancer($app_listener_name, $port)
{
  write-output "registering with load balancer ($app_listener_name, $port)"

  mkdir -force C:\HAProxy
  cd c:\HAProxy

  # Get Loadbalancer IP address via reverse DNS lookup
  $LB_IPAddresses = ([System.Net.Dns]::GetHostAddresses($env:LB_HOSTNAME) | Select IPAddressToString)

  echo "-----------------[ $LB_IPAddresses ]--------------"

  #Create Key File to access HAProxy server
  Set-Content -path "C:\HAProxy\private.key" -value $env:PRIVATE_SSH_KEY

  if ($env:MAX_CONN_PER_SERVER -notmatch "^\d+$"){
     Write-Output "MAX_CONN_PER_SERVER undefined or not an integer, defaulting to 255"
     $env:MAX_CONN_PER_SERVER=255
  }

  $haproxy_script = "$env:RUBY187 /opt/rightscale/lb/bin/haproxy_config_server.rb"

  $arguments = @(
  	"-a add",
  	"-w",
  	"-s $env:LB_BACKEND_NAME",
  	"-l $app_listener_name",
  	"-t $env:IP_ADDRESS`:$port",
  	"-e `"inter 3000 rise 2 fall 3 maxconn $env:MAX_CONN_PER_SERVER`""
  )

  if ($env:HEALTH_CHECK_URI -match "^.+$"){
     $arguments += "-k on"
  }

  if ($env:OPT_SESSION_STICKINESS -match "(true|false|on)$"){
     $arguments += "-c $env:LB_BACKEND_NAME"
  }

  # Join arguments and build linux command
  $arguments = [string]::join(' ',$arguments)
  $linux_command = $haproxy_script + " " + $arguments

  # Escape the quotation marks and wrap the linux command in quotes
  $linux_command = $linux_command.Replace("`"","`"`"")
  $linux_command = "`"$linux_command`""

  # Iterate through each IP address of the load balancer to
  # register instance with all load balancers

  foreach($LB_IPAddress in $LB_IPAddresses) {
     $LB_IPAddress=$LB_IPAddress.IPAddressToString

     echo "----------------- $LB_IPAddress --------------"
     try
     {
          $LB_IPAddress_Host=([System.Net.Dns]::GetHostByAddress($LB_IPAddress)).Hostname
          echo "LB_IPAddress_Host: $LB_IPAddress_Host"

          if ($LB_IPAddress_Host -match "^ec2.*amazonaws.com$")
          {
              $LB_IPAddress_New=(([System.Net.Dns]::GetHostByName($LB_IPAddress_Host)).AddressList | select IPAddressToString).IPAddressToString
              echo "LB_IPAddress_New: $LB_IPAddress_New"

              if ($LB_IPAddress_New -match "^10\.")
              {
                  $LB_IPAddress=(([System.Net.Dns]::GetHostByName($LB_IPAddress_Host)).AddressList | select IPAddressToString).IPAddressToString
                  echo "New LB_IPAddress: $LB_IPAddress"
              }
          }
     }
     catch [Exception]
     {
         Write-Output("{0}, moving on..." -f $_.Exception.Message)
         $Error.Clear()
     }
     Write-Output ">>>>>>>Attaching app to host $LB_IPAddress for backend $env:LB_BACKEND_NAME <<<<<<<<<<<<<<"

     # Run linux_command to register with HAProxy using the ssh client in the RightScale sandbox directory
     Write-Output "linux command: $linux_command"
     ssh -o StrictHostKeyChecking=no -o PasswordAuthentication=no root@$LB_IPAddress -i C:\HAProxy\private.key $linux_command
  }
}

$listener_names = $env:LB_APPLISTENER_NAMES.split(',')
$ports = $env:APP_SERVER_PORTS.split(',')

for ($i = 0; $i -le $listener_names.Length - 1; $i++) {
  register_with_load_balancer $listener_names[$i] $ports[$i]
}

  EOF

  source(script)
end

rightscale_marker :end