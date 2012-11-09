rightscale_marker :begin

raise "Ubuntu not supported" if node[:platform] == "ubuntu"

include_recipe 'core::download_vendor_artifacts_prereqs'

template "#{node[:ruby_scripts_dir]}/download_rsyslog.rb" do
  local true
  source "#{node[:ruby_scripts_dir]}/download_vendor_artifacts.erb"
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :s3_bucket => node[:core][:s3_bucket],
    :s3_repository => 'Vendor',
    :product => 'rsyslog',
    :version => '1.1.120',
    :artifacts => 'rsyslogwa.exe',
    :target_directory => '/installs',
    :unzip => false
  )
  not_if { File.exist?('/installs/rsyslogwa.exe') }
end

powershell 'Install rsyslog' do
  source('c:\\installs\\rsyslogwa.exe -i /S /v /qn')
  not_if { File.exist?("#{ENV['ProgramFiles(x86)']}\\RSyslog\\Agent") }
end

template "#{ENV['ProgramFiles(x86)']}\\RSyslog\\Agent\\settings.xml" do
  source 'settings.erb'
  variables(:remote_log_server => node[:rsyslog][:remote_log_server])
end

powershell 'Install rsyslog' do
  source('c:\\installs\\rsyslogwa.exe -i /S /v /qn')
  not_if { File.exist?("#{ENV['ProgramFiles(x86)']}\\RSyslog\\Agent") }
end

rightscale_marker :end

