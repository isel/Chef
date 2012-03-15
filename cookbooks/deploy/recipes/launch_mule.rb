ipaddress = node['ipaddress']
ulimit_files = node[:deploy][:ulimit_files]

bash 'launch mule' do
      code <<-EOF
      cd /opt/mule/bin
      source /etc/bash.bashrc
      export LANG=en_US.UTF-8
      export MULE_HOME=/opt/mule
      export JAVA_HOME=/usr/lib/jvm/java-6-openjdk/jre
      export MAVEN_HOME=/usr/share/maven2
      export MAVEN_OPTS='-Xmx512m -XX:MaxPermSize=256m'
      export PATH=\$PATH:\$MULE_HOME/bin:\$JAVA_HOME/bin
      ulimit -n #{ulimit_files}
      if [ -x mule ] ; then
        /usr/bin/nohup ./mule > /var/log/mule 2>&1 &
      fi
      HTTP_STATUS=`curl --write-out %{http_code} --silent --output /dev/null  http://#{ipaddress}:8585/mmc`
      if [ $HTTP_STATUS -ne 302 ] ; then
        echo "Unexpected Mule response HTTP STATUS $HTTP_STATUS != 302 ()Found)"
        exit 1
      fi

  EOF
end
