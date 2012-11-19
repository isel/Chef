windows_batch "change administrator password" do
  code <<-EOH
    net user administrator #{node[:windows][:administrator_password]}
    wmic UserAccount where "Name='administrator'" set PasswordExpires=false
  EOH
end