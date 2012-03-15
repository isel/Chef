bash 'launch ActiveMQ' do
  code <<-'EOF'
  pushd /opt/activemq/bin
  /usr/bin/nohup ./activemq start > /var/log/smlog 2>&1 &
  netstat -an | grep :61616
EOF
end