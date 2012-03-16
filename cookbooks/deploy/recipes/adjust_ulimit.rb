# Adjust ulimit settings

ulimit_files = node[:deploy][:ulimit_files]
bash 'adjust ulimit settings' do
  code <<-EOF

ULIMIT_FILES=`ulimit -a |  grep 'open files'| awk '{print \$NF}'`
ULIMIT_FILES=`expr 0  + $ULIMIT_FILES`
if [ $ULIMIT_FILES -lt #{ulimit_files} ] ; then
  cp /etc/security/limits.conf /tmp/security_limits_conf.$$
  ADD_SETTING="nofile #{ulimit_files}"
  sed  -i -e 's/\\(# End of file\\)/nofile #{ulimit_files}\\n\\1/' /tmp/security_limits_conf.$$
  cp /tmp/security_limits_conf.$$ /etc/security/limits.conf
fi
EOF
end