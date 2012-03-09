revision = node[:deploy][:revision]

script "Deploy sarmus" do
  interpreter "bash"
  code <<-EOF
    echo 'deploying sarmus'
    sarmus_root='/opt/sarmus'

    if [ -e $sarmus_root ]; then
      service sarmus_service stop
      rm -r $sarmus_root/current
    fi

    mkdir --parents $sarmus_root/#{revision}/bin

    ln -s $sarmus_root/#{revision} $sarmus_root/current

    cp #{node['deploy_scripts_dir']}/sarmus/sarmus $sarmus_root/#{revision}/bin
    chmod 755 /opt/sarmus/current/bin/sarmus
  EOF
end

bash 'Setup log directory on ephemeral drive' do
  code <<-EOF
    mkdir --parents /mnt/logs
  EOF
end

if !File.exists?('/etc/init.d/sarmus_service')
  template '/etc/init.d/sarmus_service' do
    source 'sarmus_service.erb'
    variables(
      :sarmus_logsize  => node[:deploy][:sarmus_logsize],
      :sarmus_loglevel => node[:deploy][:sarmus_loglevel]
      )
    mode 0755
  end

  script 'Registering sarmus_service service' do
    interpreter "bash"
    code <<-EOF
      update-rc.d sarmus_service defaults
    EOF
  end
else
  log 'sarmus_service service is already registered.'
end

if !File.exists?('/etc/cron.daily/sarmus_logs_cleanup')
  template '/etc/cron.daily/sarmus_logs_cleanup' do
    source 'sarmus_logs_cleanup.erb'
    variables(
      :sarmus_days_to_keep_logs  => node[:deploy][:sarmus_days_to_keep_logs]
      )
    mode 0755
  end
end

bash 'Starting sarmus_service service' do
  code <<-EOF
    service sarmus_service start
  EOF
end