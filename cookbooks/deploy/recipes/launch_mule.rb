ipaddress = node['ipaddress']
ulimit_files = node[:deploy][:ulimit_files]

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
      HTTP_STATUS=0
      while  [ $HTTP_STATUS -ne 302 -a $HTTP_STATUS -ne 200 ] ; do
        # Get HTTP status code with curl in bash
        HTTP_STATUS=`curl --write-out %{http_code} --silent --output /dev/null  http://localhost:8585/mmc`
        echo 'waiting for mule to become running HTTP on 8585'
        echo "get HTTP status code $HTTP_STATUS"
        sleep 10
      done
  EOF
end
log 'mule successfully launched'