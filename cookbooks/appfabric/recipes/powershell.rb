template "#{node['ruby_scripts_dir']}/appfabric_powershell.rb" do
  source 'scripts/powershell.erb'
end

powershell "Deploy AppFabric powershell cmdlets" do
  source("ruby #{node['ruby_scripts_dir']}/appfabric_powershell.rb")
end
