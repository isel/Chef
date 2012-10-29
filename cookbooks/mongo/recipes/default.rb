require 'json'
require 'fileutils'

include_recipe 'core::download_vendor_artifacts_prereqs'

artifacts = node[:platform] == 'ubuntu' ? 'mongo_ubuntu' : 'mongo_windows'
target_directory = node[:platform] == 'ubuntu' ? '/' : 'c:/download_mongodb'
install_directory = node[:platform] == 'ubuntu' ? '/opt/mongodb' : 'c:/mongodb'

template "#{node[:ruby_scripts_dir]}/download_mongo.rb" do
  local true
  source "#{node[:ruby_scripts_dir]}/download_vendor_artifacts.erb"
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :s3_bucket => node[:core][:s3_bucket],
    :s3_repository => 'Vendor',
    :product => 'mongo',
    :version => node[:deploy][:mongo_version],
    :artifacts => artifacts,
    :target_directory => target_directory,
    :unzip => true
  )
  not_if { File.exist?(install_directory) }
end

if node[:platform] == 'ubuntu'
  bash 'Installing mongo' do
    code <<-EOF
      ruby #{node[:ruby_scripts_dir]}/download_mongo.rb
      mv /usr/local/mongo /usr/local/mongodb
      chmod a+x /usr/local/mongodb/bin/*
    EOF
    not_if { File.exist?(install_directory) }
  end
else
  # settings = JSON.parse(File.read(node['deployment_settings_json']))
  # database_port = settings['database_port']
  database_port = '27071'
  install_directory_windows = install_directory.gsub(/\//, '\\\\')

  powershell 'Installing mongo' do

    script = <<-EOF

      ruby #{node[:ruby_scripts_dir]}/download_mongo.rb         -
      $ServiceName = 'MongoDB'
      $ServiceStartDelay  = 15

      new-item -path "#{install_directory}" -Type Directory -Force -ErrorAction SilentlyContinue | out-null

      cd #{install_directory}

      copy-item "#{target_directory}/mongo_windows/mongo/*" -destination . -recurse -Force

      # create logpath
      new-item -path log -Type Directory -Force | out-null

      # create datapath
      new-item -path data/db  -Type Directory -Force | out-null

      # update configuration
      $conf = '#{install_directory_windows}\\mongod.conf'
      (Get-Content ($conf)) | Foreach-Object {$_ -replace "^port +=.+$", ("port = " + #{database_port})} | Set-Content  ($conf)

      # Install the MongoDB Service
      bin\\mongod.exe --config $conf --install  --rest

      sc.exe query $ServiceName

      $ServiceKey = "HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\services\\${ServiceName}"
      write-output "Reading registry key of the service`n" ,   $ServiceKey
      reg.exe query $ServiceKey

      # Run the MongoDB Service
      sc.exe start $ServiceName

      start-sleep $ServiceStartDelay
      sc.exe query $ServiceName
    EOF
    source(script)
    not_if { File.exist?(install_directory) }
  end

end
=begin

windows

$Env:MONGO_HOME = 'C:\mongodb\'
$Env:Path = "${Env:PATH};${Env:MONGO_HOME}\bin"
$Env:ADMINISTRATOR_USER_MONGO  =  'adm'
$Env:ADMINISTRATOR_PASSWORD_MONGO  = 'ar'

Write-output "Adding admin user"
Write-output  "db.addUser(""${Env:ADMINISTRATOR_USER_MONGO}"",""${Env:ADMINISTRATOR_PASSWORD_MONGO}"")"

 mongo admin --eval "db.addUser(\""${Env:ADMINISTRATOR_USER_MONGO}\"",\""${Env:ADMINISTRATOR_PASSWORD_MONGO}\"")"



unix


echo -e "\njournal = true\n" >> $mongodb_config
if test "$EBS_SKIP_MOUNT" == "false"; then
  echo "Adding admin user"
  mongo admin --eval "db.addUser(\""$ADMINISTRATOR_USER_MONGO"\",\""$ADMINISTRATOR_PASSWORD_MONGO"\")"
sed -i -r "s/^#\s*auth\s*=.*/auth = true/" $mongodb_config
fi
$LogPath = 'C:\mongodb\log'
$DbPath = 'C:\mongodb\data\db'
$LogPath = 'C:\mongodb\log2\mongo.log'


      $LogPath = $LogPath  -Replace '\\[^\\]*$'  , ''
      write-output $LogPath

      # create logpath
      new-item -path $LogPath  -Type Directory -Force | out-null

=end