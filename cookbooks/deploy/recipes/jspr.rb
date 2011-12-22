require 'rake/clean'

bash 'Deploying websites' do
  code <<-EOF
    rm --recursive --force /var/www/JSPR
    rm --recursive --force /var/www/Compass
    cp -r #{node['deploy_scripts_dir']}/JSPR/* /var/www
    ln -s /var/www/JSPR /var/www/Compass/JSPR

    cp -r #{node['deploy_scripts_dir']}/Prios/* /var/www/Compass
  EOF
end

template '/var/www/Compass/settings.js' do
  source 'compass_settings.erb'
  variables(
    :host => node[:deploy][:app_server]
  )
end

template '/var/www/Compass/Prios.plist' do
  source 'prios_plist.erb'
end

template '/var/www/Compass/Prios.html' do
  source 'prios_html.erb'
end

