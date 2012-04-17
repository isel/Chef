#LB_APPLISTENER_NAME, LB_BACKEND_NAME, LB_HOSTNAME, PRIVATE_SSH_KEY
powershell 'Deregister app server with HAProxy' do
  parameters (
    {
      'LB_APPLISTENER_NAMES' => node[:load_balancer][:app_listener_names],
      'LB_BACKEND_NAME' => node[:load_balancer][:backend_name],
      'LB_HOSTNAME' => node[:load_balancer][:dns_name],
      'PRIVATE_SSH_KEY' => node[:load_balancer][:private_ssh_key]
    }
  )

  script = <<-'EOF'
# Stop and fail script when a command fails
$ErrorActionPreference="Stop"

if(!$env:LB_HOSTNAME)
{
  Write-Host "LB_HOSTNAME is not specified, no need to deregister. Exiting silently..."
  exit 0
}

function deregister_with_load_balancer($app_listener_name)
{
  write-output "deregistering from load balancer ($app_listener_name)"

  mkdir -force C:\HAProxy
  cd c:\HAProxy

  # Get Loadbalancer IP address via reverse DNS lookup
  $LB_IPAddresses = ([System.Net.Dns]::GetHostAddresses($env:LB_HOSTNAME) | Select IPAddressToString)

  echo "----------------- $LB_IPAddress --------------"

  #Create Key File to access HAProxy server
  Set-Content -path "C:\HAProxy\private.key" -value $env:PRIVATE_SSH_KEY

  # Define the path to the haproxy configure script
  $haproxy_script = "/opt/rightscale/lb/bin/haproxy_config_server.rb"

  $arguments = @(
    "-a del",
    "-w",
    "-s $env:LB_BACKEND_NAME",
    "-l $app_listener_name"
  )

  # Join arguments and build linux command
  $arguments = [string]::join(' ',$arguments)
  $linux_command = $haproxy_script + " " + $arguments

  # Escape the quotation marks and wrap the linux command in quotes
  $linux_command = $linux_command.Replace("`"","`"`"")
  $linux_command = "`"$linux_command`""

  # Iterate through each IP address of the load balancer to
  # deregister instance with all load balancers

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
     Write-Output ">>>>>>>Removing app from host $LB_IPAddress <<<<<<<<<<<<<<"

     # Run linux_command to deregister with HAProxy using the ssh client in the RightScale sandbox directory
     ssh -o StrictHostKeyChecking=no -o PasswordAuthentication=no root@$LB_IPAddress -i C:\HAProxy\private.key $linux_command
  }
}

$listener_names = $env:LB_APPLISTENER_NAMES.split(',')

for ($i = 0; $i -le $listener_names.Length - 1; $i++) {
  deregister_with_load_balancer $listener_names[$i]
}

  EOF

  source(script)
end