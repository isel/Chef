template "#{node['ruby_scripts_dir']}/local_search.rb" do
  source 'scripts/local_search.erb'
  variables(
    :search_port => node[:search_port],
    :server_type => node[:core][:server_type]
  )
end

bash 'Running local smoke tests' do
  code <<-EOF
    rake --rakefile #{node['ruby_scripts_dir']}/local_search.rb
  EOF
end