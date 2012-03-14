
# the script may fail with
# jar hell error with log4j
# http://stackoverflow.com/questions/1359708/problem-using-log4j-with-axis2
#
#
#  /opt/mule/lib/boot/log4j-1.2.14.jar
#  /opt/mule/apps/mmc/webapps/mmc/WEB-INF/lib/slf4j-log4j12-1.5.6.jar
#  /opt/mule/apps/mmc/webapps/mmc/WEB-INF/lib/log4j-1.2.13.jar
#  /opt/ElasticSearch/elasticsearch-0.17.6/lib/log4j-1.2.16.jar
#
# and other errors



bash 'launch mule' do
      code <<-EOF
      cd /opt/mule/bin
      . /etc/bash.bashrc
      if [ -x mule ] ; then
        ./mule
      fi
      wget -O /dev/null http://node['ipaddress']:8585/mmc
  EOF
end
