ruby_scripts_dir = node['ruby_scripts_dir']
deploy_scripts_dir = node['deploy_scripts_dir']

version = node[:deploy][:activemq_version]

bash 'install ActiveMQ' do
  code <<-EOF
  mkdir -p ~/Installs
  cd ~/Installs
  wget --quiet http://apache.mirrors.redwire.net/activemq/apache-activemq/#{version}/apache-activemq-#{version}-bin.tar.gz
  tar xf apache-activemq-#{version}-bin.tar.gz
  mkdir -p /opt/activemq
  pushd /opt/activemq
  cp -R ~/Installs/apache-activemq-#{version}/* .
  chmod -R 777 .
  if [ ! -f /opt/activemq/bin/activemq ]
  then
    exit 1
  fi
EOF
  log 'activemq successgully launched'
end

