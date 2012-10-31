database_port = '27017'
ruby_scripts_dir = node[:ruby_scripts_dir]

if node[:platform] == 'ubuntu'
  bash 'Configuring mongo' do
    code <<-EOF
      mongo admin --eval "db.addUser(\""$ADMINISTRATOR_USER_MONGO"\",\""$ADMINISTRATOR_PASSWORD_MONGO"\")"
    EOF
  end
else
  template "#{ruby_scripts_dir}/add_mongo_auth.rb" do
    source 'scripts/add_mongo_auth.erb'
    variables(
      :binaries_directory => node[:binaries_directory],
      :admin_user_mongo => node[:deploy][:admin_user_mongo],
      :admin_password_mongo => node[:deploy][:admin_password_mongo],
      :db_port => database_port
    )
  end
  powershell 'Configuring mongo' do
    source(%{
    if ( (${Env:RS_REBOOT} -ne $null) -and (${Env:RS_REBOOT} -match 'true'))  {
      write-output 'Skipping configuring mongo during reboot.'
      $Error.Clear()
      exit 0
    }
    ruby #{ruby_scripts_dir}/add_mongo_auth.rb
    }) unless ENV['RS_REBOOT'].match(/true/)
  end
end
