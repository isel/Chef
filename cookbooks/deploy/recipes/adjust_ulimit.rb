# ruby_scripts_dir = node['ruby_scripts_dir']
# deploy_scripts_dir = node['deploy_scripts_dir']

# Adjust ulimit settings
ulimit_files=8192
# ulimit_files = node[:deploy][:ulimit_files]
bash 'adjust ulimit settings' do
  code <<-EOF

ULIMIT_FILES=`ulimit -a |  grep 'open files'| awk '{print $NF}'`
ULIMIT_FILES=`expr 0  + $ULIMIT_FILES`
if [ $ULIMIT_FILES -lt #{ulimit_files} ] ; then
  cp /etc/security/limits.conf /tmp/security_limits_conf.$$
  ADD_SETTING="nofile #{ulimit_files}"
  sed  -ie 's/\(# End of file\)/$ADD_SETTING\n\1/' /tmp/security_limits_conf.$$
  cp /tmp/security_limits_conf.$$ /etc/security/limits.conf
  # TODO - what service to restart to make changes take effect w/o reboot / logoff .
  # maybe nothing - the limits.conf is used to persist across users.

fi
EOF
end