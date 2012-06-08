bash 'Installing Passenger prereqs' do
  code <<-EOF
    rvm gem install passenger -v 3.0.12 --no-rdoc --no-ri

    apt-get install -y libcurl4-openssl-dev
    apt-get install -y apache2-prefork-dev
    apt-get install -y libapr1-dev
    apt-get install -y libaprutil1-dev

    sync

    echo ===========================================
    gem list
    export /opt/rvm/bin:/opt/rvm/gems/ruby-1.9.2-head/bin:/opt/rvm/gems/ruby-1.9.2-head@global/bin:/opt/rvm/rubies/ruby-1.9.2-head/bin:/usr/local/bin:/home/ec2/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:$PATH
    echo $PATH
    rvm use default
    rvmsudo passenger-install-apache2-module --auto
    #rvmsudo /opt/rvm/gems/ruby-1.9.2-head/bin/passenger-install-apache2-module --auto
    #apt-get install -y libapache2-mod-passenger
  EOF
end

bash 'Set document root and configure Passenger' do
  code <<-EOF
    if grep -q DocumentRoot /etc/apache2/apache2.conf; then
        echo "document root already set"
        exit 0
    fi

    echo LoadModule passenger_module /opt/rvm/gems/ruby-1.9.2-head/gems/passenger-3.0.12/ext/apache2/mod_passenger.so >> /etc/apache2/apache2.conf
    echo PassengerRoot /opt/rvm/gems/ruby-1.9.2-head/gems/passenger-3.0.12 >> /etc/apache2/apache2.conf
    echo PassengerRuby /opt/rvm/wrappers/ruby-1.9.2-head/ruby >> /etc/apache2/apache2.conf
    echo PassengerDefaultUser www-data >> /etc/apache2/apache2.conf

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
    chmod --recursive 0666 /var/www/api/log
    chown --recursive www-data:www-data /var/www/api/log

    cd /var/www/api
    bundle install

    echo restarting apache
    service apache2 restart
  EOF
end

