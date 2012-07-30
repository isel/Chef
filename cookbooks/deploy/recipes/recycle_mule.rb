# Stop and remove Mule_ESB
require 'fileutils'
require 'yaml'
product = 'mule'
mule_home = "/opt/#{product}"
version = node[:deploy][:mule_version]
complete_removal = 1
product_vendor_directory="/opt/mule-enterprise-standalone-#{version}"

# TODO - process cleanup
bash 'Stop mule service' do
  code <<-EOF
    set +e
    MULE_HOME=
    MULE_SIGNATURE='/mule/lib/boot/exec'
    SERVICE_PROCESS=`ps ax | grep $MULE_SIGNATURE | grep -v grep | awk '{print $1}'|tail -1`
    if [ ! -z "$SERVICE_PROCESS" ] ; then
      echo 'Stopping the mule via launcher script call'
      if [ -d "/opt/mule/bin" ] ; then
        pushd /opt/mule/bin
        ./mule stop
        echo "waiting on mule service stop "
        sleep 10
        popd
      else
        echo "No Mule bin directory detected"
      fi
    fi
    sleep 10
    echo "Terminate orphaned mule process still running"
    while [ ! -z $SERVICE_PROCESS ] ; do
      echo "Killing the service process $SERVICE_PROCESS"
      kill -KILL  $SERVICE_PROCESS
      sleep 10
      SERVICE_PROCESS=`ps ax | grep $MULE_SIGNATURE | grep -v grep | awk '{print $1}'|tail -1`
    done
  EOF
end

bash 'remove mule installation' do

    code <<-EOF
    set +e
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

    log "Check if $MULE_HOME directory is still present"
    pushd $MULE_HOME
    if [ "$?" -ne "0" ]
    then
    echo "No Mule install directory detected"
    exit 0
    else
    popd
    log "Detected that $MULE_HOME directory was still present"
    rm -rf $MULE_HOME
    fi
    EOF
  end

  log 'Recycled Mule install directory.'

=begin

The leftover directory contents are shown below.


root@ip-10-81-31-138:/opt# ls -la mule/.mule/
drwxr-xr-x 3 root root 4096 2012-07-25 14:51 mmc-agent-mule3-app-3.3.0
drwxr-xr-x 3 root root 4096 2012-07-25 14:51 mmc-distribution-console-app-3.3.0

=end