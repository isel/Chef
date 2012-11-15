rightscale_marker :begin

database_port = '27017'
install_directory = node[:platform] == 'ubuntu' ? '/opt/mongodb' : 'c:/mongodb'
ruby_scripts_dir = node[:ruby_scripts_dir]

if node[:platform] == 'ubuntu'
  bash 'Configuring mongo' do
    code <<-EOF
      mongo admin --eval "db.addUser(\""$ADMINISTRATOR_USER_MONGO"\",\""$ADMINISTRATOR_PASSWORD_MONGO"\")"
    EOF
  end
else
  template "#{ruby_scripts_dir}/initiate_replica_set.rb" do
    source 'scripts/initiate_replica_set.erb'
    variables(
      :binaries_directory => node[:binaries_directory],
      :db_port => database_port,
      :db_replica_set_name => node[:deploy][:db_replica_set_name],
      :install_directory => install_directory,
      :service_name => 'mongoDB',
      :timeout => 120
    )
  end
  powershell 'Initializing the replica set' do
    source("ruby #{ruby_scripts_dir}/initiate_replica_set.rb")
  end

  template "#{ruby_scripts_dir}/add_mongo_auth.rb" do
    source 'scripts/add_mongo_auth.erb'
    variables(
      :admin_user_mongo => node[:deploy][:admin_user_mongo],
      :admin_password_mongo => node[:deploy][:admin_password_mongo],
      :db_port => database_port
    )
  end
  powershell 'Adding admin credentials to mongo' do
    source("ruby #{ruby_scripts_dir}/add_mongo_auth.rb")
  end

end

rightscale_marker :end