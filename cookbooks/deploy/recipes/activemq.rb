include_recipe 'core::download_vendor_artifacts_prereqs'

product = 'activemq'

if File.exists?("/opt/#{product}")
  log "#{product} is already installed"
else
  template "#{node['ruby_scripts_dir']}/download_#{product}.rb" do
    local true
    source "#{node['ruby_scripts_dir']}/download_vendor_artifacts.erb"
    variables(
      :aws_access_key_id => node[:core][:aws_access_key_id],
        :aws_secret_access_key => node[:core][:aws_secret_access_key],
        :s3_bucket => node[:core][:s3_bucket],
        :s3_repository => 'Vendor',
        :product => product,
        :version => node[:activemq_version],
        :artifacts => product,
        :target_directory => '/opt',
        :unzip => true
    )
  end

  bash "Downloading #{product}" do
    code <<-EOF
      ruby #{node['ruby_scripts_dir']}/download_#{product}.rb
    EOF
  end

  bash 'Setting application permissions' do
    code <<-EOF
      cd /opt/#{product}
      chmod -R 777 .
    EOF
  end

  log "#{product} successfully installed"
end

bash 'launch activemq' do
  code <<-EOF
  cd /opt/activemq/bin
  /usr/bin/nohup ./activemq start > /var/log/smlog 2>&1 &
  EOF
end

template "#{node['ruby_scripts_dir']}/wait_for_activemq.rb" do
  source 'scripts/wait_for_activemq.erb'
end

bash 'wait for activemq' do
  code "ruby #{node['ruby_scripts_dir']}/wait_for_activemq.rb"
end



