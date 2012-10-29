install_directory = node[:platform] == 'ubuntu' ? '/opt/mongodb' : 'c:/mongodb'

if node[:platform] == 'ubuntu'
  bash 'Configuring mongo' do
    code <<-EOF
      mongo admin --eval "db.addUser(\""${Env:ADMINISTRATOR_USER_MONGO}\"",\""${Env:ADMINISTRATOR_PASSWORD_MONGO}\"")"
    EOF
  end
else
  install_directory_windows = install_directory.gsub(/\//, '\\\\')

  powershell 'Configuring mongo' do
    parameters({

      'ADMINISTRATOR_USER_MONGO' => node[:deploy][:admin_user_mongo],
      'ADMINISTRATOR_PASSWORD_MONGO' => node[:deploy][:admin_password_mongo],
    }

    )
    script = <<-EOF

write-output "Probing RS_REBOOT=${env:RS_REBOOT}"

if ( (${Env:RS_REBOOT} -ne $null) -and (${Env:RS_REBOOT} -match 'true'))  {
   write-output 'Skipping configuring mongo during reboot.'
   $Error.Clear()
   exit 0
  }

$Env:MONGO_HOME = '#{install_directory_windows}'
$Env:Path = "${Env:PATH};${Env:MONGO_HOME}\\bin"

Write-output "Adding admin user"

mongo.exe admin --eval "db.addUser(\\""${Env:ADMINISTRATOR_USER_MONGO}\\"",\\""${Env:ADMINISTRATOR_PASSWORD_MONGO}\\"")"


    EOF

    source(script)
  end
