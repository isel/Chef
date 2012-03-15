ruby_scripts_dir = node['ruby_scripts_dir']
deploy_scripts_dir = node['deploy_scripts_dir']

# Install the Mule_ESB
version = node[:deploy][:mule_version]

# TODO detect maven
# maven2 installs java runtime
# may need to remove sun java6
# due to errors
# https://jira.appcelerator.org/browse/APSTUD-3609
# http://stackoverflow.com/questions/1359708/problem-using-log4j-with-axis2
bash 'install mule prerequisites' do
    code <<-EOF
    apt-get -yqq install openjdk-6-jre
    java -version
    mkdir ~/.m2
    apt-get -yqq install maven2
    mvn  --version
    apt-get -yqq install tomcat6
  EOF
end
# openjdk

# need to do it once
bash 'add setting to system profile' do
    code <<-EOCODE
  cat<<EOF>>/etc/bash.bashrc
  export MULE_HOME=/opt/mule
  export JAVA_HOME=/usr/lib/jvm/java-6-openjdk/jre
  export MAVEN_HOME=/usr/share/maven2
  export MAVEN_OPTS=\'-Xmx512m -XX:MaxPermSize=256m\'
  export PATH=\\\$PATH:\\\$MULE_HOME/bin:\\\$JAVA_HOME/bin
EOF
EOCODE
end
# TODO -  detect version file
# NOTE: mule is 180MB
if !File.exists?('/opt/mule/bin')
  bash 'install mule' do
    code <<-EOF
    mkdir -p ~/Installs
    cd ~/Installs
    # initial version - upload 200 MB from the web
    wget -q http://s3.amazonaws.com/MuleEE/mule-ee-distribution-standalone-mmc-#{version}.tar.gz
    tar xf mule-ee-distribution-standalone-mmc-#{version}.tar.gz
    mkdir /opt/mule
    pushd /opt/mule
    cp -R ~/Installs/mule-enterprise-standalone-#{version}/* .
    chmod -R 777 .
  EOF
end
else
  log 'Mule already installed.'
end
# source bash.bashrc does not seem to work yet.
# may need to run the resolvelink.sh
# script to trouble shoot multiple java and log4j
#
if !File.exists?('/root/.m2/org/mule/mule/#{version}/mule-#{version}.pom')
bash 'populate maven repositories' do
    code <<-EOF
    cd /opt/mule/bin
    export LANG=en_US.UTF-8
    export MULE_HOME=/opt/mule
    export JAVA_HOME=/usr/lib/jvm/java-6-openjdk/jre
    export MAVEN_HOME=/usr/share/maven2
    export MAVEN_OPTS='-Xmx512m -XX:MaxPermSize=256m'
    export PATH=\$PATH:\$MULE_HOME/bin:\$JAVA_HOME/bin
    if [ -x populate_m2_repo ] ; then
      ./populate_m2_repo ~/.m2
    fi
EOF
end
else
  log 'maven repositories already populated.'
end
