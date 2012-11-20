rightscale_marker :begin

forwarding_ports = node[:load_balancer][:forwarding_ports].split(',').reject{|port| port == '443'}
forwarding_ports.each do |port|
  listener_name = "#{node[:load_balancer][:prefix]}#{port}"
  bash 'Registering instance with haproxy configuration' do
    code <<-EOF
      echo registering instance: #{node[:load_balancer][:instance_backend_name]}, ip: #{node[:load_balancer][:instance_ip]}, listener: #{listener_name} with haproxy

      script="/opt/rightscale/lb/bin/haproxy_config_server.rb"
      args1="-a add -w -s #{node[:load_balancer][:instance_backend_name]}"
      args2="-l #{listener_name} -t #{node[:load_balancer][:instance_ip]}:#{port}"
      args3="-e inter 3000 rise 2 fall 3 maxconn #{node[:max_connections_per_lb]} -k on"

      echo /opt/rightscale/sandbox/bin/ruby $script $args1 $args2 $args3
      /opt/rightscale/sandbox/bin/ruby $script $args1 $args2 $args3
    EOF
  end
end

rightscale_marker :end