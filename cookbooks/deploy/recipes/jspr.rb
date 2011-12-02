bash 'Deploying websites' do
  code <<-EOF
    rm --recursive --force /var/www/JSPR
    rm --recursive --force /var/www/Compass
    cp /DeployScripts/JSPR/JSPR/* /var/www/JSPR
    cp /DeployScripts/JSPR/Compass/* /var/www/Compass
    ln -s /var/www/JSPR /var/www/Compass/JSPR
  EOF
end