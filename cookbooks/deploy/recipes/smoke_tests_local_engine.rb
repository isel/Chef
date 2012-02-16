ruby_scripts_dir = node['ruby_scripts_dir']

template "#{ruby_scripts_dir}/smoke_tests_local_engine.rb" do
  source 'scripts/smoke_tests_local_engine.erb'
  variables(
    :app_server => node[:deploy][:app_server],
    :server_type => node[:core][:server_type]
  )
end

bash 'Running local smoke tests' do
  code <<-EOF
    rake --rakefile #{ruby_scripts_dir}/smoke_tests_local_engine.rb
  EOF
end
