rightscale_marker :begin

windows_task 'Backup TeamCity' do
  user 'Administrator'
  password node[:windows][:administrator_password]
  command 'rs_run_recipe --name "teamcity::web_backup_volumes"'
  run_level :highest
end

rightscale_marker :end
