binaries_directory = node['binaries_directory']

war = 'droolz'

bash 'stop tomcat' do
  code <<-EOF
    /etc/init.d/tomcat6 stop
  EOF
end

bash 'copy war file' do
  code <<-EOF
    pushd /var/lib/tomcat6/webapps
    rm -f -r #{war}
    cp #{binaries_directory}/Engine/#{war}.war .
    popd
  EOF
end

bash 'start tomcat' do
  code <<-EOF
    export JAVA_OPTS="-DappServer=#{node[:deploy][:app_server]} -DtenantId=#{node[:deploy][:tenant]} -Duser=test@test.com"
    /etc/init.d/tomcat6 start
  EOF
end