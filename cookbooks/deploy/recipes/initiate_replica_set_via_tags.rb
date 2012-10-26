template "#{node[:ruby_scripts_dir]}/initiate_replica_set_via_tags.rb" do
  source 'scripts/initiate_replica_set_via_tags.erb'
  variables(
      :deployment_name => node[:deploy][:deployment_name],
      :server_name => node[:deploy][:server_name]
  )
  only_if { node[:deploy][:is_primary_db] == 'true' && node[:deploy][:use_replication] == 'true' }
end

bash 'Initiate replica set via tags' do
  code <<-EOF
    ruby #{node[:ruby_scripts_dir]}/initiate_replica_set_via_tags.rb
    sleep 2m
  EOF
  only_if { node[:deploy][:is_primary_db] == 'true' && node[:deploy][:use_replication] == 'true' }
end