include_recipe 'core::download_vendor_artifacts_prereqs'

template "#{node[:ruby_scripts_dir]}/download_ant.rb" do
  local true
  source "#{node[:ruby_scripts_dir]}/download_vendor_artifacts.erb"
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :s3_bucket => node[:core][:s3_bucket],
    :s3_repository => 'Vendor',
    :product => 'ant',
    :version => '1.8.4',
    :artifacts => 'ant',
    :target_directory => '/',
    :unzip => true
  )
  not_if { File.exist?('/ant.zip') }
end

powershell 'Download ant' do
  script = <<EOF
    ruby #{node[:ruby_scripts_dir]}/download_ant.rb
    [System.Environment]::SetEnvironmentVariable('ANT_HOME', 'c:\\ant', 'machine')
EOF
  source(script)
  not_if { File.exist?('/ant.zip') }
end

windows_path 'C:\ant\bin' do
  action :add
end
