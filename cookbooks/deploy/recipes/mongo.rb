Chef::Log.info('Registering and/or starting Mongo service')

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