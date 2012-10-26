require 'json'
require 'fileutils'

include_recipe 'core::download_vendor_artifacts_prereqs'

artifacts = node[:platform] == 'ubuntu' ? 'mongo_ubuntu' : 'mongo_windows'
target_directory = node[:platform] == 'ubuntu' ? '/' : '/download_mongodb'
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
    :version =>  node[:deploy][:mongo_version],
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
  target_directory_windows = target_directory.gsub(/\//, '\\')
  install_directory_windows = install_directory.gsub(/\//, '\\')

  powershell 'Installing mongo' do

    script = <<-EOF

      ruby #{node[:ruby_scripts_dir]}/download_mongo.rb         -

      new-item -path "#{install_directory_windows}" -Type Directory -Force -ErrorAction SilentlyContinue
      cd #{install_directory_windows}
      copy-item "#{target_directory_windows}\mongo_windows\mongo\*" -recurse -Force -ErrorAction SilentlyContinue
      $conf = 'mongodb.conf'
      (Get-Content ($conf)) | Foreach-Object {$_ -replace "^port +=.+$", ("port = " + #{database_port})} | Set-Content  ($conf)

      mkdir log
      mkdir data\db
      bin\mongod.exe --config  C:\mongodb\mongod.conf  --install  --rest
      net.exe start mongodb

    EOF
    source(script)
    not_if { File.exist?(install_directory) }
  end

  env('JAVA_HOME') { value 'c:\jdk\bin' }
  env('JRE_HOME') { value 'c:\jdk\bin' }

  env('PATH') do
    action :modify
    delim ::File::PATH_SEPARATOR
    value 'C:\jdk\bin'
  end
end