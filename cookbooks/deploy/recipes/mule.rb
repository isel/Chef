ruby_scripts_dir = node['ruby_scripts_dir']
deploy_scripts_dir = node['deploy_scripts_dir']

# Install the Mule_ESB
version = node[:deploy][:mule_version]

# TODO detect maven
# maven2 installs java runtime
bash 'install mule prerequisites' do
    code <<-EOF
    mkdir ~/.m2
    sudo apt-get -yqq install maven2
    java -version
    mvn  --version
    sudo apt-get -yqq install tomcat6
  EOF
end
# openjdk

# need to do it once
bash 'add setting to system profile' do
    code <<-EOCODE
  cat<<EOF>>/etc/bash.bashrc
  export MULE_HOME=/opt/mule
  export JAVA_HOME=/usr/lib/jvm/java-6-openjdk
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
# 'source' instruction does not have its effect,
# repeating environment settings.
# removed    . /etc/bash.bashrc
if !File.exists?('/root/.m2/org/mule/mule/#{version}/mule-#{version}.pom')
bash 'populate maven repositories' do
    code <<-EOF
    cd /opt/mule/bin
    export LANG=en_US.UTF-8
    export MULE_HOME=/opt/mule
    export JAVA_HOME=/usr/lib/jvm/java-6-openjdk
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
