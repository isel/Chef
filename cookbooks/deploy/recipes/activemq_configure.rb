bash 'launch activemq' do
  code <<-EOF
  cd /opt/activemq/bin
  /usr/bin/nohup ./activemq start > /var/log/smlog 2>&1 &
  EOF
end

template("#{node[:ruby_scripts_dir]}/wait_for_activemq.rb") { source 'scripts/wait_for_activemq.erb' }

bash('wait for activemq') { code "ruby #{node[:ruby_scripts_dir]}/wait_for_activemq.rb" }
