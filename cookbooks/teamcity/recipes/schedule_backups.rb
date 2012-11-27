rightscale_marker :begin

windows_task 'Schedule backups' do
  user 'Administrator'
  password node[:windows][:administrator_password]
  command 'rs_run_recipe --name "teamcity::back_volumes"'
  run_level :highest
end

rightscale_marker :end
