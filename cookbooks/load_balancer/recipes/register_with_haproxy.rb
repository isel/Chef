rightscale_marker :begin

template "#{node[:ruby_scripts_dir]}/register_with_haproxy.rb" do
  source 'scripts/register_with_haproxy.erb'
  variables(
    :deployment_name => node[:deploy][:deployment_name],
    :prefix => node[:load_balancer][:prefix],
    :instance_backend_name => node[:load_balancer][:backend_name],
    :instance_ip => node[:load_balancer][:server_ip]
  )
end

if node[:platform] == "ubuntu"
  bash 'Registering instance with haproxy' do
    code <<-EOF
      ruby #{node[:ruby_scripts_dir]}/register_with_haproxy.rb
    EOF
    only_if { node[:load_balancer][:should_register_with_lb] == 'true' }
  end
else
  powershell 'Registering instance with haproxy' do
    source("ruby #{node[:ruby_scripts_dir]}/register_with_haproxy.rb")
    only_if { node[:load_balancer][:should_register_with_lb] == 'true' }
  end
end

rightscale_marker :end