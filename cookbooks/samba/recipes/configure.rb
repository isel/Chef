directory node[:deploy][:mule_home] do
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
  only_if { File.readlines('/etc/passwd').find{ |user_entry| user_entry.start_with?("#{node[:user]}:")}.nil?   }
end

service "smbd" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

template "/etc/samba/smb.conf" do
  source "smb.erb"
  variables(
    :share_name => node[:share_name],
    :share_path => node[:deploy][:mule_home]
  )
  notifies :restart, "service[smbd]"
end