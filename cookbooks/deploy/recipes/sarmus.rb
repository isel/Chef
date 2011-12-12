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
    cp #{node['deploy_scripts_dir']}/sarmus/sarmus_service /etc/init.d
    chmod 755 /etc/init.d/sarmus_service

    cp #{node['deploy_scripts_dir']}/sarmus/sarmus $sarmus_root/#{revision}/bin
    chmod 755 /opt/sarmus/current/bin/sarmus

    update-rc.d sarmus_service defaults
    service sarmus_service start
  EOF
end
