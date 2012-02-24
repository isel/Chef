if !File.exists?('/opt/Mongo')
  version = node[:deploy][:mongo_version]
  bash 'Installing Mongo' do
    code <<-EOF
      mkdir --parents /opt/Mongo
      cd /opt/Mongo

      curl http://downloads.mongodb.org/linux/mongodb-linux-x86_64-#{version}.tgz > mongo.tgz
      tar xvfz mongo.tgz
      ln -s /opt/Mongo/mongodb-linux-x86_64-#{version} /opt/Mongo/current

      mkdir --parents /data/db
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
    service cron restart
  EOF
end

if !File.exists?('/etc/init.d/mongo')
  template '/etc/init.d/mongo' do
    source 'mongo.erb'
    mode 0755
    variables(
      :port => node[:deploy][:mongo_port]
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