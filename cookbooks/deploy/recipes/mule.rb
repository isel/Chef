# Install the Mule_ESB

version = node[:deploy][:mule_version]
mule_home = '/opt/mule'
# directory where developer or build copies the configurations
# /svn/ugf/trunk/Foundation/Java/events/configuration.
configuration_dir = 'configuration'
# apt-get detects if debian package is already installed - no need to replicate its functionality
# may need to remove sun java6
bash 'install mule prerequisites' do
  code <<-EOF
    export DEBIAN_FRONTEND=noninteractive
    apt-get -yqq install openjdk-6-jre
    java -version
    mkdir -p ~/.m2
    apt-get -yqq install maven2
    mvn --version
    apt-get -yqq install tomcat6
  EOF
end

local_filename = '/etc/bash.bashrc'
f = File.open(local_filename, 'r+'); contents = f.read; f.close
append_contents = <<-'EOF'
export LANG=en_US.UTF-8
export MULE_HOME=#{mule_home}
export JAVA_HOME=/usr/lib/jvm/java-6-openjdk/jre
export MAVEN_HOME=/usr/share/maven2
export MAVEN_OPTS='-Xmx512m -XX:MaxPermSize=256m'
export PATH=$PATH:$MULE_HOME/bin:$JAVA_HOME/bin
EOF

special_chars = %r{
    ([\[$@\\\]])
    }x

append_contents.split(/\n/).each do |entry|
  check_entry = entry.gsub(special_chars) { '\\' + $1 }
  puts "probing #{check_entry}" if $DEBUG
  if contents !~ Regexp.new(check_entry)
    puts "need to append #{entry}" if $DEBUG
    contents += entry + "\n"
  end
end

File.open(local_filename, 'r+') { |f| f.puts contents }

log 'bash profile updated.'


if !File.exists?("#{mule_home}/bin")
  bash 'install mule' do
    code <<-EOF
    mkdir -p ~/Installs
    cd ~/Installs
    # initial version - upload 200 MB from the web
    wget -q http://s3.amazonaws.com/MuleEE/mule-ee-distribution-standalone-mmc-#{version}.tar.gz
    tar xf mule-ee-distribution-standalone-mmc-#{version}.tar.gz
    mkdir -p #{mule_home}
    pushd #{mule_home}
    cp -R ~/Installs/mule-enterprise-standalone-#{version}/* .
    chmod -R 777 .
    EOF
  end
  log 'Mule service is installed'
else
  log 'Mule already installed.'
end

# source bash.bashrc does not seem to work, not used.

log "Checking project [/root/.m2/org/mule/mule/#{version}/mule-#{version}.pom]."

if !File.exists?("/root/.m2/org/mule/mule/#{version}/mule-#{version}.pom")

  bash 'populate maven repositories' do
    code <<-EOF
    cd #{mule_home}/bin
    export LANG=en_US.UTF-8
    export MULE_HOME=#{mule_home}
    export JAVA_HOME=/usr/lib/jvm/java-6-openjdk/jre
    export MAVEN_HOME=/usr/share/maven2
    export MAVEN_OPTS='-Xmx512m -XX:MaxPermSize=256m'
    export PATH=$PATH:$MULE_HOME/bin:$JAVA_HOME/bin
    LOG_FILE=/tmp/populate_m2_repo.log.$$
    if [ -x populate_m2_repo ] ; then
      ./populate_m2_repo ~/.m2 > $LOG_FILE 2>&1
    fi
    echo "Saving maven logs to a file, please wait..."
    if [ -f $LOG_FILE ] ; then
      echo "Tail of the maven log $LOG_FILE"
      /usr/bin/tail -10 $LOG_FILE
    else
      echo "No log file, aborting"
      exit 1
    fi
    exit 0
    EOF
  end
  log 'maven repositories successfully populated.'
else
  log 'maven repositories already populated.'
end

bash 'Patch Mule configuration wrapper.conf' do
  # patch wrapper.conf from embedded unified diff
  # warning ruby corrupting certain inputs.

  code <<-EOF
