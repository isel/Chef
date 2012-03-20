sarmus_loglevel = node[:deploy][:sarmus_loglevel]
script "Restart sarmus to #{sarmus_loglevel}" do
  interpreter "bash"
  code <<-EOF
    echo "Restart sarmus to #{sarmus_loglevel}"
    SERVICE_STATUS=`service sarmus_service status`
    expr "$SERVICE_STATUS" : '.*running.*' > /dev/null
    STATUS=$?
    if [ "$STATUS" -eq "0" ]; then
      service sarmus_service stop
    else
      echo 'sarmus service was not operational'
    fi
      echo 'updating sarmus_service file'
      sed -e 's/\\(SARMUS_LOGLEVEL\\)=\\([0-9]\\)/\\1=#{sarmus_loglevel}/' /etc/init.d/sarmus_service  > /tmp/sarmus_service.tmp.$$
      cp /tmp/sarmus_service.tmp.$$ /etc/init.d/sarmus_service
      service sarmus_service start
   EOF
end