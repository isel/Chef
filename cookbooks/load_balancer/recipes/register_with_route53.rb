rightscale_marker :begin

template "#{node[:ruby_scripts_dir]}/register_with_route53.rb" do
  source 'scripts/route53.erb'
  variables(
    :action => 'create',
    :binaries_directory => node[:binaries_directory],
    :domain => node[:load_balancer][:domain],
    :prefix => node[:load_balancer][:prefix],
    :route53_ip => node[:load_balancer][:route53_ip],
    :route53_additional_ip => node[:load_balancer][:route53_additional_ip]
  )
end

if node[:load_balancer][:route53_ip] && node[:load_balancer][:domain]
  if node[:platform] == "ubuntu"
    bash 'Registering with Route53' do
      code <<-EOF
          ruby #{node[:ruby_scripts_dir]}/register_with_route53.rb
      EOF
    end
  else
    powershell 'Registering with Route53' do
      source("ruby #{node[:ruby_scripts_dir]}/register_with_route53.rb")
    end
  end
  right_link_tag "route53:domain=#{node[:load_balancer][:prefix]}.#{node[:load_balancer][:domain]}"
end

rightscale_marker :end
