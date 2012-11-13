rightscale_marker :begin

ruby_scripts_dir = node[:ruby_scripts_dir]

template "#{ruby_scripts_dir}/local_db.rb" do
  source 'scripts/local_db.erb'
  variables(
    :admin_password_mongo => node[:deploy][:admin_password_mongo],
    :admin_user_mongo => node[:deploy][:admin_user_mongo],
    :server_type => node[:core][:server_type]
  )
  only_if { node[:deploy][:is_primary_db] == 'true' }
end

bash 'Running local smoke tests' do
  code <<-EOF
    rake --rakefile #{ruby_scripts_dir}/local_db.rb
  EOF
  only_if { node[:deploy][:is_primary_db] == 'true' }
end

rightscale_marker :end