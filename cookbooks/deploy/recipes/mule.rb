include_recipe 'core::download_vendor_artifacts_prereqs'

# Install the Mule_ESB
require 'fileutils'
require 'yaml'

version = node[:mule_version]
ruby_scripts_dir = node['ruby_scripts_dir']
product = 'mule'
mule_home = "/opt/#{product}"
messaging_server_directory='MessagingServer'
plugin_home = "#{mule_home}/apps"
# shared directory to store ultimate.configuration and log4j.configuration files
# note the change of the name in transit from s3 folder to mule
configuration_dir = 'configuration'
mule_configuration_dir="#{mule_home}/#{configuration_dir}"
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

File.open(local_filename, 'r+') { |file| file.puts contents }

log 'bash profile updated.'

if File.exists?("#{mule_home}/bin")
  log 'Mule already installed.'
else
  log "Download #{product} from s3"

  template "#{node['ruby_scripts_dir']}/download_mule.rb" do
    local true
    source "#{node['ruby_scripts_dir']}/download_vendor_artifacts.erb"
    variables(
      :aws_access_key_id => node[:core][:aws_access_key_id],
        :aws_secret_access_key => node[:core][:aws_secret_access_key],
        :s3_bucket => node[:core][:s3_bucket],
        :s3_repository => 'Vendor',
        :product => product,
        :version => version,
        :artifacts => 'mule',
        :target_directory => '/opt',
        :unzip => true
    )
  end

  bash 'Downloading artifacts' do
    code "ruby #{ruby_scripts_dir}/download_mule.rb"
  end

  bash 'Setting directory links' do
    product_directory="mule-enterprise-standalone-#{version}"
    code <<-EOF
        PRODUCT_DIRECTORY="#{product_directory}"
        pushd /opt
        ls -l .
        set +e
        ls -l #{product}
        set -e
        if [ -L "#{product}" ] ; then
          echo "clearing possibly existing link"
          rm #{product}
        fi
        echo "Probing the directory $PRODUCT_DIRECTORY"

        if [ -d "$PRODUCT_DIRECTORY" ] ; then
          ln -s $PRODUCT_DIRECTORY #{product}
        fi

        pushd "#{product}"
        chmod -R 777 .
        if [ ! -f /opt/#{product}/bin/#{product} ] ; then
          exit 1
        fi
    EOF
  end

  template "#{node['ruby_scripts_dir']}/download_mule_plugins.rb" do
    local true
    source "#{node['ruby_scripts_dir']}/download_vendor_artifacts.erb"
    variables(
      :aws_access_key_id => node[:core][:aws_access_key_id],
        :aws_secret_access_key => node[:core][:aws_secret_access_key],
        :s3_bucket => node[:core][:s3_bucket],
        :s3_repository => 'Vendor',
        :product => product,
        :version => version,
        :artifacts => node[:mule_plugins].join(','),
        :target_directory => "#{mule_home}/apps",
        :unzip => false
    )
  end

  bash 'Downloading mule plugins' do
    code <<-EOF
        ruby #{ruby_scripts_dir}/download_mule_plugins.rb
    EOF
  end

  bash 'Patch Mule configuration wrapper.conf' do
    # patch wrapper.conf from embedded unified diff
    # warning ruby processor may corrupt certain inputs.
    # review the patch file before commit
    # note that few options are added commented, due to the conflicting options
    # observed in wrapper-additional.conf
    code <<-EOF
  #!/bin/bash
  PATCH_FILE="/tmp/wrapper.conf.patch.$$"
  VERBOSE=${1:-0}
  echo VERBOSE=$VERBOSE
  cat <<WRAPPER_CONF_PATCH > $PATCH_FILE
--- wrapper.conf        2012-06-15 20:06:38.000000000 +0000
+++ wrapper.conf.orig   2012-07-11 18:40:29.000000000 +0000
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
@@ -89,6 +89,7 @@
 wrapper.java.classpath.2=%MULE_BASE%/conf
 wrapper.java.classpath.3=%MULE_HOME%/lib/boot/*.jar
 wrapper.java.classpath.4=%MULE_BASE%/data-mapper
+wrapper.java.classpath.5=%MULE_HOME%/#{configuration_dir}

 # Java Native Library Path (location of .DLL or .so files)
 wrapper.java.library.path.1=%LD_LIBRARY_PATH%
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

  bash 'Installing Mule-EE License' do
    code <<-EOF
      cd /opt/mule/bin
      chmod 777 mule
      ./mule -installLicense /opt/mule/mule-ee-license.lic
    EOF
  end

end

# source bash.bashrc does not seem to  produce desired effect -  not using it.

log "Checking project [/root/.m2/org/mule/mule/#{version}/mule-#{version}.pom]."

if File.exists?("/root/.m2/org/mule/mule/#{version}/mule-#{version}.pom")
  log 'maven repositories already populated.'
else
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
end

bash "Install Mule applications from /DeployScripts_Binaries/#{messaging_server_directory}/apps to #{plugin_home}" do
  code <<-EOF
#!/bin/bash
APPLICATION_DIR='/DeployScripts_Binaries/#{messaging_server_directory}/apps'
MULE_PLUGIN_HOME="#{plugin_home}"

if [ ! -d "$MULE_PLUGIN_HOME" ]
then
mkdir -p -m 0777 $MULE_PLUGIN_HOME
fi
pushd $APPLICATION_DIR
if [ "$?" -ne "0" ] ; then
echo "No $APPLICATION_DIR found. Aborting with error"
exit 1
fi

APP_LIST=`find . -type f`
for APP_RELATIVE_PATH in $APP_LIST  ; do
APP_ZIP=`basename $APP_RELATIVE_PATH`
APP_DIR=${APP_ZIP%%.zip}
APP_ANCHOR="$APP_DIR-anchor.txt"
APP_PATH=`dirname $APP_RELATIVE_PATH`

if [ -f "$MULE_PLUGIN_HOME/$APP_ANCHOR" ] ; then
echo "Deleting the anchor file $APP_ANCHOR to undeploy application in a clean way"
rm "$MULE_PLUGIN_HOME/$APP_ANCHOR"
sleep 10
fi

if [ -d  "$MULE_PLUGIN_HOME/$APP_DIR" ] ; then
echo "Removing old application directory $APP_DIR"
rm -r -f "$MULE_PLUGIN_HOME/$APP_DIR"
fi

echo "Copying $APP_ZIP from $APPLICATION_DIR/$APP_PATH to $MULE_PLUGIN_HOME"
cp $APP_RELATIVE_PATH "$MULE_PLUGIN_HOME"
done
# bash embedded in ruby - double the backslash
find . -type f -exec cp {} "$MULE_PLUGIN_HOME" \\;
popd
  pushd $MULE_PLUGIN_HOME
  chmod -R ogu+w .
  echo "Contents of $MULE_PLUGIN_HOME"
  ls -l

  EOF
end

log "Mule custom applications installed"

# cannot inspect the environment using ruby code in recipes,
# need to either bootstrap/ delay expand such code, or use shell code

bash "Populate Mule configurations  #{mule_configuration_dir} from /DeployScripts_Binaries/#{messaging_server_directory}" do
  code <<-EOF

#!/bin/bash
########### inputs ########### 
MULE_CONFIGURATION_DIR="#{mule_configuration_dir}"
PROPERTIES_PATH="/DeployScripts_Binaries/#{messaging_server_directory}"
###########  code  ###########
if [ -d "$MULE_CONFIGURATION_DIR"  ] ; then
echo "Mule configuration directory $MULE_CONFIGURATION_DIR was found"
else
mkdir -p -m 0777 $MULE_CONFIGURATION_DIR
  echo "Mule configuration directory $MULE_CONFIGURATION_DIR created"
fi
set +e
pushd $MULE_CONFIGURATION_DIR
if [ $? -ne "0" ] ; then
  echo "Failed to create Mule configuration directory $MULE_CONFIGURATION_DIR"
  exit 1
fi
echo "Copying build properties from $PROPERTIES_PATH"
cp $PROPERTIES_PATH/* .
echo "Removing old properties backup files"
set +e
rm *.BAK 2 >& /dev/null
chmod -R ogu+w .
echo "Configuration directory:"
ls -l
  EOF
end

log "Mule application properties installed"

template "#{node['ruby_scripts_dir']}/update_configuration_tokens.rb" do
  source 'scripts/update_configuration_tokens.erb'
  variables(
    :app_server => node[:deploy][:app_server],
    :cache_server => node[:deploy][:cache_server],
    :db_server => node[:deploy][:db_server],
    :engine_server => node[:deploy][:engine_server],
    :messaging_server => node[:deploy][:messaging_server],
    :search_server => node[:deploy][:search_server],
    :web_server => node[:deploy][:web_server]
  )
end

bash 'Updating tokens in Mule configuration' do
  code "ruby #{node['ruby_scripts_dir']}/update_configuration_tokens.rb"
end