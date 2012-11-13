rightscale_marker :begin

template "#{node[:ruby_scripts_dir]}/add_admin_replica_set.rb" do
  source 'scripts/add_admin_replica_set.erb'
  variables(
      :admin_password_mongo => node[:deploy][:admin_password_mongo],
      :admin_user_mongo => node[:deploy][:admin_user_mongo]
  )
  only_if { node[:deploy][:is_primary_db] == 'true' && node[:deploy][:use_replication] == 'true' }
end

bash 'Add admin user for mongo with replica set' do
  code <<-EOF
    ruby #{node[:ruby_scripts_dir]}/add_admin_replica_set.rb
  EOF
  only_if { node[:deploy][:is_primary_db] == 'true' && node[:deploy][:use_replication] == 'true' }
end

rightscale_marker :end