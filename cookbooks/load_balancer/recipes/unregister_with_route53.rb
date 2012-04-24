
template "#{node['ruby_scripts_dir']}/unregister_with_route53.rb" do
  source 'scripts/route53.erb'
  variables(
    :action => 'delete',
    :binaries_directory => node['binaries_directory'],
    :domain         => node[:load_balancer][:domain],
    :prefix         => node[:load_balancer][:prefix],
    :load_balancer1 => node[:load_balancer][:load_balancer1],
    :load_balancer2 => node[:load_balancer][:load_balancer2]
  )
end

bash 'Un-registering with Route53' do
  code <<-EOF
      ruby #{node['ruby_scripts_dir']}/unregister_with_route53.rb
  EOF

  only_if { node[:load_balancer][:load_balancer1] }
end
