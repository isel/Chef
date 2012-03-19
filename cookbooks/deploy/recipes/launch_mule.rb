
ipaddress = node['ipaddress']
ulimit_files = node[:deploy][:ulimit_files]
mule_port = node[:deploy][:mule_port]
verify_completion = node[:deploy][:verify_completion]
sleep_interval = 10

bash 'launch mule' do
      code <<-EOF
      cd /opt/mule/bin
      export LANG=en_US.UTF-8
      export MULE_HOME=/opt/mule
      export JAVA_HOME=/usr/lib/jvm/java-6-openjdk/jre
      export MAVEN_HOME=/usr/share/maven2
      export MAVEN_OPTS='-Xmx512m -XX:MaxPermSize=256m'
      export PATH=$PATH:$MULE_HOME/bin:$JAVA_HOME/bin
      ulimit -n #{ulimit_files}
      if [ -x mule ] ; then
        /usr/bin/nohup ./mule start
      fi
  EOF
end
if verify_completion
  bash 'verify the launch of mule' do
    code <<-EOF
    LAST_RETRY=0
    RETRY_CNT=20
    HTTP_STATUS=0
    RESULT=1
    echo 'waiting for mule to be serving HTTP on #{mule_port}'
    while  [ "$RESULT" -ne "0" ] ; do
      HTTP_STATUS=`curl --write-out %{http_code} --silent --output /dev/null  http://#{ipaddress}:#{mule_port}/mmc`
      expr $HTTP_STATUS : '302\|200' > /dev/null
      RESULT=$?
      echo "get HTTP status code $HTTP_STATUS"
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
log 'mule successfully launched'

