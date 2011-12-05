require 'rake/clean'

bash 'Deploying websites' do
  code <<-EOF
    rm --recursive --force /var/www/JSPR
    rm --recursive --force /var/www/Compass
    cp -r /DeployScripts/JSPR/* /var/www
    ln -s /var/www/JSPR /var/www/Compass/JSPR
  EOF
end

versioned_folder = FileList['/DeployScripts/JSPR/JSPR/ver*'][0]
rev = versioned_folder.split('ver')[1] unless versioned_folder.nil?
rev ||= '42'

template '/var/www/Compass/settings.js' do
  source 'compass_settings.erb'
  variables(
    :revision => rev,
    :host => node[:deploy][:app_server_host_name]
  )
end