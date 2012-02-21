require 'rake'

destination_dirs = [
  "#{node['powershell_x32_dir']}/Modules/AppFabricPowershell",
  "#{node['powershell_x64_dir']}/Modules/AppFabricPowershell"
]

destination_dirs.each do |dir|
  FileUtils.remove_dir(dir, true)
  FileUtils.mkdir_p(dir)
  FileUtils.cp_r("#{node['deploy_scripts_dir']}/AppFabricPowershell/.", dir)
end
