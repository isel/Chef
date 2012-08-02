ruby_scripts_dir = node['ruby_scripts_dir']

template "#{ruby_scripts_dir}/appfabric_powershell.rb" do
  source 'scripts/appfabric_powershell.erb'
end

powershell "Deploy AppFabric powershell cmdlets" do
  source("ruby #{ruby_scripts_dir}/appfabric_powershell.rb")
end
