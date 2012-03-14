ruby_scripts_dir = node['ruby_scripts_dir']
deploy_scripts_dir = node['deploy_scripts_dir']

version = node[:deploy][:activemq_version]

bash 'download ActiveMQ' do
  code <<-EOF
  mkdir ~/Installs
  cd ~/Installs
  wget http://apache.mirrors.redwire.net/activemq/apache-activemq/#{version}/apache-activemq-#{version}-bin.tar.gz
  tar xf apache-activemq-#{version}-bin.tar.gz
  mkdir /opt/activemq
  pushd /opt/activemq
  cp -r ~/Installs/apache-activemq-#{version}/* .
  chmod -R 777 .
EOF
end
bash 'launch ActiveMQ' do
  code <<-EOF
  pushd /opt/activemq/bin
  nohup ./activemq start > /var/log/smlog 2>&1 &
  netstat -an | grep :61616
EOF
