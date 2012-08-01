require 'fileutils'
require 'yaml'

# rs_agent_dev:download_cookbooks_once=true
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
# put a marker in the log .
#(0..16).to_a.map{|a| rand(16).to_s(16)}.join
bash 'launch mule' do
  code <<-EOF
      cd /opt/mule/bin
      export LANG=en_US.UTF-8
      export MULE_HOME=/opt/mule
      export JAVA_HOME=/usr/lib/jvm/java-6-openjdk/jre
      export MAVEN_HOME=/usr/share/maven2
      export MAVEN_OPTS='-Xmx512m -XX:MaxPermSize=256m'
      export PATH=$PATH:$MULE_HOME/bin:$JAVA_HOME/bin
      export MULE_EE_PIDFILE=".mule_ee.pid"

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
            echo "current directory: `pwd`"
            echo "user: $UID"
            echo "effective user: $EUID"
            date +"%Y/%m/%W %z %H:%M:%S"
            echo 'starting the mule'
            ls -lA .
            /usr/bin/nohup ./mule start -debug
            echo 'started the mule'
            ls -lA .
            if [ -f $MULE_EE_PIDFILE ] ; then
            echo "Mule pidfile has $( cat $MULE_EE_PIDFILE )"
            fi
         fi
      fi
  EOF
end
if !verify_completion.nil? && verify_completion != ''

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

  cd "$MULE_HOME/bin"

  echo "current directory: `pwd`"
  date +"%Y/%m/%W %z %H:%M:%S"
  echo "Checking mule service status"
  ls -lA .
  if [ -f $MULE_EE_PIDFILE ] ; then
    echo "Mule pidfile has $( cat $MULE_EE_PIDFILE )"
  else
    echo "No mule pidfile"
  fi

  LAST_RETRY=0
  RETRY_CNT=5
  MULE_PID=
  while  [ -z  $MULE_PID ] ; do
    echo "current directory: `pwd`"
    date +"%Y/%m/%W %z %H:%M:%S"
    echo "Checking mule service status"
    ls -lA .
    if [ -f $MULE_EE_PIDFILE ] ; then
      echo "Mule pidfile has $( cat $MULE_EE_PIDFILE )"
    else
      echo "No mule pidfile"
    fi
    ./mule status
    MULE_STATUS=$(./mule status | tail -1| grep -i mule)

    echo "MULE_STATUS=$MULE_STATUS "
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
    popd

  EOF
end
end

bash 'show the mule_ee.log from the current launch' do
  code <<-EOF

MULE_EE_LOG="/opt/mule/logs/mule_ee.log"

LINE_LAST_LAUNCH=$(grep -n 'initialization started' $MULE_EE_LOG | grep 'Root WebApplicationContext'| tail -1 | cut -d: -f1)
if [ ! -z $LINE_LAST_LAUNCH ] ; then
sed -n "$LINE_LAST_LAUNCH,\\$p" $MULE_EE_LOG
else
cat $MULE_EE_LOG
fi
  EOF
end

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

