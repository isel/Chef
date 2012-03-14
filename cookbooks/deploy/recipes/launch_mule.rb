
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
