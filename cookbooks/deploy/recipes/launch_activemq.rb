bash 'launch activeMQ' do
  code <<-'EOF'
  pushd /opt/activemq/bin
  /usr/bin/nohup ./activemq start > /var/log/smlog 2>&1 &
  STATUS=
  while  [  "-$STATUS" = '-' ] ; do
    STATUS=`netstat -an | grep :61616`
    echo 'waiting for achiveMQ to become available on port 61616'
    sleep 4
  done

EOF
end
log 'launched activeMQ'