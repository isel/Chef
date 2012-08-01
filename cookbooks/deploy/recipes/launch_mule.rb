require 'fileutils'
require 'yaml'


hostname = node[:hostname]
ulimit_files = node[:deploy][:ulimit_files]
mule_port = node[:deploy][:mule_port]
verify_completion = node[:deploy][:verify_completion]
sleep_interval = 10
plugin_home = '/opt/mule/apps'

# MMC plugins. List of plugins is read from server input.
# There is a mmc plugins which are required.
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

bash 'launch mule' do
      code <<-EOF
      cd /opt/mule/bin
      export LANG=en_US.UTF-8
      export MULE_HOME=/opt/mule
      export JAVA_HOME=/usr/lib/jvm/java-6-openjdk/jre
      export MAVEN_HOME=/usr/share/maven2
      export MAVEN_OPTS='-Xmx512m -XX:MaxPermSize=256m'
      export PATH=$PATH:$MULE_HOME/bin:$JAVA_HOME/bin
      FILE_LIMIT=#{ulimit_files}
      if [ ! -z $FILE_LIMIT ];      then
      FILE_LIMIT=`expr $FILE_LIMIT : '^\\([0-9][0-9]*\\)$'`
      echo "FILE_LIMIT='$FILE_LIMIT'"
      fi
      if [ ! -z $FILE_LIMIT ]
      then
        echo 'bumping open file handle limit to $FILE_LIMIT'
        ulimit -n $FILE_LIMIT
      else
        echo 'no meaningful FILE_LIMIT provided'
      fi
      ulimit -a
      if [ -x mule ] ; then
         MULE_STATUS=$(./mule status | tail -1| grep -i mule)
         echo "MULE_STATUS=$MULE_STATUS "
         MULE_PID=`expr "$MULE_STATUS" : 'Mule.*(\\([0-9][0-9]*\\)).*'`
         if [ ! -z  $MULE_PID ] ; then
         echo "mule is already running on PID=$MULE_PID"
         else
            echo 'starting the mule'
            /usr/bin/nohup ./mule start -debug
         fi
      fi
  EOF
end

# test the mule status again
=begin
         MULE_STATUS=$(./mule status | tail -1| grep -i mule)
         echo "MULE_STATUS=$MULE_STATUS "
         MULE_PID=`expr "$MULE_STATUS" : 'Mule.*(\\([0-9][0-9]*\\)).*'`
         if [ ! -z  $MULE_PID ] ; then
         echo "mule is already running on PID=$MULE_PID"
         else

=end


# shortly after launch the deployed plugins are exploded from the original zip format
# and become directory with the same basename

plugins.each do |package_file|
    log "Inspecting mmc plugin package: #{package_file}"
    package_directory = File.basename(package_file,'.zip')
    if !File.exists?("#{plugin_home}/#{package_file}") && !File.directory?("#{plugin_home}/#{package_directory}")
      log "Neither Plugin file #{package_file} nor directory #{package_directory} was found in #{plugin_home}."
      # d = Dir.new(plugin_home)
      # log d.entries.to_yaml
      # raise 1
    end
end

#
# wget -O /dev/null http://localhost:8585/mmc
#
if !verify_completion.nil? && verify_completion != ''
  bash 'verify the launch of mule' do
    code <<-EOF
    LAST_RETRY=0
    RETRY_CNT=60
    HTTP_STATUS=0
    RESULT=1
    echo 'waiting for mule to be serving HTTP on #{mule_port}'
    while  [ "$RESULT" -ne "0" ] ; do
      HTTP_STATUS=`curl --write-out %{http_code} --silent --output /dev/null  http://#{hostname}:#{mule_port}/mmc`
      expr $HTTP_STATUS : '302\\|200' > /dev/null
      RESULT=$?
      echo "get HTTP status code $HTTP_STATUS, $RESULT"
      RETRY_CNT=`expr $RETRY_CNT - 1`
      if [ "$RETRY_CNT" -eq "$LAST_RETRY" ] ; then
         echo "Exhausted retries"
         exit 1
      fi
      echo "Retries left: $RETRY_CNT"
      sleep #{sleep_interval}
    done
  EOF
  end
end
log 'mule successfully launched'

