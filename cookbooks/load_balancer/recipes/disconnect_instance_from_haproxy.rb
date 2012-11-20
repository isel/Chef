rightscale_marker :begin

forwarding_ports = node[:load_balancer][:forwarding_ports].split(',').reject{|port| port == '443'}
forwarding_ports.each do |port|
  listener_name = "#{node[:load_balancer][:prefix]}#{port}"
  bash 'Removing instance from haproxy configuration' do
    code <<-EOF
      echo disconnecting instance: #{node[:load_balancer][:instance_backend_name]}, with listener: #{listener_name} from haproxy

      script="/opt/rightscale/lb/bin/haproxy_config_server.rb"
      args="-a del -w -s #{node[:load_balancer][:instance_backend_name]} -l #{listener_name}"

      /opt/rightscale/sandbox/bin/ruby $script $args

      # NOTE: restarting haproxy for now, we need a cleaner way to do this
      echo restarting haproxy
      service haproxy restart
    EOF
  end
end

rightscale_marker :end