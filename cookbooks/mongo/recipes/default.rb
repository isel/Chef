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
  database_port = '27017'
  install_directory_windows = install_directory.gsub(/\//, '\\\\')

  powershell 'Installing mongo' do

    script = <<-EOF

      ruby #{node[:ruby_scripts_dir]}/download_mongo.rb         -

      $erroractionpreference = 'SilentlyContinue'

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

      $ServiceKey = "HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\services\\${ServiceName}"
      write-output "Reading registry key of the service`n" ,   $ServiceKey

      # Run the MongoDB Service
      sc.exe start $ServiceName

      # Query the service
      sc.exe query $ServiceName

      # busy wait loop  for mogo.exe shell to be able to process commands
      $Env:MONGO_HOME = '#{install_directory_windows}'
      $Env:Path = "${Env:PATH};${Env:MONGO_HOME}\\bin"

      $command = "mongo.exe --eval ""quit();"""
      $finished = $false
      $Env:TIMEOUT = 100
      $cumulative_wait_time = 0
      $wait_time = 10
      $action = 'connect to mongo'
      Write-output "Trying ${action}"

      while ($cumulative_wait_time -lt ${Env:TIMEOUT}){

        $response = invoke-command  {cmd /c $command  2>`& /NUL}
        if ($response -match 'connecting to'){
          $finished = $true
          break
        }
        else {
          $cumulative_wait_time = $cumulative_wait_time + $wait_time
          write-host "Could not ${action} for ${cumulative_wait_time} sec. Retry after $wait_time sec."
          start-sleep  $wait_time
        }
      }

      if (!$finished){
        Write-Host "Could not ${action}"
        Exit 1
      }

      Write-host "Done ${action}"
      $Error.clear()
    EOF
    source(script)
    not_if { File.exist?(install_directory) }
  end
end
