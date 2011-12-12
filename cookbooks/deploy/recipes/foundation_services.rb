require 'rake'

ruby_scripts_dir = node['ruby_scripts_dir']

template "#{ruby_scripts_dir}/foundation_services.rb" do
  source 'scripts/foundation_services.erb'
  variables(
    :cache_server => node[:deploy][:cache_server],
    :db_server => node[:deploy][:db_server],
    :elastic_search_port => node[:deploy][:elastic_search_port],
    :sarmus_port => node[:deploy][:sarmus_port]
  )
end

powershell "Updating foundation services" do
  source("ruby #{ruby_scripts_dir}/foundation_services.rb")
end
