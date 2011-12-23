require 'rake/clean'

template '/etc/apache2/conf.d/status.conf' do
  source 'status_conf.erb'
end

bash 'Configuring apache' do
  code <<-EOF
    echo "load the caching expiration module..."
    a2enmod expires

    echo "bouncing apache..."
    service apache2 restart
  EOF
end

bash 'Set document root' do
  code <<-EOF
    mkdir --parents /var/www/Compass

    if grep -q DocumentRoot /etc/apache2/apache2.conf; then
        echo "document root already set"
        exit 0
    fi

    echo "setting document root"
    echo DocumentRoot "/var/www/Compass" >> /etc/apache2/apache2.conf
  EOF
end

bash 'Deploying websites' do
  code <<-EOF
    rm --recursive --force /var/www/JSPR
    rm --recursive --force /var/www/Compass
    rm --recursive --force /var/www/Prios
    cp -r #{node['deploy_scripts_dir']}/JSPR/* /var/www
    ln -s /var/www/JSPR /var/www/Compass/JSPR
  EOF
end

bash 'Deploying prios' do
  code <<-EOF
    mkdir --parents /var/www/Prios/Tests
    cp -r #{node['deploy_scripts_dir']}/Prios/* /var/www/Prios
    cp -r #{node['deploy_scripts_dir']}/PriosUIAutomation/* /var/www/Prios/Tests
  EOF
  only_if { File.exists?("#{node['deploy_scripts_dir']}/Prios") }
end

template '/var/www/Compass/settings.js' do
  source 'compass_settings.erb'
  variables(
    :host => node[:deploy][:app_server]
  )
end

template '/var/www/Prios/Prios.plist' do
  mode "0644"
  source 'prios_plist.erb'
end

template '/var/www/Prios/index.html' do
  mode "0644"
  source 'prios_html.erb'
end

