revision = node[:deploy][:revision]

script "sarmus" do
  interpreter "bash"
  code <<-EOH
    echo 'deploying sarmus'
    sarmus_root='/opt/sarmus'
    mkdir --parents $sarmus_root/#{revision}/bin

    service sarmus_service stop

    rm -r $sarmus_root/current
    ln -s $sarmus_root/#{revision} $sarmus_root/current
    cp /DeployScripts/sarmus/sarmus_service /etc/init.d
    chmod 755 /etc/init.d/sarmus_service

    cp /DeployScripts/sarmus/sarmus $sarmus_root/#{revision}/bin
    chmod 755 /opt/sarmus/current/bin/sarmus

    update-rc.d sarmus_service defaults
    service sarmus_service start
  EOH
end