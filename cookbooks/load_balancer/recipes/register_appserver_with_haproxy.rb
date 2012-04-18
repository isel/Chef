powershell 'Register app server with HAProxy' do
  parameters (
    {
      'LB_APPLISTENER_NAMES' => node[:load_balancer][:app_listener_names],
      'LB_BACKEND_NAME' => node[:load_balancer][:backend_name],
      'LB_HOSTNAME' => node[:load_balancer][:website_dns],
      'MAX_CONN_PER_SERVER' => node[:load_balancer][:max_connections_per_lb],
      'HEALTH_CHECK_URI' => node[:load_balancer][:health_check_uri],
      'PRIVATE_SSH_KEY' => node[:load_balancer][:private_ssh_key],
      'APP_SERVER_PORTS' => node[:load_balancer][:app_server_ports],
      'OPT_SESSION_STICKINESS' => node[:load_balancer][:session_stickiness]
    }
  )

  script = <<-'EOF'
# Stop and fail script when a command fails
$ErrorActionPreference="Stop"

if(!$env:LB_HOSTNAME)
{
  Write-Host "website_dns is not specified. No load balancer to connect - exiting."
  exit 0
}

function register_with_load_balancer($app_listener_name, $port)
{
  write-output "registering with load balancer ($app_listener_name, $port)"

  mkdir -force C:\HAProxy
  cd c:\HAProxy

  # Get Loadbalancer IP address via reverse DNS lookup
  $LB_IPAddresses = ([System.Net.Dns]::GetHostAddresses($env:LB_HOSTNAME) | Select IPAddressToString)

  echo "----------------- $LB_IPAddress --------------"

  #Create Key File to access HAProxy server
  Set-Content -path "C:\HAProxy\private.key" -value $env:PRIVATE_SSH_KEY

  if ($env:MAX_CONN_PER_SERVER -notmatch "^\d+$"){
     Write-Output "MAX_CONN_PER_SERVER undefined or not an integer, defaulting to 255"
     $env:MAX_CONN_PER_SERVER=255
  }

  $haproxy_script = "/opt/rightscale/lb/bin/haproxy_config_server.rb"

  $arguments = @(
  	"-a add",
  	"-w",
  	"-s $env:LB_BACKEND_NAME",
  	"-l $app_listener_name",
  	"-t $env:RS_PRIVATE_IP`:$port",
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
     try
     {
          $LB_IPAddress_Host=([System.Net.Dns]::GetHostByAddress($LB_IPAddress)).Hostname
          if ($LB_IPAddress_Host -match "^ec2.*amazonaws.com$")
          {
              $LB_IPAddress_New=(([System.Net.Dns]::GetHostByName($LB_IPAddress_Host)).AddressList | select IPAddressToString).IPAddressToString
              if ($LB_IPAddress_New -match "^10\.")
              {
                  $LB_IPAddress=(([System.Net.Dns]::GetHostByName($LB_IPAddress_Host)).AddressList | select IPAddressToString).IPAddressToString
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