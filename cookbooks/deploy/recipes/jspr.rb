bash 'Deploying websites' do
  code <<-EOF
    rm --recursive --force /var/www/JSPR
    rm --recursive --force /var/www/Compass
    cp -r /DeployScripts/JSPR/* /var/www
    ln -s /var/www/JSPR /var/www/Compass/JSPR
  EOF
end