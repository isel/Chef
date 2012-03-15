ipaddress = node['ipaddress']
ulimit_files = node[:deploy][:ulimit_files]

bash 'launch mule' do
      code <<-EOF
      cd /opt/mule/bin
      source /etc/bash.bashrc
      ulimit -n #{ulimit_files}
      if [ -x mule ] ; then
        /usr/bin/nohup ./mule > /var/log/mule 2>&1 &
      fi
      HTTP_STATUS=`curl --write-out %{http_code} --silent --output /dev/null  http://#{ipaddress}:8585/mmc`
      if [ $HTTP_STATUS -ne 302 ] ; then
        echo "Unexpected Mule response HTTP STATUS $HTTP_STATUS != 302 ()Found)"
        exit 1
      fi
  EOF
end
log 'mule successfully launched'