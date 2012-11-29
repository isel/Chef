windows_batch 'Set sa password' do
  code "sqlcmd -E -Q\"ALTER LOGIN [sa] WITH PASSWORD='#{node[:mssql][:sa_password]}'\""
end
