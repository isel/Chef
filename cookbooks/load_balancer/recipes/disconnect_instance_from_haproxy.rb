bash 'Removing instance from haproxy configuration' do
  code <<-EOF
    script="/opt/rightscale/lb/bin/haproxy_config_server.rb"
    args="-a del -w -s #{node[:load_balancer][:instance_backend_name]} -l www"

    /opt/rightscale/sandbox/bin/ruby $script $args
  EOF
end
