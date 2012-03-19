activemq_port = node[:deploy][:activemq_port]
verify_completion = node[:deploy][:verify_completion]
sleep_interval = 4
bash 'launch activeMQ' do
  code <<-EOF
  pushd /opt/activemq/bin
  /usr/bin/nohup ./activemq start > /var/log/smlog 2>&1 &
  EOF
end

if !verify_completion.nil? && verify_completion != ''
  bash 'verify the launch of activemq' do
  code <<-EOF
  LAST_RETRY=0
  RETRY_CNT=20
  STATUS=
  echo 'waiting for achiveMQ to become available on port #{activemq_port}'
  while  [ "-$STATUS" = '-' ] ; do
    STATUS=`netstat -an | grep :#{activemq_port}`
    RETRY_CNT=`expr $RETRY_CNT - 1`
    if [ "$RETRY_CNT" -eq "$LAST_RETRY" ] ; then
       echo "Exhausted retries"
       exit 1
    fi
    echo "Retries left: $RETRY_CNT"
    sleep #{sleep_interval}
  done
  EOF
  end
end
log 'launched activeMQ'