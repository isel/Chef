# Stop and remove Mule_ESB

version = node[:deploy][:mule_version]
complete_removal = 1
# TODO - process cleanup

bash 'Stop mule service' do
  code <<-EOF
    set +e
    MULE_LAUNCHER=`ps ax |  grep /mule/lib/boot/exec`
    if [ ! -z "$MULE_LAUNCHER" ] ; then
      echo 'Stopping the mule'
      pushd /opt/mule/bin
      ./mule stop
      popd
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
      rm $HOME/Installs/mule-enterprise-standalone-#{version}
    fi
    rm -rf /opt/mule
    EOF
  end
  log 'Recycled Mule install directory.'
else
  log 'Mule was not installed.'
end