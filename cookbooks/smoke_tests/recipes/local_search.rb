ruby_scripts_dir = node['ruby_scripts_dir']
elastic_search_plugins = node[:deploy][:elastic_search_plugins]
# temporarily limit the smoke test to site plugins
elastic_search_plugins = join(',', %w(bigdesk head))
log 'temporarily limit the smoke test to site plugins'
log "running smoke test with #{elastic_search_plugins}"


template "#{ruby_scripts_dir}/local_search.rb" do
  source 'scripts/local_search.erb'
  variables(
    :elastic_search_plugins => elastic_search_plugins,
    :elastic_search_port => node[:deploy][:elastic_search_port],
    :server_type => node[:core][:server_type]
  )
end

bash 'Running local smoke tests' do
  code <<-EOF
    rake --rakefile #{ruby_scripts_dir}/local_search.rb
  EOF
end