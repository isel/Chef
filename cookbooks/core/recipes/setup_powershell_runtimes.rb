ruby_scripts_dir = node['ruby_scripts_dir']
Dir.mkdir(ruby_scripts_dir) unless File.exist? ruby_scripts_dir

template "/Windows/System32/WindowsPowerShell/v1.0/powershell.exe.xml" do
  source 'powershell.erb'
end

template "/Windows/System32/WindowsPowerShell/v1.0/powershell_ise.exe.xml" do
  source 'powershell.erb'
end

`powershell Copy-Item \\Windows\\SysWow64\\WindowsPowerShell\\v1.0\\powershell.exe.xml \\Windows\\System32\\WindowsPowerShell\\v1.0\\`
`powershell Copy-Item \\Windows\\SysWow64\\WindowsPowerShell\\v1.0\\powershell_ise.exe.xml \\Windows\\System32\\WindowsPowerShell\\v1.0\\`