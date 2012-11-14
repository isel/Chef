rightscale_marker :begin

powershell 'Enable MSMQ' do
  parameters ({ 'SERVER_MANAGER_FEATURES' => node[:msmq_features] })
  powershell_script = <<-'EOF'
    Import-Module ServerManager
    $features_array = $Env:SERVER_MANAGER_FEATURES -split ','

    foreach ($feature in $features_array)
    {
      $check = Get-WindowsFeature -name $feature
      if ($check -ne $null  ) {
        if ($check.Installed -ne $True ) {
          write-output  "Installing feature ${feature}"
          Add-WindowsFeature -name $feature
        }
        else {
          write-output "Feature ${feature} already installed "
        }
      }
      else {
        write-output  "Unknown feature ${feature}"
      }
    }

    $Error.clear()
  EOF
  source(powershell_script)
end

rightscale_marker :end