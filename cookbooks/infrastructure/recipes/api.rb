bash 'Set document root and configure Passenger' do
  code <<-EOF
    if grep -q DocumentRoot /etc/apache2/apache2.conf; then
        echo "document root already set"
        exit 0
    fi

    echo LoadModule passenger_module /opt/passenger-3.0.12/ext/apache2/mod_passenger.so >> /etc/apache2/apache2.conf
    echo PassengerRoot /opt/passenger-3.0.12 >> /etc/apache2/apache2.conf
    echo PassengerRuby /opt/rvm/wrappers/ruby-1.9.2-head/ruby >> /etc/apache2/apache2.conf
    echo PassengerDefaultUser root >> /etc/apache2/apache2.conf

    echo DocumentRoot "/var/www/api/public" >> /etc/apache2/apache2.conf
  EOF
end

template '/etc/apache2/conf.d/status.conf' do
  source 'status_conf.erb'
end

bash 'Setting up website' do
  code <<-EOF
    mkdir --parents /var/www/api
    cp -r #{node['infrastructure_directory']}/InfrastructureServices/* /var/www/api

    echo "" >> /var/www/api/log/production.log
    echo "" >> /var/www/api/log/rest.log
    chmod --recursive 0666 /var/www/api/log
    chown --recursive www-data:www-data /var/www/api/log

    cd /var/www/api

    echo "##### PATH #####"
    echo $PATH
    echo "##### PATH #####"

    echo "running bundle install"
    /opt/rvm/gems/ruby-1.9.2-head/bin/bundle install

    echo "running gem list"
    gem list

    service apache2 restart
  EOF
end

