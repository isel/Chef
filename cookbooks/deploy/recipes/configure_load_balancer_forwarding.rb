lb_bind_address = '127.0.0.1'
#lb_bind_port = '85'

['85', '81', '82'].each do |lb_bind_port|
  bash 'Configuring load balancer forwarding' do
    code <<-EOF
# Test for a reboot,  if this is a reboot just skip this script.
echo rs_reboot = $RS_REBOOT
echo rs_private_ip = $RS_PRIVATE_IP

if test "$RS_REBOOT" = "true" ; then
  echo "Skip configure vhost on reboot."
  exit 0
fi

# hack for /opt/rightscale/lb/bin/apache_config_vhost.rb to work inside the VPC
EC2_PUBLIC_HOSTNAME=#{node[:ipaddress]}; export EC2_PUBLIC_HOSTNAME

# hack to make the Rightscale tools work in an EBS backed image
ln -s -f /var/spool/cloud /var/spool/ec2

log_dir="/var/log/apache2"
install_dir_option=" -i /etc/apache2"

## General Variables
doc_root=/home/webapps/#{node[:deploy][:lb_application]}/current
deploy_dir=/home/webapps/#{node[:deploy][:lb_application]}/releases

mkdir -p $deploy_dir
mkdir -p $log_dir
ln -nfs $deploy_dir $doc_root

apache_maint_page="#{node[:deploy][:lb_maintenance_page]}"

# Pass the listener target of the next hop proxy (haproxy)
next_hop_option="-n #{lb_bind_address}:#{lb_bind_port}"

# Entry port override?
if [ "#{lb_bind_port}" != "85" ]; then
  vhost_port_option="-p #{lb_bind_port}"
fi

# Set: ServerName, DocumentRoot, LogDirectory, MaintancePage, ExtendedStatus(On), and Serve
# Locally(Off)
options="-s #{node[:deploy][:lb_website_dns]} -d $doc_root -l $log_dir $install_dir_option -m "$apache_maint_page" -k on -f off"

# Add an entry vhost (frontend) that forwards to next target
/opt/rightscale/lb/bin/apache_config_vhost.rb  -t http $vhost_port_option $next_hop_option $options

# Reload apache with the new vhosts
a2enmod rewrite
service apache2 restart

logger -t RightScale "Vhost configuration done."
    EOF
  end
end
