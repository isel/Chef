# Install the Mule_ESB
require 'fileutils'
require 'yaml'

version = node[:deploy][:mule_version]
ruby_scripts_dir = node['ruby_scripts_dir']
product = 'mule'
mule_home = "/opt/#{product}"
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

local_filename = "/etc/bash.bashrc"
f = File.open(local_filename, 'r+'); contents = f.read; f.close
append_contents = <<-EOF
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
vendor_download = false

if !File.exists?("#{mule_home}/bin")
  if vendor_download
  bash "Download #{product} from vendor site" do
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
  else
  log "Download #{product} from s3"

  puts "Processing template " + File.join(File.dirname(__FILE__), '/scripts/download_vendor_drop.erb' )
template "#{ruby_scripts_dir}/download_vendor_drop.rb" do
  source 'scripts/download_vendor_drop.erb'
  variables(
    :aws_access_key_id => node[:deploy][:aws_access_key_id],
    :aws_secret_access_key => node[:deploy][:aws_secret_access_key],
    :product => product,
    :version => version,
    :filelist => 'mule',
    :deploy_folder => '/opt'
  )
end

bash 'Downloading artifacts' do
  code <<-EOF
    ruby #{ruby_scripts_dir}/download_vendor_drop.rb
  EOF
end

  bash 'Setting directory links' do
    code <<-EOF
    pushd /opt
    if [ -d  "mule-enterprise-standalone-#{version}" ] ; then
      ln -s mule-enterprise-standalone-#{version} #{product}
    fi
    pushd "#{product}"
    chmod -R 777 .
    if [ ! -f /opt/#{product}/bin/#{product} ] ; then
      exit 1
    fi
  EOF
  end
  log 'Mule service is installed'
end
log 'download configurations'

template "#{ruby_scripts_dir}/download_configurations.rb" do
  source 'scripts/download_artifacts.erb'
  variables(
    :aws_access_key_id => node[:deploy][:aws_access_key_id],
    :aws_secret_access_key => node[:deploy][:aws_secret_access_key],
    :artifacts => 'configuration',
    :target_directory => configuration_dir,
    :revision => '27441.9',
    :s3_bucket => node[:deploy][:s3_bucket],
    :s3_repository => node[:deploy][:s3_repository],
    :s3_directory => 'configurations'
  )
end

bash 'Downloading artifacts' do
    code <<-EOF
      ruby #{ruby_scripts_dir}/download_configurations.rb
    EOF
end


  bash 'Patch Mule configuration wrapper.conf' do
    # patch wrapper.conf from embedded unified diff
    # warning ruby may corrupt certain inputs.
    # review the patch file before commit
    # note that the options are added commented, due to the conflicting options
    # present in wrapper-additional.conf
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
  +#wrapper.java.additional.4=-Xdebug
   #wrapper.java.additional.<n>=-Xnoagent
   #wrapper.java.additional.<n>=-Djava.compiler=NONE
  -#wrapper.java.additional.<n>=-Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005
  +#wrapper.java.additional.5=-Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005

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
    echo "Save updates"
    mv wrapper.conf.orig wrapper.conf
    if [ $VERBOSE != "0" ] ; then
      diff -u wrapper.conf.saved wrapper.conf
    fi
  else
    echo 'Detected that patch already applied'
    mv wrapper.conf.saved wrapper.conf
  fi
  set -e
  rm $PATCH_FILE
  popd
    EOF
  end
  log 'Mule wrapper configuration updated.'

  # add directory to store ultimate.configuration and log4j.configuration files
  custom_configuration_dir="#{mule_home}/#{configuration_dir}"

  if !File.exists?(custom_configuration_dir)
 #    Dir.mkdir(custom_configuration_dir, 0777)
    bash "added custom configuration directory #{custom_configuration_dir}." do
      code <<-EOF
      #!/bin/bash
      mkdir -p -m 0777 #{custom_configuration_dir}
    EOF
    end
  end

else
  log 'Mule already installed.'
end

# source bash.bashrc does not seem to work, not using it.

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

=begin

# verify the command line flags.
# detect if debug flag passed by the launcher

cp=.:$MULE_HOME/conf:$groovyJar:$commonsCliJar:$muleModuleLoggingJar:$log4jJar

JPDA_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,address=5005"

# The string passed to eval must handle spaces in paths correctly.
COMMAND_LINE="\"${JAVA}\" $JPDA_OPTS -Dmule.home=\"$MULE_HOME\" -Djava.endorsed.dirs=\"$MULE_HOME/lib/endorsed\" -cp \"$cp\" org.codehaus.groovy.tools.GroovyStarter --main groovy.ui.GroovyMain --conf \"$MULE_HOME/bin/launcher.conf\" $@"
COMMAND_LINE="\"${JAVA}\"            -Dmule.home=\"$MULE_HOME\" -Djava.endorsed.dirs=\"$MULE_HOME/lib/endorsed\" -cp \"$cp\" org.codehaus.groovy.tools.GroovyStarter --main groovy.ui.GroovyMain --conf \"$MULE_HOME/bin/launcher.conf\" $@"
eval $COMMAND_LINE

=end