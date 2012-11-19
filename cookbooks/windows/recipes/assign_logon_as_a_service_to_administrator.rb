cookbook_file "tools/ntrights.exe" do
  source "ntrights.exe"
end

windows_batch "assign logon as a service to administrator" do
  code 'ntrights +r SeServiceLogonRight -u Administrator'
end