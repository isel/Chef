ruby_scripts_dir = node['ruby_scripts_dir']
version  = node[:deploy][:activemq_version]
product = 'activemq'

if !File.exists?("/opt/#{product}")
puts "Processing template (need a different path for rvm cookbook) " + File.join(File.dirname(__FILE__), '/scripts/download_vendor_drop.erb' )
template "#{ruby_scripts_dir}/download_vendor_drop.rb" do
  source 'scripts/download_vendor_drop.erb'
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :product => product,
    :version => version,
    :filelist => 'activemq',
    :deploy_folder => '/opt'
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
  if [ -d  "apache-activemq-#{version}" ] ; then
    ln -s apache-activemq-#{version} #{product}
  fi
  pushd "#{product}"
  chmod -R 777 .
  if [ ! -f /opt/activemq/bin/activemq ] ; then
    exit 1
  fi
EOF
end

log 'Activemq successfully installed'
else
  log 'Activemq is already registered.'
end

