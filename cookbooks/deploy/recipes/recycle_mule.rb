# Stop and remove Mule_ESB
require 'fileutils'
require 'yaml'
product = 'mule'
mule_home = "/opt/#{product}"
version = node[:deploy][:mule_version]
product_vendor_directory="/opt/mule-enterprise-standalone-#{version}"
sleep_interval = 10
complete_removal = node[:deploy][:mule_complete_removal]

if !complete_removal.nil? && complete_removal != ''

bash 'Tell mule to undeploy plugins and applications in a clean way' do
  code <<-EOF
    set +e
    export LANG=en_US.UTF-8
    MULE_HOME="#{mule_home}"
    MULE_PLUGIN_HOME="$MULE_HOME/apps"
    if [ ! -d "$MULE_PLUGIN_HOME" ] ; then
      edit 0
    fi
    pushd "$MULE_PLUGIN_HOME"
    APP_ANCHOR_LIST=`find . -type f  -a -name '*-anchor.txt'`
    for APP_ANCHOR_FILE in $APP_ANCHOR_LIST ; do
      echo "Deleting the anchor file $APP_ANCHOR_FILE"
      rm "$MULE_PLUGIN_HOME/$APP_ANCHOR_FILE"
      pushd $MULE_HOME/bin
      ./mule restart
      popd
      sleep 30
    done
  EOF
end
end

bash 'Stop mule service' do
  code <<-EOF
    set +e
    export LANG=en_US.UTF-8
    MULE_HOME="#{mule_home}"
    MULE_SIGNATURE='/mule/lib/boot/exec'
    SERVICE_PROCESS=`ps ax | grep $MULE_SIGNATURE | grep -v grep | awk '{print $1}'|tail -1`
    if [ ! -z "$SERVICE_PROCESS" ] ; then
      echo 'Stopping the mule via launcher script call'
      if [ -d "$MULE_HOME/bin" ] ; then
        pushd $MULE_HOME/bin
        ./mule stop
        echo "waiting on mule service stop "
        sleep 10
        popd
      else
        echo "No Mule bin directory detected"
      fi
    fi
  EOF
end

bash 'Detect mule stops clean' do

  code <<-EOF
  export LANG=en_US.UTF-8
  MULE_HOME="#{mule_home}"

  pushd "$MULE_HOME/bin"

  LAST_RETRY=0
  RETRY_CNT=5
  MULE_STATUS=$(./mule status | tail -1| grep -i mule)
  echo "MULE_STATUS=$MULE_STATUS"
  MULE_PID=`expr "$MULE_STATUS" : 'Mule.*(\\([0-9][0-9]*\\)).*'`
  while  [ ! -z $MULE_PID ] ; do
    MULE_STATUS=$(./mule status | tail -1| grep -i mule)
    echo "MULE_STATUS=$MULE_STATUS "
    MULE_PID=`expr "$MULE_STATUS" : 'Mule.*(\\([0-9][0-9]*\\)).*'`
    if [ -z  $MULE_PID ] ; then
      echo "Mule is terminated"
      exit 0
    fi
    RETRY_CNT=`expr $RETRY_CNT - 1`
    if [ "$RETRY_CNT" -eq "$LAST_RETRY" ] ; then
      echo "Exhausted retries"
      exit 1
    fi
    echo "Retries left: $RETRY_CNT"
    sleep #{sleep_interval}
  done
  popd

  EOF
end

if !complete_removal.nil? && complete_removal != ''

bash 'Terminate stray mule processes' do
  code <<-EOF
    set +e
    export LANG=en_US.UTF-8
    MULE_SIGNATURE='/mule/lib/boot/exec'
    SERVICE_PROCESS=`ps ax | grep $MULE_SIGNATURE | grep -v grep | awk '{print $1}'|tail -1`
    if [ ! -z "$SERVICE_PROCESS" ] ; then
    echo "Terminate orphaned mule process still running"
    while [ ! -z $SERVICE_PROCESS ] ; do
      echo "Killing the service process $SERVICE_PROCESS"
      kill -KILL  $SERVICE_PROCESS
      sleep 10
      SERVICE_PROCESS=`ps ax | grep $MULE_SIGNATURE | grep -v grep | awk '{print $1}'|tail -1`
    done
    fi
  EOF
end


bash 'remove mule installation' do

  code <<-EOF
    set +e
    export LANG=en_US.UTF-8
    export MULE_HOME=#{mule_home}
    PRODUCT_VENDOR_DIRECTORY="#{product_vendor_directory}"
    rm -f -r $PRODUCT_VENDOR_DIRECTORY

    # remove the directory or soft link
    # does not properly recycle mule directory.

    if [ -d $MULE_HOME ] ; then
    rm -rf $MULE_HOME
    fi
    if [ -L $MULE_HOME ] ; then
    rm -f $MULE_HOME
    fi

    echo "Check if $MULE_HOME directory is still present"
    pushd $MULE_HOME
    if [ "$?" -ne "0" ]
    then
    echo "No Mule install directory detected"
    exit 0
    else
    popd
    echo "Detected that $MULE_HOME directory was still present"
    rm -rf $MULE_HOME
    fi
  EOF
end

log 'Recycled Mule install directory.'

end

=begin

Leftover directory cfound after recycling mule:

ls -la mule/.mule/
drwxr-xr-x 3 root root 4096 2012-07-25 14:51 mmc-agent-mule3-app-3.3.0
drwxr-xr-x 3 root root 4096 2012-07-25 14:51 mmc-distribution-console-app-3.3.0

=end
