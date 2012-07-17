# Stop and remove Mule_ESB
require 'fileutils'
require 'yaml'
product = 'mule'
mule_home = "/opt/#{product}"
version = node[:deploy][:mule_version]
complete_removal = 1
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
      fi
    fi
    echo "Detect orphaned mule process still running"
    while [ ! -z $SERVICE_PROCESS ] ; do
      echo "Killing the service process $SERVICE_PROCESS"
      kill -KILL  $SERVICE_PROCESS
      sleep 1
      SERVICE_PROCESS=`ps ax | grep $MULE_SIGNATURE | grep -v grep | awk '{print $1}'|tail -1`
    done
  EOF
end


if File.exists?(mule_home)
  product_directory="mule-enterprise-standalone-#{version}"
  bash 'remove mule installation' do
    code <<-EOF
    set +e
    pushd /opt
    export MULE_HOME=#{mule_home}
    PRODUCT_DIRECTORY="#{product_directory}"
    COMPLETE_REMOVAL="#{complete_removal}"
    if  [ "$COMPLETE_REMOVAL" == "1" ] ; then
      rm -f -r $PRODUCT_DIRECTORY
    fi
    # remove the directory or soft link
    if [ -L "$MULE_HOME" ] ; then
      rm $MULE_HOME
    else
      rm -rf $MULE_HOME
    fi
    popd

    EOF
  end
  log 'Recycled Mule install directory.'
else
  log 'Mule was not installed.'
end