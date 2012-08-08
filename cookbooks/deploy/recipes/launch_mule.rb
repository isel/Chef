require 'fileutils'
require 'yaml'

# rs_agent_dev:download_cookbooks_once=true
hostname = node[:hostname]
ulimit_files = node[:ulimit_files]
sleep_interval = 10
plugin_home = '/opt/mule/apps'

# put a marker in the log .
launch_marker = (0..8).to_a.map { |a| rand(16).to_s(16) }.join

bash 'launch mule' do
  code <<-EOF
    set +e

      export LANG=en_US.UTF-8
      export MULE_HOME=/opt/mule
      export JAVA_HOME=/usr/lib/jvm/java-6-openjdk/jre
      export MAVEN_HOME=/usr/share/maven2
      export MAVEN_OPTS='-Xmx512m -XX:MaxPermSize=256m'
      export PATH=$PATH:$MULE_HOME/bin:$JAVA_HOME/bin
      export MULE_EE_PIDFILE=".mule_ee.pid"
      export LAUNCH_MARKER="-- #{launch_marker} launched --"
      export LAUNCH_TIMESTAMP=

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

      cd "$MULE_HOME/bin"

      if [ -x "mule" ] ; then
        MULE_STATUS=$(./mule status | tail -1| grep -i mule)
        echo "MULE_STATUS=$MULE_STATUS "
        MULE_PID=`expr "$MULE_STATUS" : 'Mule.*(\\([0-9][0-9]*\\)).*'`
        if [ ! -z  $MULE_PID ] ; then
          echo "mule is already running on PID=$MULE_PID"
        else
          echo 'starting the mule'
          LAUNCH_TIMESTAMP=$(date +"%Y/%m/%W %z %H:%M:%S")
          /usr/bin/nohup ./mule start -debug
          if [ -f $MULE_EE_PIDFILE ] ; then
            echo "Started the Mule process $( cat $MULE_EE_PIDFILE ) on $LAUNCH_TIMESTAMP"
          fi
        fi
      fi
  EOF
end

bash 'detect the mule status change' do
  code <<-EOF
    set +e

    export LANG=en_US.UTF-8
    export MULE_HOME=/opt/mule
    export JAVA_HOME=/usr/lib/jvm/java-6-openjdk/jre
    export MAVEN_HOME=/usr/share/maven2
    export MAVEN_OPTS='-Xmx512m -XX:MaxPermSize=256m'
    export PATH=$PATH:$MULE_HOME/bin:$JAVA_HOME/bin
    export MULE_EE_PIDFILE=".mule_ee.pid"
    export MULE_STATUS_CHECK_TIMESTAMP=
    cd "$MULE_HOME/bin"

    LAST_RETRY=0
    RETRY_CNT=5
    MULE_PID=
    while  [ -z $MULE_PID ] ; do

      if [ -f $MULE_EE_PIDFILE ] ; then
        echo "Mule pidfile has $( cat $MULE_EE_PIDFILE )"
      else
        echo "No mule pidfile"
      fi
      MULE_STATUS_CHECK_TIMESTAMP=$(date +"%Y/%m/%W %z %H:%M:%S")
      MULE_STATUS=$(./mule status | tail -1| grep -i mule)
      echo "Mule service status at ${MULE_STATUS_CHECK_TIMESTAMP}: $MULE_STATUS "
      MULE_PID=`expr "$MULE_STATUS" : 'Mule.*(\\([0-9][0-9]*\\)).*'`
      if [ ! -z  $MULE_PID ] ; then
        echo "Mule is launched with PID=$MULE_PID"
      fi
      RETRY_CNT=`expr $RETRY_CNT - 1`
      if [ "$RETRY_CNT" -eq "$LAST_RETRY" ] ; then
        echo "Exhausted retries, ignoring the error"
        exit 0
      fi
      echo "Retries left: $RETRY_CNT"
      sleep #{sleep_interval}
      done
  EOF
end

# shortly after launch the deployed plugins are exploded from the original zip format
# and become directory with the same basename this has to become erb template to work as intended.
node[:mule_plugins].each do |package_file|
  log "Inspecting mmc plugin package: #{package_file}"
  package_directory = File.basename(package_file, '.zip')
  if !File.exists?("#{plugin_home}/#{package_file}") && !File.directory?("#{plugin_home}/#{package_directory}")
    log "Neither Plugin file #{package_file} nor directory #{package_directory} was found in #{plugin_home}."
  end
end

bash 'verify the launch of mule' do
  code <<-EOF
    LAST_RETRY=0
    RETRY_CNT=60
    HTTP_STATUS=0
    RESULT=1
    echo 'waiting for mule to be serving HTTP on #{node[:mule_port]}'
    while  [ "$RESULT" -ne "0" ] ; do
      HTTP_STATUS=`curl --write-out %{http_code} --silent --output /dev/null  http://#{hostname}:#{node[:mule_port]}/mmc`
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

log 'mule successfully launched'

