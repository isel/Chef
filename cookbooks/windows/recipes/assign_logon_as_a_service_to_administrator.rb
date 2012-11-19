directory '/tools' do
  action :create
end

cookbook_file "/tools/ntrights.exe" do
  source "ntrights.exe"
end

windows_batch "assign logon as a service to administrator" do
  code 'c:\tools\ntrights.exe +r SeServiceLogonRight -u Administrator'
end