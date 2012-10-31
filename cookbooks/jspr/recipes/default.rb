require 'rake/clean'

template '/etc/apache2/conf.d/status.conf' do
  source 'status_conf.erb'
end

bash 'Configuring apache' do
  code <<-EOF
    mkdir --parents /var/www/App

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
    echo DocumentRoot "/var/www/App" >> /etc/apache2/apache2.conf
  EOF
end

bash 'Deploying websites' do
  code <<-EOF
    rm --recursive --force /var/www/JSPR
    rm --recursive --force /var/www/App

#temporary until we get an app...
    mkdir --parents /var/www/App

    cp -r #{node[:binaries_directory]}/JSPR/* /var/www
    ln -s /var/www/JSPR /var/www/App/JSPR
  EOF
end

bash 'Deploying UIAutomation' do
  code <<-EOF
    rm --recursive --force /var/www/Tests

    mkdir --parents /var/www/Tests

    cp -r #{node[:binaries_directory]}/UIAutomation/* /var/www/Tests
    cp #{node[:binaries_directory]}/UIAutomation/.* /var/www/Tests
    ls #{node[:binaries_directory]}/JSPR/JSPR* > /var/www/Tests/jspr_version

    version=`cat /var/www/Prios/Tests/jspr_version`
    sed -i "s@/JSPR/ver1/@/JSPR/$version/@" /var/www/Tests/jstestload.html
  EOF
end

template '/var/www/App/settings.js' do
  mode "0644"
  source 'settings.erb'
  variables(
    :domain => node[:deploy][:domain].nil? ? node[:ipaddress] : node[:deploy][:domain],
    :host => node[:deploy][:app_server],
    :tenant => node[:deploy][:tenant]
  )
end

template '/var/www/Tests/settings.js' do
  mode "0644"
  source 'tests_settings.erb'
  variables(
    :domain => node[:deploy][:domain].nil? ? node[:ipaddress] : node[:deploy][:domain],
    :host => node[:deploy][:domain].nil? ? node[:ipaddress] : "www.#{node[:deploy][:domain]}"
  )
end

bash('Restarting apache') { code 'service apache2 restart' }
