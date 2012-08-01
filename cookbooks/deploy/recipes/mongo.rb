include_recipe 'core::download_vendor_artifacts_prereqs'

if !File.exists?('/opt/mongo')
  version = node[:deploy][:mongo_version]
  install_directory="/opt/mongo"

  template "#{ruby_scripts_dir}/download_mongo.rb" do
    local true
    source "#{node['ruby_scripts_dir']}/download_vendor_artifacts.erb"
    variables(
      :aws_access_key_id => node[:core][:aws_access_key_id],
      :aws_secret_access_key => node[:core][:aws_secret_access_key],
      :s3_bucket => node[:core][:s3_bucket],
      :s3_repository => 'Vendor',
      :product => 'mongo',
      :version => version,
      :artifacts => 'mongo',
      :target_directory => install_directory
    )
  end
  bash 'Downloading mongo' do
    code <<-EOF
      ruby -rubygems #{ruby_scripts_dir}/download_mongo.rb
    EOF
  end

  bash 'Setting directory links' do
    code <<-EOF
      pushd /opt/mongo
      ln -s #{install_directory} current
      mkdir -p /data/db
    EOF
  end
else
  log 'Mongo already installed.'
end

bash 'Setup log directory on ephemeral drive' do
  code <<-EOF
    mkdir --parents /mnt/logs
  EOF
end

if !File.exists?('/etc/cron.daily/recycle_logs')
  template '/etc/cron.daily/recycle_logs' do
    source 'recycle_logs.erb'
    mode 0755
  end
end


template '/etc/crontab' do
  source 'database_crontab.erb'
  mode 0644
end

bash 'Restarting cron' do
  code <<-EOF
    rm /etc/cron.daily/apt
    service cron restart
  EOF
end

if !File.exists?('/etc/init.d/mongo')
  template '/etc/init.d/mongo' do
    source 'mongo.erb'
    mode 0755
    variables(
      :port => node[:deploy][:db_port]
    )
  end

  bash 'Registering mongo service' do
    code <<-EOF
      update-rc.d mongo defaults
    EOF
  end
else
  log 'Mongo service is already registered.'
end

ruby_block 'Starting mongo service' do
  block do
    puts `service mongo start`

    sleep_time = 5
    done = false
    elapsed = 0
    until done || elapsed >= 300
      sleep sleep_time
      done = `service mongo status`.include?('Mongo is running with pid=')
      elapsed += sleep_time
    end
  end
end