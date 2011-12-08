ruby_scripts_dir = '/RubyScripts'

template "#{ruby_scripts_dir}/smoke_tests.rb" do
  source 'scripts/smoke_tests.erb'
  variables(
    :deployment_name => node[:deploy][:deployment_name]
  )
end

powershell "Running smoke tests" do
  source("ruby #{ruby_scripts_dir}/smoke_tests.rb")
end