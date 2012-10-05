share_path = "#{node[:deploy][:mule_home]}/apps"

directory share_path do
  owner "root"
  group "root"
  mode "0777"
  action :create
end

bash 'adding samba user' do
  code <<-EOF
    useradd -s /bin/true #{node[:user]}
    (echo #{node[:samba][:password]}; echo #{node[:samba][:password]}) | smbpasswd -L -a -s #{node[:user]}
    smbpasswd -L -e #{node[:user]}
  EOF
  not_if { File.exist?(share_path) }
end

service "smbd" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

template "/etc/samba/smb.conf" do
  source "smb.erb"
  variables(
    :share_name => node[:share_name],
    :share_path => share_path
  )
  notifies :restart, "service[smbd]"
end