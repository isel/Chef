if !File.exists?('/opt/Mongo')
  version = node[:deploy][:mongo_version]
  install_directory="/opt/Mongo/mongodb-linux-x86_64-#{version}"
  template "#{ruby_scripts_dir}/download_vendor_drop.rb" do
    source 'scripts/download_vendor_drop.erb'
    variables(
      :aws_access_key_id => node[:deploy][:aws_access_key_id],
      :aws_secret_access_key => node[:deploy][:aws_secret_access_key],
      :install_dir => install_dir,
      :product => 'Mongo',
      :version => version,
      :filelist => 'mongo',
      :no_explode => '0'
    )
  end
  bash 'Installing vendor drop artifacts' do
    code <<-EOF
      ruby #{ruby_scripts_dir}/download_vendor_drop.rb
    EOF
  end

  bash 'Setting directory links' do
    code <<-EOF
      pushd /opt/Mongo
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

bash 'Starting mongo service' do
  code <<-EOF
    service mongo start
  EOF
end