include_recipe 'core::download_vendor_artifacts_prereqs'

template "#{node['ruby_scripts_dir']}/download_access_database_engine.rb" do
  local true
  source "#{node['ruby_scripts_dir']}/download_vendor_artifacts.erb"
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :s3_bucket => node[:core][:s3_bucket],
    :s3_repository => 'Vendor',
    :product => 'accessdatabaseengine',
    :version => '14.0',
    :artifacts => 'accessdatabaseengine',
    :target_directory => '/installs',
    :unzip => true
  )
  not_if { File.exist?('/installs/accessdatabaseengine.zip') }
end

powershell 'Download Access Database Engine' do
  source("ruby #{node['ruby_scripts_dir']}/download_access_database_engine.rb")
  not_if { File.exist?('/installs/accessdatabaseengine.zip') }
end

powershell 'Install Access Database Engine' do
  source('cmd /c "/installs/accessdatabaseengine/AccessDatabaseEngine_x64.exe /log:c:\accessdbengine.log /quiet /norestart"')
  not_if { File.exist?('/accessdbengine.log') }
end
