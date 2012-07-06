# Stop and remove Mule_ESB
# undo just enough changes to workaround mule license expiration

version = node[:deploy][:mule_version]

bash 'Stop mule service' do
  code <<-EOF
    set +e
    MULE_LAUNCHER=`ps ax |  grep /mule/lib/boot/exec`
    if [ ! -z "$MULE_LAUNCHER" ] ; then
      echo 'stopping the mule'
      pushd /opt/mule/bin
      ./mule stop
      popd
      # wait
    fi
  EOF
  else

  log 'Mule service is not running'
end

complete_removal = 0

if File.exists?('/opt/mule')
  bash 'remove mule installation' do
    code <<-EOF
    set +e
    COMPLETE_REMOVAL="#{complete_removal}"
    if  [ "$COMPLETE_REMOVAL == "1" ] ; then
      rm ~/Installs/mule-enterprise-standalone-#{version}/* .
    fi
    rm -rf /opt/mule
    EOF
  end
  log 'Recycled Mule install directory.'
else
  log 'Mule was not installed.'
end

log "Removing maven repositories [/root/.m2/org/mule/mule/#{version}/mule-#{version}.pom]."

if File.exists?("/root/.m2/org/mule/mule/#{version}")
  log 'maven repositories successfully recycled. just kidding'
else
  log 'maven repositories not populated.'
end

