ruby_scripts_dir = node['ruby_scripts_dir']
Dir.mkdir(ruby_scripts_dir) unless File.exist? ruby_scripts_dir

if !File.exists?('/opt/Mongo')
  version = node[:deploy][:mongo_version]
  install_directory="/opt/Mongo/mongodb-linux-x86_64-#{version}"
  template "#{ruby_scripts_dir}/download_vendor_drop.rb" do
    source 'scripts/download_vendor_drop.erb'
    variables(
      :aws_access_key_id => node[:core][:aws_access_key_id],
      :aws_secret_access_key => node[:core][:aws_secret_access_key],
      :product => 'Mongo',
      :version => version,
      :filelist => 'mongo'
    )
  end
  bash 'Installing vendor drop artifacts' do
    code <<-EOF
      /opt/rightscale/sandbox/bin/ruby -rubygems #{ruby_scripts_dir}/download_vendor_drop.rb
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