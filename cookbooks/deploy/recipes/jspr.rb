bash 'Deploying websites' do
  code <<-EOF
    rm --recursive --force /var/www/JSPR
    rm --recursive --force /var/www/Compass
    cp -r /DeployScripts/JSPR/* /var/www
    ln -s /var/www/JSPR /var/www/Compass/JSPR
  EOF
end

jspr_revision = '42'
template '/var/www/Compass/settings.js' do
    source 'compass_settings.erb'
    variables(
      :revision => jspr_revision,
      :host => node[:deploy][:app_server_host_name]
    )
  end