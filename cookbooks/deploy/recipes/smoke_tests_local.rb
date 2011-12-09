ruby_scripts_dir = '/RubyScripts'

template "#{ruby_scripts_dir}/smoke_tests_local.rb" do
  source 'scripts/smoke_tests_local.erb'
  variables(
    :app_server => node[:deploy][:app_server],
    :server_type => node[:core][:server_type]
  )
  only_if { ['web'].include?(node[:core][:server_type]) }
end

powershell "Running local smoke tests" do
  source("rake --rakefile #{ruby_scripts_dir}/smoke_tests_local.rb")
  only_if { ['web'].include?(node[:core][:server_type]) }
end