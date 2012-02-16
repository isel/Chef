ruby_scripts_dir = node['ruby_scripts_dir']
deploy_scripts_dir = node['deploy_scripts_dir']

war = 'engine'

bash 'stop tomcat' do
  code <<-EOF
    /etc/init.d/tomcat6 stop
  EOF
end

bash 'copy war file' do
  code <<-EOF
    pushd /var/lib/tomcat6/webapps
    rm -f -r #{war}
    cp #{deploy_scripts_dir}/Engine/#{war}.war .
    popd
  EOF
end

bash 'start tomcat' do
  code <<-EOF
    export JAVA_OPTS=-DappServer=#{node[:deploy][:app_server]}
    /etc/init.d/tomcat6 start
  EOF
end