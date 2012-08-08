bash 'launch activeMQ' do
  code <<-EOF
  pushd /opt/activemq/bin
  /usr/bin/nohup ./activemq start > /var/log/smlog 2>&1 &
  EOF
end

bash 'verify the launch of activemq' do
  code <<-EOF
  LAST_RETRY=0
  RETRY_CNT=20
  STATUS=
  echo 'waiting for achiveMQ to become available on port #{node[:activemq_port]}'
  while  [ "-$STATUS" = '-' ] ; do
    STATUS=`netstat -an | grep :#{node[:activemq_port]}`
    RETRY_CNT=`expr $RETRY_CNT - 1`
    if [ "$RETRY_CNT" -eq "$LAST_RETRY" ] ; then
       echo "Exhausted retries"
       exit 1
    fi
    echo "Retries left: $RETRY_CNT"
    sleep 4
  done
  EOF
end

