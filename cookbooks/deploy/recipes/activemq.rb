include_recipe 'core::download_vendor_artifacts_prereqs'

version  = node[:deploy][:activemq_version]
product = 'activemq'

if !File.exists?("/opt/#{product}")
  template "#{node['ruby_scripts_dir']}/download_#{product}.rb" do
    local true
    source "#{node['ruby_scripts_dir']}/download_vendor_artifacts.erb"
    variables(
      :aws_access_key_id => node[:core][:aws_access_key_id],
      :aws_secret_access_key => node[:core][:aws_secret_access_key],
      :s3_bucket => node[:core][:s3_bucket],
      :s3_repository => 'Vendor',
      :product => product,
      :version => version,
      :artifacts => product,
      :target_directory => "/opt/#{product}"
    )
  end

  bash "Downloading #{product}" do
    code <<-EOF
      ruby #{node['ruby_scripts_dir']}/download_#{product}.rb
    EOF
  end

  bash 'Setting application permissions' do
    code <<-EOF
      # pushd /opt
      # if [ -d  "apache-activemq-#{version}" ] ; then
      #  ln -s apache-activemq-#{version} #{product}
      # fi

      cd /opt/#{product}
      chmod -R 777 .

      # if [ ! -f /opt/activemq/bin/activemq ] ; then
      #  exit 1
      # fi
    EOF
  end

  log "#{product} successfully installed"
else
  log "#{product} is already installed"
end

