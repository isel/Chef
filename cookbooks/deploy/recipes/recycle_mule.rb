# Stop and remove Mule_ESB
require 'fileutils'
require 'yaml'

version = node[:deploy][:mule_version]
complete_removal = 1
# TODO - process cleanup

bash 'Stop mule service' do
  code <<-EOF
    set +e
    MULE_LAUNCHER=`ps ax |  grep /mule/lib/boot/exec`
    if [ ! -z "$MULE_LAUNCHER" ] ; then
      echo 'Stopping the mule'
      if [ -d "/opt/mule/bin" ] ; then
      pushd /opt/mule/bin
      ./mule stop
      popd
      else
       echo "detected orphaned mule process running but without mule directory"
        SERVICE_PROCESS=`ps ax | grep mule | grep -v grep | awk '{print $1}'|tail -1`
        while [ ! -z $SERVICE_PROCESS ] ; do
        echo "Killing the service process $SERVICE_PROCESS"
        kill -KILL  $SERVICE_PROCESS
        sleep 1
        SERVICE_PROCESS=`ps ax | grep mule | grep -v grep | awk '{print $1}'|tail -1`
        done
    else
      echo 'Mule service is not running'
    fi
  EOF
end


if File.exists?('/opt/mule')
  bash 'remove mule installation' do
    code <<-EOF
    set +e
    COMPLETE_REMOVAL="#{complete_removal}"
    if  [ "$COMPLETE_REMOVAL" == "1" ] ; then
      rm /opt/mule-enterprise-standalone-#{version}
    fi
    rm -rf /opt/mule
    EOF
  end
  log 'Recycled Mule install directory.'
else
  log 'Mule was not installed.'
end