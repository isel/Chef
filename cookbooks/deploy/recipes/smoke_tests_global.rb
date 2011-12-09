ruby_scripts_dir = '/RubyScripts'

template "#{ruby_scripts_dir}/smoke_tests_global.rb" do
  source 'scripts/smoke_tests_global.erb'
  variables(
    :deployment_name => node[:deploy][:deployment_name]
  )
end

powershell "Running global smoke tests" do
  source("rake --rakefile #{ruby_scripts_dir}/smoke_tests_global.rb")
end