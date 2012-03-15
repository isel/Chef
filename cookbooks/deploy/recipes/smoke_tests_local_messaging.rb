ruby_scripts_dir = node['ruby_scripts_dir']

template "#{ruby_scripts_dir}/smoke_tests_local_messaging.rb" do
  source 'scripts/smoke_tests_local_messaging.erb'
  variables(
    :mule_port => node[:deploy][:mule_port],
    :activemq_port => node[:deploy][:activemq_port]
  )
end

powershell "Running local smoke tests" do
  source("rake --rakefile #{ruby_scripts_dir}/smoke_tests_local_messaging.rb")
end