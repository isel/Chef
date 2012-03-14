ruby_scripts_dir = node['ruby_scripts_dir']
deploy_scripts_dir = node['deploy_scripts_dir']

# Install the Mule_ESB
version = node[:deploy][:mule_version]

# TODO detect maven
# maven2 installs java runtime
bash 'install maven' do
    code <<-EOF
    mkdir ~/.m2
    sudo apt-get -y install maven2
    java -version
    mvn  --version
    sudo apt-get -y install tomcat6
  EOF
done
# openjdk

# need to do it once
bash 'add setting to system profile' do
    code <<-EOCODE
  echo export MULE_HOME=/opt/mule>>/etc/bash.bashrc
  echo export JAVA_HOME=/usr/lib/jvm/java-6-openjdk>>/etc/bash.bashrc
  echo export MAVEN_HOME=/usr/share/maven2>>/etc/bash.bashrc
  echo export MAVEN_OPTS=\'-Xmx512m -XX:MaxPermSize=256m\'>>/etc/bash.bashrc
  echo export PATH=\$PATH:\$MULE_HOME/bin:\$JAVA_HOME/bin>>/etc/bash.bashrc
EOF
EOCODE
end
# TODO -  detect version file
# NOTE: mule is 180MB
if !File.exists?('/opt/mule/bin')
bash 'install mule' do
   code <<-EOF
   mkdir ~/Installs
   cd ~/Installs
   # initial version - upload 200 MB from the web
   wget http://s3.amazonaws.com/MuleEE/mule-ee-distribution-standalone-mmc-#{version}.tar.gz
   tar xf mule-ee-distribution-standalone-mmc-#{version}.tar.gz
   mkdir /opt/mule
   pushd /opt/mule
   cp -r ~/Installs/mule-enterprise-standalone-#{version}/* .
   chmod -R 777 .
   EOF
end
else
  log 'Mule already installed.'
end
# source bash.bashrc
# is populate_m2_repo idempotent ? - NO  - subsequent runs still take  3 minute user time
# one can check for the presence of
# /root/.m2/org/mule/mule/3.2.1/mule-3.2.1.pom

if !File.exists?('/root/.m2/org/mule/mule/#{version}/mule-#{version}.pom')
bash 'populate maven repositories' do
    code <<-EOF
    cd /opt/mule/bin
    . /etc/bash.bashrc
    if [ -x populate_m2_repo ] ; then
      ./populate_m2_repo ~/.m2
    fi
EOF
end
else
  log 'maven repositories already populated.'
end

# the script may fail with
# jar hell error with log4j
# http://stackoverflow.com/questions/1359708/problem-using-log4j-with-axis2
#
#
#  /opt/mule/lib/boot/log4j-1.2.14.jar
#  /opt/mule/apps/mmc/webapps/mmc/WEB-INF/lib/slf4j-log4j12-1.5.6.jar
#  /opt/mule/apps/mmc/webapps/mmc/WEB-INF/lib/log4j-1.2.13.jar
#  /opt/ElasticSearch/elasticsearch-0.17.6/lib/log4j-1.2.16.jar
#
# and other errors

bash 'launch mule' do
      code <<-EOF
      cd /opt/mule/bin
      . /etc/bash.bashrc
      if [ -x mule ] ; then
        ./mule
      fi
      wget -O /dev/null http://node['ipaddress']:8585/mmc
  EOF
end
