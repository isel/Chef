include_recipe 'core::download_vendor_artifacts_prereqs'

template('/installs/set_password_to_not_expire.bat') { source 'set_password_to_not_expire.erb' }

template "#{node['ruby_scripts_dir']}/download_appfabric.rb" do
  local true
  source "#{node['ruby_scripts_dir']}/download_vendor_artifacts.erb"
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :s3_bucket => node[:core][:s3_bucket],
    :s3_repository => 'Vendor',
    :product => 'appfabric',
    :version => '6.1',
    :artifacts => 'appfabric',
    :target_directory => '/installs',
    :unzip => true
  )
  not_if { File.exist?('/installs/WindowsServerAppFabricSetup_x64_6.1.exe') }
end

powershell 'Download AppFabric' do
  source("ruby #{node['ruby_scripts_dir']}/download_appfabric.rb")
  not_if { File.exist?('/installs/WindowsServerAppFabricSetup_x64_6.1.exe') }
end

template "#{node['ruby_scripts_dir']}/download_appfabric_admin_tool.rb" do
  local true
  source "#{node['ruby_scripts_dir']}/download_vendor_artifacts.erb"
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :s3_bucket => node[:core][:s3_bucket],
    :s3_repository => 'Vendor',
    :product => 'appfabric',
    :version => '6.1',
    :artifacts => 'appfabricadmintool',
    :target_directory => '/appfabric_caching_admin',
    :unzip => true
  )
  not_if { File.exist?('/appfabric_caching_admin') }
end

powershell 'Download AppFabric' do
  source("ruby #{node['ruby_scripts_dir']}/download_appfabric.rb")
  not_if { File.exist?('/installs/WindowsServerAppFabricSetup_x64_6.1.exe') }
end

powershell 'Download AppFabric Admin Tool' do
  source("ruby #{node['ruby_scripts_dir']}/download_appfabric_admin_tool.rb")
  not_if { File.exist?('/appfabric_caching_admin') }
end

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

