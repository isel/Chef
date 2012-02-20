ruby_scripts_dir = node['ruby_scripts_dir']
Dir.mkdir(ruby_scripts_dir) unless File.exist? ruby_scripts_dir

template "/Windows/sysnative/WindowsPowerShell/v1.0/powershell.exe.config" do
  source 'powershell.erb'
end

template "/Windows/system32/WindowsPowerShell/v1.0/powershell.exe.config" do
  source 'powershell.erb'
end

template "/Windows/sysnative/WindowsPowerShell/v1.0/powershell_ise.exe.config" do
  source 'powershell.erb'
end

template "/Windows/system32/WindowsPowerShell/v1.0/powershell_ise.exe.config" do
  source 'powershell.erb'
end