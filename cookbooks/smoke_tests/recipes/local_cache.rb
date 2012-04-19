ruby_scripts_dir = node['ruby_scripts_dir']

template "#{ruby_scripts_dir}/local_cache.rb" do
  source 'scripts/local_cache.erb'
  variables(:server_type => node[:core][:server_type])
end

powershell "Running local smoke tests" do
  source("rake --rakefile #{ruby_scripts_dir}/local_cache.rb")
end