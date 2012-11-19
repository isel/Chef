powershell "change administrator password" do
  script = <<-EOH
    net user administrator #{node[:windows_examples][:administrator_password]}
    wmic UserAccount where "Name='administrator'" set PasswordExpires=false
  EOH
  source(script)
end