require 'rake/clean'

template '/etc/apache2/conf.d/status.conf' do
  source 'status_conf.erb'
  variables(:use_mocked_website => node[:deploy][:use_mocked_website])
end

bash 'Configuring apache' do
  code <<-EOF
    mkdir --parents /var/www/Compass

    echo "load the caching expiration module..."
    a2enmod expires

    echo "installing php..."
    apt-get install -y php5 libapache2-mod-php5
    a2enmod php5

    echo "bouncing apache..."
    service apache2 restart
  EOF
end

bash 'Set document root' do
  code <<-EOF
    if grep -q DocumentRoot /etc/apache2/apache2.conf; then
        echo "document root already set"
        exit 0
    fi

    echo "setting document root"
    echo DocumentRoot "/var/www/Compass" >> /etc/apache2/apache2.conf

    echo "bouncing apache..."
    service apache2 restart
  EOF
end

bash 'Deploying websites' do
  code <<-EOF
    rm --recursive --force /var/www/JSPR
    rm --recursive --force /var/www/Compass
    rm --recursive --force /var/www/Prios
    cp -r #{node['binaries_directory']}/JSPR/* /var/www
    ln -s /var/www/JSPR /var/www/Compass/JSPR
  EOF
end

bash 'Deploying prios' do
  code <<-EOF
    mkdir --parents /var/www/Prios/Tests
    cp -r #{node['binaries_directory']}/Prios/* /var/www/Prios
    cp -r #{node['binaries_directory']}/PriosUIAutomation/* /var/www/Prios/Tests
    ls #{node['binaries_directory']}/JSPR/JSPR* > /var/www/Prios/Tests/jspr_version
    version=`cat /var/www/Prios/Tests/jspr_version`
    sed -i "s@/JSPR/ver1/@/JSPR/$version/@" /var/www/Prios/Tests/jstestload.html
  EOF
  only_if { File.exists?("#{node['binaries_directory']}/Prios") }
end

template '/var/www/Compass/settings.js' do
  mode "0644"
  source 'compass_settings.erb'
  variables(
    :host => node[:deploy][:app_server]
  )
end

template '/var/www/Prios/Tests/settings.js' do
  mode "0644"
  source 'compass_settings.erb'
  variables(
    :host => "#{ node[:deploy][:domain].nil? ? node[:ipaddress] : "www.#{node[:deploy][:domain]}" }/Prios/Tests"
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

