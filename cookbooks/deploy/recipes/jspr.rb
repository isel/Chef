require 'rake/clean'

bash 'Deploying websites' do
  code <<-EOF
    rm --recursive --force /var/www/JSPR
    rm --recursive --force /var/www/Compass
    cp -r /DeployScripts/JSPR/* /var/www
    ln -s /var/www/JSPR /var/www/Compass/JSPR
  EOF
end

template '/var/www/Compass/settings.js' do
  source 'compass_settings.erb'
  variables(
    :host => node[:deploy][:app_server]
  )
end
