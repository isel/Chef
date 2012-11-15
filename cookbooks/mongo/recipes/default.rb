rightscale_marker :begin

require 'json'
require 'fileutils'

include_recipe 'core::download_vendor_artifacts_prereqs'

artifacts = node[:platform] == 'ubuntu' ? 'mongo_ubuntu' : 'mongo_windows'
target_directory = node[:platform] == 'ubuntu' ? '/' : 'c:/download_mongodb'
install_directory = node[:platform] == 'ubuntu' ? '/opt/mongodb' : 'c:/mongodb'
database_port = '27017'
ruby_scripts_dir = node[:ruby_scripts_dir]

template "#{ruby_scripts_dir}/download_mongo.rb" do
  local true
  source "#{ruby_scripts_dir}/download_vendor_artifacts.erb"
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
      ruby #{ruby_scripts_dir}/download_mongo.rb
      mv /usr/local/mongo /usr/local/mongodb
      chmod a+x /usr/local/mongodb/bin/*
    EOF
    not_if { File.exist?(install_directory) }
  end
else

  powershell 'Downloading mongo' do
    source("ruby #{ruby_scripts_dir}/download_mongo.rb")
    not_if { File.exist?(install_directory) }
  end

  template "#{ruby_scripts_dir}/mongod.conf" do
    source 'mongod_conf.erb'
    variables(
      :db_port => database_port,
      :db_replica_set_name => node[:deploy][:db_replica_set_name],
      :install_directory => install_directory.gsub(/\//, '\\\\')
    )
    not_if { File.exist?(install_directory) }
  end

  template "#{ruby_scripts_dir}/install_mongo.rb" do

    source 'scripts/install_mongo.erb'
    variables(
      :binaries_directory => node[:binaries_directory],
      :db_port => database_port,
      :install_directory => install_directory,
      :source_config => "#{ruby_scripts_dir}/mongod.conf",
      :service_name => 'mongoDB',
      :source_directory => target_directory,
      :timeout => 300
    )
    not_if { File.exist?(install_directory) }
  end

  powershell 'Installing mongo' do
    source("ruby #{ruby_scripts_dir}/install_mongo.rb")
    not_if { File.exist?(install_directory) }
  end

  env('PATH') do
    action :modify
    delim ::File::PATH_SEPARATOR
    value 'C:\mongodb\bin'
  end
end

rightscale_marker :end