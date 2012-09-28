powershell "Install AppFabric" do
  powershell_script = <<'POWERSHELL_SCRIPT'
    if (Test-Path "$env:windir\system32\AppFabric")
    {
      Write-Output 'AppFabric already installed'
      exit 0
    }

    cd "c:\installs"
    cmd /c "c:\installs\WindowsServerAppFabricSetup_x64_6.1.exe /i /SkipUpdates /l c:\installs\appfabric.log"
    cmd /c "sc config AppFabricWorkflowManagementService start= disabled"
POWERSHELL_SCRIPT
  source(powershell_script)
end

