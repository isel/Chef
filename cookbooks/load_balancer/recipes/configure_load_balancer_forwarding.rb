node[:load_balancer][:forwarding_ports].split(',').each do |lb_bind_port|
  bash 'Configuring load balancer forwarding' do
    code <<-EOF
# Test for a reboot,  if this is a reboot just skip this script ******* we don't get this one in chef
echo rs_reboot = $RS_REBOOT

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
doc_root=/home/webapps/#{node[:load_balancer][:website_dns]}/current
deploy_dir=/home/webapps/#{node[:load_balancer][:website_dns]}/releases

mkdir -p $deploy_dir
mkdir -p $log_dir
ln -nfs $deploy_dir $doc_root

apache_maint_page="#{node[:load_balancer][:maintenance_page]}"

# Pass the listener target of the next hop proxy (haproxy)
bind_address = '127.0.0.1'
if [ "#{lb_bind_port}" == "80" -o "#{lb_bind_port}" == "443" ]; then
  next_hop_option="-n $bind_address:85"
else
  next_hop_option="-n $bind_address:80#{lb_bind_port}"
fi

# Entry port override?
if [ "#{lb_bind_port}" != "80" ]; then
  vhost_port_option="-p #{lb_bind_port}"
fi

# Set: ServerName, DocumentRoot, LogDirectory, MaintancePage, ExtendedStatus(On), and Serve
# Locally(Off)
options="-s #{node[:load_balancer][:website_dns]} -d $doc_root -l $log_dir $install_dir_option -m "$apache_maint_page" -k on -f off"

# Add an entry vhost (frontend) that forwards to next target

if [ "#{lb_bind_port}" == "443" ]; then
  apache="apache2"

  # Put SSL certificates in place
  key_dir=/etc/${apache}/rightscale.d/key
  mkdir -m 700 -p $key_dir
  echo "#{node[:load_balancer][:ssl_key]}" > $key_dir/#{node[:load_balancer][:website_dns]}.key
  echo "#{node[:load_balancer][:ssl_certificate]}" > $key_dir/#{node[:load_balancer][:website_dns]}.crt
  #if [ -n "$OPT_SSL_CERTIFICATE_CHAIN" ]; then
  #  echo "Installing SSL certificate chain"
  #  echo "$OPT_SSL_CERTIFICATE_CHAIN" > $key_dir/#{node[:load_balancer][:website_dns]}.sf_crt
  #fi
  chmod 400 $key_dir/*

  # Remove the on the key, so Apache service can start without passphrase
  #if [ -n "$OPT_SSL_PASSPHRASE" ]; then
  #  openssl rsa -passin env:OPT_SSL_PASSPHRASE -in $key_dir/$WEBSITE_DNS.key -passout env:OPT_SSL_PASSPHRASE -out $key_dir/$WEBSITE_DNS.key
  #fi

  /opt/rightscale/lb/bin/apache_config_vhost.rb  -t https  $vhost_port_option $next_hop_option $options -a /etc/${apache}/rightscale.d/key

  # Remove SSL certificates
  rm -rf /etc/${apache}/rightscale.d/key
else
  /opt/rightscale/lb/bin/apache_config_vhost.rb  -t http $vhost_port_option $next_hop_option $options
fi

# Reload apache with the new vhosts
a2enmod rewrite
if [ "#{lb_bind_port}" == "443" ]; then
  a2enmod headers
  a2enmod ssl
fi
service apache2 restart

logger -t RightScale "Vhost configuration done."
    EOF
  end
end
