#todo: add this recipe to the "Image Application Server" template
powershell 'Enable MSMQ' do
  parameters ({ 'SERVER_MANAGER_FEATURES' => node[:msmq_features] })
  powershell_script = <<-'EOF'
# as long as this is a constant, we can break on the first discovery of an installed component
# also try removing the additionalinfo check and see if it is costing us time
# move recipe below installing ruby gems

    Import-Module ServerManager
    $features_array = $Env:SERVER_MANAGER_FEATURES -split ','

    foreach ($feature in $features_array)
    {
      $check = Get-WindowsFeature -name $feature
      if ($check -ne $null  ) {
        if ($check.Installed -ne $True ) {
          write-output  "Installing feature ${feature}"
          Add-WindowsFeature -name $feature
        } else {
            write-output "Feature ${feature} already installed "
        }
      } else {
          write-output  "Feature ${feature} is unknown to Windows Server Manager"
      }
    }

    $Error.clear()
  EOF
  source(powershell_script)
end
