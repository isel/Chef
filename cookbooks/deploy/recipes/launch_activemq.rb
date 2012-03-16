activemq_port = node[:deploy][:activemq_port]
sleep_interval
bash 'launch activeMQ' do
  code <<-'EOF'
  pushd /opt/activemq/bin
  /usr/bin/nohup ./activemq start > /var/log/smlog 2>&1 &
  STATUS=
  while  [  "-$STATUS" = '-' ] ; do
    STATUS=`netstat -an | grep :#{activemq_port}`
    echo 'waiting for achiveMQ to become available on port #{activemq_port}'
    sleep 4
  done

EOF
end
log 'launched activeMQ'