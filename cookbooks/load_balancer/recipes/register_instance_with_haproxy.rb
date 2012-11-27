rightscale_marker :begin

forwarding_ports = node[:load_balancer][:forwarding_ports].split(',').reject{|port| port == '443'}
forwarding_ports.each do |port|
  listener_name = "#{node[:load_balancer][:prefix]}#{port}"
  bash 'Registering instance with haproxy configuration' do
    code <<-EOF
      echo registering instance: #{node[:load_balancer][:instance_backend_name]}, ip: #{node[:load_balancer][:instance_ip]}, listener: #{listener_name} with haproxy

      script="/opt/rightscale/lb/bin/haproxy_config_server.rb"

      /opt/rightscale/sandbox/bin/ruby $script -a add -w -s #{node[:load_balancer][:instance_backend_name]} -l #{listener_name} -t #{node[:load_balancer][:instance_ip]}:#{port} -e " inter 3000 rise 2 fall 3 maxconn #{node[:max_connections_per_lb]}" -k on

    EOF
  end
end

forwarding_ports = node[:load_balancer][:forwarding_ports].split(',').reject{|port| port == '443'}
forwarding_ports.each do |port|
  listener_name = "#{node[:load_balancer][:prefix]}#{port}"
  bash 'Registering instance with haproxy configuration' do
    code <<-EOF
      echo registering instance: #{node[:load_balancer][:instance_backend_name]}, ip: #{node[:load_balancer][:instance_ip]}, listener: #{listener_name} with haproxy

      script="/opt/rightscale/lb/bin/haproxy_config_server.rb"

      count=0
      echo /opt/rightscale/sandbox/bin/ruby $script -a add -w -s #{node[:load_balancer][:instance_backend_name]} -l #{listener_name} -t #{node[:load_balancer][:instance_ip]}:#{port} -e " inter 3000 rise 2 fall 3 maxconn #{node[:max_connections_per_lb]}" -k on
      result=`/opt/rightscale/sandbox/bin/ruby $script -a add -w -s #{node[:load_balancer][:instance_backend_name]} -l #{listener_name} -t #{node[:load_balancer][:instance_ip]}:#{port} -e " inter 3000 rise 2 fall 3 maxconn #{node[:max_connections_per_lb]}" -k on`
      echo "Result: $result"
      failtest=`echo $result | grep fail`
      while [ "$failtest" != "" ]; do
        if [ "$count" -gt 10 ]; then
          exit 1
        fi
        count=$[$count + 1]
        echo "waiting for $script to finish successfully"
        sleep 5
        echo /opt/rightscale/sandbox/bin/ruby $script -a add -w -s #{node[:load_balancer][:instance_backend_name]} -l #{listener_name} -t #{node[:load_balancer][:instance_ip]}:#{port} -e " inter 3000 rise 2 fall 3 maxconn #{node[:max_connections_per_lb]}" -k on
        result=`/opt/rightscale/sandbox/bin/ruby $script -a add -w -s #{node[:load_balancer][:instance_backend_name]} -l #{listener_name} -t #{node[:load_balancer][:instance_ip]}:#{port} -e " inter 3000 rise 2 fall 3 maxconn #{node[:max_connections_per_lb]}" -k on`
        echo "Result: $result"
        service haproxy status
        failtest=`echo $result | grep fail`
      done
    EOF
  end
end

template "#{node[:ruby_scripts_dir]}/wait_for_haproxy.rb" do
  source 'scripts/wait_for_haproxy.erb'
  variables(
    :binaries_directory => node[:binaries_directory],
    :timeout => 300
  )
end

bash 'Waiting for haproxy to start' do
  code <<-EOF
      ruby #{node[:ruby_scripts_dir]}/wait_for_haproxy.rb
  EOF
end

rightscale_marker :end