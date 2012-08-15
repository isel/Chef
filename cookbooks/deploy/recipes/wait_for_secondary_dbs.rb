template "#{node['ruby_scripts_dir']}/wait_for_secondary_dbs.rb" do
  source 'scripts/wait_for_secondary_dbs.erb'
  variables(
      :deployment_name => node[:deploy][:deployment_name],
      :timeout => '30*60'
  )
end

bash 'Waiting for secondary dbs to be operational' do
  code <<-EOF
    ruby #{node['ruby_scripts_dir']}/wait_for_secondary_dbs.rb
  EOF
  only_if { node[:deploy][:is_primary_db] == 'true' }
end