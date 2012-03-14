# source does not seem to work, removed

bash 'launch mule' do
      code <<-EOF
      cd /opt/mule/bin
      export LANG=en_US.UTF-8
      export MULE_HOME=/opt/mule
      export JAVA_HOME=/usr/lib/jvm/java-6-openjdk
      export MAVEN_HOME=/usr/share/maven2
      export MAVEN_OPTS='-Xmx512m -XX:MaxPermSize=256m'
      export PATH=\$PATH:\$MULE_HOME/bin:\$JAVA_HOME/bin

      if [ -x mule ] ; then
        ./mule
      fi
      wget -O /dev/null http://#{node['ipaddress']}:8585/mmc
  EOF
end
