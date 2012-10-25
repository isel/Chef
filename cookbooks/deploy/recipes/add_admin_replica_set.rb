bash 'Add admin user for mongo with replica set' do
  code <<-EOF
    mongo admin --eval "db.addUser(\"#{node[:deploy][:admin_user_mongo]}\",\"#{node[:deploy][:admin_password_mongo]}\")"
  EOF
  only_if { node[:deploy][:is_primary_db] == 'true' && node[:deploy][:use_replication] == 'true' }
end