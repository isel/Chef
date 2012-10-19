template "#{node[:ruby_scripts_dir]}/sanity_app.rb" do
  source 'scripts/sanity_app.erb'
  variables(:server_type => node[:core][:server_type])
end

powershell "Running local smoke tests" do
  source("rake --rakefile #{node[:ruby_scripts_dir]}/sanity_app.rb")
end