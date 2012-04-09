powershell 'Register app server with HAProxy' do
  parameters (
    {
      'LB_APPLISTENER_NAME' => node[:deploy][:app_listener_name], #api, api81, api82
      'LB_BACKEND_NAME' => node[:deploy][:backend_name], #env:RS_INSTANCE_UUID
      'LB_HOSTNAME' => node[:deploy][:dns_name], #api.globalincite.info
      'MAX_CONN_PER_SERVER' => node[:deploy][:max_connections_per_lb], #255
      'HEALTH_CHECK_URI' => node[:deploy][:health_check_uri], #/HealthCheck.html
      'PRIVATE_SSH_KEY' => node[:deploy][:private_ssh_key],
      'WEB_SERVER_PORT' => node[:deploy][:web_server_port],
      'OPT_SESSION_STICKINESS' => node[:deploy][:session_stickiness]
    }
  )

  script = <<-'EOF'
# Powershell 2.0
# Copyright (c) 2008-2011 RightScale, Inc, All Rights Reserved Worldwide.

# Powershell script compatible with RightLink v5.6+ enabled images
# Create folder to house scripts require to registry with HAProxy

# Contacts and configures an HAProxy server for user with a generic apache application
# LB_APPLISTENER_NAME -- specifies which HAProxy server pool to use
# LB_BACKEND_NAME -- A unique name for each back end e.g. (RS_INSTANCE_UUID)
# LB_HOSTNAME -- DNS name of the front ends
# MAX_CONN_PER_SERVER -- Maximum number of connections per server
# HEALTH_CHECK_URI --

# Stop and fail script when a command fails
$ErrorActionPreference="Stop"


if(!$env:LB_HOSTNAME)
{
  Write-Host "LB_HOSTNAME is not specified. No load balancer to connect - exiting."
  exit 0
}

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
	"-l $env:LB_APPLISTENER_NAME",
	"-t $env:RS_PRIVATE_IP`:$env:WEB_SERVER_PORT",
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
  EOF

  source(script)
end