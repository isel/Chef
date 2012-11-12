rightscale_marker :begin

template "#{node[:ruby_scripts_dir]}/local_web.rb" do
  source 'scripts/local_web.erb'
  variables(
    :app_server => node[:deploy][:app_server],
    :server_type => node[:core][:server_type],
    :download_server  => node[:deploy][:domain].nil? ? node[:ipaddress] : "www.#{node[:deploy][:domain]}"
  )
end

bash 'Running local smoke tests' do
  code <<-EOF
    rake --rakefile #{node[:ruby_scripts_dir]}/local_web.rb
  EOF
end

rightscale_marker :end