#!/bin/bash
PATCH_FILE="/tmp/wrapper.conf.patch.$$"
VERBOSE=${1:-0}
echo VERBOSE=$VERBOSE
cat <<WRAPPER_CONF_PATCH > $PATCH_FILE
--- wrapper.conf.orig
+++ wrapper.conf
@@ -30,10 +30,10 @@
 #wrapper.java.additional.<n>=-Dmule.verbose.exceptions=true

 # Debug remotely, the application will wait for the external debugger to connect.
-#wrapper.java.additional.<n>=-Xdebug
+wrapper.java.additional.4=-Xdebug
 #wrapper.java.additional.<n>=-Xnoagent
 #wrapper.java.additional.<n>=-Djava.compiler=NONE
-#wrapper.java.additional.<n>=-Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005
+wrapper.java.additional.5=-Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005

 # Specify an HTTP proxy if you are behind a firewall.
 #wrapper.java.additional.<n>=-Dhttp.proxyHost=YOUR_HOST
@@ -88,6 +88,7 @@
 wrapper.java.classpath.1=%MULE_LIB%
 wrapper.java.classpath.2=%MULE_BASE%/conf
 wrapper.java.classpath.3=%MULE_HOME%/lib/boot/*.jar
+wrapper.java.classpath.4=%MULE_HOME%/#{configuration_dir}

 # Java Native Library Path (location of .DLL or .so files)
 wrapper.java.library.path.1=%LD_LIBRARY_PATH%
@@ -200,3 +201,5 @@
 # This include should point to wrapper-additional.conf file in the same directory as this file
 # ATTENTION: Path must be either absolute or relative to wrapper executable.
 #include %MULE_BASE%/conf/wrapper-additional.conf
+
+
WRAPPER_CONF_PATCH
# the updates to wrapper conf applied from the patch file, not direct edit
#
pushd #{mule_home}/conf
cp wrapper.conf wrapper.conf.orig
mv wrapper.conf wrapper.conf.saved
set +e
# force, but assume unreversed.
echo "applying the patch $PATCH_FILE and if rejected, keep the saved configuration"
if [ $VERBOSE == "0" ] ; then
QUIET=-s
else
QUIET=
fi
patch -p0 $QUIET -f < $PATCH_FILE
if  [ "$?"  == "0" ] ; then
  echo "save updates"
  mv wrapper.conf.orig wrapper.conf
  if [ $VERBOSE != "0" ] ; then
    diff -u wrapper.conf.saved wrapper.conf
  fi
else
  echo "detected already applied patch"
  mv wrapper.conf.saved wrapper.conf
fi
set -e
# rm $PATCH_FILE
popd
  EOF
end
log 'configuration updated.'


# add directory to store ultimate.configuration and log4j.configuration files
custom_configuration_dir="#{mule_home}/#{configuration_dir}"

if !File.exists?(custom_configuration_dir)
  log "added custom configuration directory #{custom_configuration_dir}."
  Dir.mkdir(custom_configuration_dir, 0777)
end

=begin
# add debug flag to launcher

cp=.:$MULE_HOME/conf:$groovyJar:$commonsCliJar:$muleModuleLoggingJar:$log4jJar

JPDA_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,address=5005"

# The string passed to eval must handle spaces in paths correctly.
COMMAND_LINE="\"${JAVA}\" $JPDA_OPTS -Dmule.home=\"$MULE_HOME\" -Djava.endorsed.dirs=\"$MULE_HOME/lib/endorsed\" -cp \"$cp\" org.codehaus.groovy.tools.GroovyStarter --main groovy.ui.GroovyMain --conf \"$MULE_HOME/bin/launcher.conf\" $@"
COMMAND_LINE="\"${JAVA}\"            -Dmule.home=\"$MULE_HOME\" -Djava.endorsed.dirs=\"$MULE_HOME/lib/endorsed\" -cp \"$cp\" org.codehaus.groovy.tools.GroovyStarter --main groovy.ui.GroovyMain --conf \"$MULE_HOME/bin/launcher.conf\" $@"
eval $COMMAND_LINE

=end