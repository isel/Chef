ruby_scripts_dir = '/RubyScripts'

template "#{ruby_scripts_dir}/smoke_tests_local.rb" do
  source 'scripts/smoke_tests_local.erb'
  variables(
    :app_server => node[:deploy][:app_server],
    :db_server => node[:deploy][:db_server],
    :sarmus_port => node[:deploy][:sarmus_port],
    :server_type => node[:core][:server_type]
  )
end

if node[:platform] == "ubuntu"
  bash 'Running local smoke tests' do
    code <<-EOF
      rake --rakefile #{ruby_scripts_dir}/smoke_tests_local.rb
    EOF
  end
else
  powershell "Running local smoke tests" do
    source("rake --rakefile #{ruby_scripts_dir}/smoke_tests_local.rb")
  end
end