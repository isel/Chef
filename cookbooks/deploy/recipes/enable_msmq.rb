powershell 'Enable MSMQ' do
  parameters (
    {
      'SERVER_MANAGER_FEATURES' => node[:msmq_features]
    }
  )
  powershell_script = <<-'EOF'
   # the script install components in Microsoft recommended way
   # that is only available on  Windows 2008 R2
   # TODO - merge with legacy way (servermanagercmd.exe)

   # http://blogs.msdn.com/b/johnbreakwell/archive/2007/06/19/minimalist-setup-script-for-msmq-unattended-installation.aspx
    Import-Module ServerManager
    $features_array = $Env:SERVER_MANAGER_FEATURES -split ','

    foreach ( $feature in $features_array    )
    {
    $check=Get-WindowsFeature -name $feature
        if ($check -ne $null  ) {
            if ($check.Installed -ne $True ) {
                write-output  "Installing Feature ${feature}"
                Add-WindowsFeature -name $feature
            } else      {
                write-output  "Feature ${feature} Already installed "
                write-output $check.AdditionalInfo  " "  $check.Installed
            }
        } else {
            write-output  "Feature ${feature} is unknown to Windows Server Manager"
        }
    }

    $Error.clear()
  EOF
  source(powershell_script)
end
