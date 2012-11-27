rightscale_marker :begin

template "d:\\create_database.sql" do
  source 'create_database.erb'
  variables(
    :database_user => node[:teamcity][:database_user],
    :database_password => node[:teamcity][:database_password]
  )
end

windows_batch 'Create TeamCity database' do
  code "sqlcmd -Usa -P#{node[:mssql][:sa_password]} -id:\\create_database.sql"
end

rightscale_marker :end