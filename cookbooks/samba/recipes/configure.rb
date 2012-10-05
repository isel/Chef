directory node[:samba][:share_path] do
  owner "root"
  group "root"
  mode "0777"
  action :create
end

user node[:user] do
  comment "samba user"
  system true
  shell "/bin/true"
  password node[:samba][:password]
end

service "smbd" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

template "/etc/samba/smb.conf" do
  source "smb.erb"
  variables(
    :share_name => node[:share_name],
    :share_path => node[:samba][:share_path]
  )
  notifies :restart, "service[smbd]"
end