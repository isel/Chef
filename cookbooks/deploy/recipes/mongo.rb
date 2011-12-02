if !Dir.exists?('/opt/Mongo')
  version = [:deploy][:mongo_version]
  bash 'Installing Mongo' do
    code <<-EOF
      mkdir --parents /opt/Mongo
      cd /opt/Mongo

      curl http://downloads.mongodb.org/linux/mongodb-linux-x86_64-#{version}.tgz > mongo.tgz
      tar xvfz mongo.tgz
      ln -s /opt/Mongo/mongodb-linux-x86_64-#{version} /opt/Mongo/current

      mkdir --parents /data/db
      mkdir --parents /var/log
    EOF
  end
else
  Chef::Log.info('Mongo already installed.')
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
  Chef::Log.info('Mongo service is already registered.')
end

bash 'Starting mongo service' do
  code <<-EOF
    service mongo start
  EOF
end