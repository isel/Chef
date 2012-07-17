# Install the Mule_ESB
require 'fileutils'
require 'yaml'

version = node[:deploy][:mule_version]
ruby_scripts_dir = node['ruby_scripts_dir']
product = 'mule'
mule_home = "/opt/#{product}"
messaging_server_configuration='MessagingServer'
plugin_home = '/opt/mule/apps'

# shared directory to store ultimate.configuration and log4j.configuration files
# note the change of the name on the way.
configuration_dir = 'configuration'
mule_configuration_dir="#{mule_home}/#{configuration_dir}"
# MMC plugins
plugins = node[:deploy][:mule_plugins]
if !plugins.nil?
  plugins = plugins.split(',')
  if  plugins.length == 0
    plugins = %w(
             mmc-agent-mule3-app-3.3.0.zip
             mmc-distribution-console-app-3.3.0.zip
            )
  end
end

$DEBUG = false
properties_filename = '/opt/mule/configuration/ultimate.properties'
properties_backup_filename = "#{local_filename}.BAK"

# using tokens instead of variable reference in the hash
# to allow for name collision.

token_values = {
    'db_server' => node[:deploy][:db_server],
    'db_port' => node[:deploy][:db_port],
    'appserver' => node[:deploy][:app_server],
    'app_server' => node[:deploy][:app_server],
    'search_port' => node[:deploy][:elastic_search_port],
    'search_server' => node[:deploy][:search_server],
    'messaging_server_port' => node[:deploy][:messaging_server_port],
    'engine_server' => node[:deploy][:engine_server],
    'cache_server' => node[:deploy][:cache_server],
    'messaging_server' => node[:deploy][:messaging_server],
    'engine_port' => node[:deploy][:engine_port],
    'web_server' => node[:deploy][:web_server],
}

def update_properties(local_filename, token_values)
  $stderr.puts "local_filename=#{local_filename}"
  $stderr.puts "token_values=\n" + token_values.to_yaml

  f = File.open(local_filename, 'r+'); contents = f.read; f.close
  token_values.each do |token, entry|
    matcher = Regexp.new('(\{' + token + '\})', Regexp::MULTILINE)
    while matcher.match(contents) # multiline ?
      $stderr.puts "Will replace #{matcher.source}} with #{entry}"
      contents=contents.gsub(matcher, entry)
    end
  end
  $stderr.puts "updated contents\n" + contents
  File.open(local_filename, 'r+') { |f| f.puts contents }
end


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

    puts "Processing template " + File.join(File.dirname(__FILE__), '/scripts/download_vendor_drop.erb')
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
    log 'Mule service is installed'
  end

  log 'download configurations'

  template "#{ruby_scripts_dir}/download_plugins.rb" do
    source 'scripts/download_vendor_drop.erb'
    variables(
        :aws_access_key_id => node[:deploy][:aws_access_key_id],
        :aws_secret_access_key => node[:deploy][:aws_secret_access_key],
        :install_dir => "#{mule_home}/apps",
        :deploy_folder => "#{mule_home}/apps",
        :no_explode => 'true',
        :product => product,
        :version => version,
        :filelist => plugins.join(',')
    )
  end

  bash 'Downloading mmc plugin packages' do
    code <<-EOF
        ruby #{ruby_scripts_dir}/download_plugins.rb
    EOF
  end


  if File.exists?(plugin_home)
    log "looking at installed plugins"
# shortly after launch the deployed plugins are exploded from the original zip format
# and become directory with the same basename

    plugins.each do |package_file|
      log "Inspecting mmc plugin package: #{package_file}"
      package_directory = File.basename(package_file, '.zip')
      if !File.exists?("#{plugin_home}/#{package_file}") && !File.directory?("#{plugin_home}/#{package_directory}")
        log "Neither Plugin file #{package_file} nor directory #{package_directory} was found in #{plugin_home}."
        # d = Dir.new(plugin_home)
        # log d.entries.to_yaml
        # raise 1
      end
    end
  else
    log "Plugin app directory #{plugin_home} was not found under #{mule_home}"
  end
  # NOTE: after the mule starts, the zips get exploded.

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


  if !File.exists?(mule_configuration_dir)
    #    Dir.mkdir(mule_configuration_dir, 0777)
    bash "Populate Mule configurations  #{mule_configuration_dir} from /DeployScripts_Binaries/#{messaging_server_configuration}" do
      code <<-EOF
      #!/bin/bash

      MULE_CONFIGURATION_DIR="#{mule_configuration_dir}"
      mkdir -p -m 0777 $MULE_CONFIGURATION_DIR
      pushd $MULE_CONFIGURATION_DIR
      cp -R /DeployScripts_Binaries/#{messaging_server_configuration}/*  .
      chmod -R ogu+w .
      ls -l
      EOF
    end
    # replace the tokens in the properties file
    # Chef converge failed
    if !File.exists?(properties_backup_filename)
      # FileUtils.cp(properties_filename, properties_backup_filename)
      log "properties file backed up"
    end
    update_properties(properties_filename, token_values)
    log "Properties updated"


  else
    log "Mule configuration directory #{mule_configuration_dir} was found, kept intact"
    # d = Dir.new(mule_home)
    # log d.entries.to_yaml
    # raise 1
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

