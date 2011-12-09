ruby_scripts_dir = '/RubyScripts'

template "#{ruby_scripts_dir}/smoke_tests.rb" do
  source 'scripts/smoke_tests.erb'
  variables(
    :deployment_name => node[:deploy][:deployment_name],
    :server_type => node[:core][:server_type]
  )
end

powershell "Running smoke tests" do
  source("rake --rakefile #{ruby_scripts_dir}/smoke_tests.rb")
  #source("rake --rakefile #{ruby_scripts_dir}/global_smoke_tests.rb")
end