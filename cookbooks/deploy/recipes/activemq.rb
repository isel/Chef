ruby_scripts_dir = node['ruby_scripts_dir']
version  = node[:deploy][:activemq_version]
template "#{ruby_scripts_dir}/download_vendor_drop.rb" do
  source 'scripts/download_vendor_drop.erb'
  variables(
    :aws_access_key_id => node[:deploy][:aws_access_key_id],
    :aws_secret_access_key => node[:deploy][:aws_secret_access_key],
    :product => 'activemq',
    :version => version,
    :filelist => 'activemq',
    :no_explode => '0'
  )
end

bash 'Downloading artifacts' do
  code <<-EOF
    ruby #{ruby_scripts_dir}/download_vendor_drop.rb
  EOF
end

bash 'Setting directory links' do
  code <<-EOF
  pushd /opt
  ln -s apache-activemq-#{version} activemq
  pushd activemq
  chmod -R 777 .
  if [ ! -f /opt/activemq/bin/activemq ] ; then
    exit 1
  fi
EOF
end

log 'Activemq successfully installed'
