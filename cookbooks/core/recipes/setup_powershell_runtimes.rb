ruby_scripts_dir = node['ruby_scripts_dir']
Dir.mkdir(ruby_scripts_dir) unless File.exist? ruby_scripts_dir

["#{node['core']['powershell_x32_dir']}", "#{node['core']['powershell_x64_dir']}"].each do |dir|
  ['powershell', 'powershell_ise'].each do |app|
    template "#{dir}/#{app}.exe.config" do
      source "#{app}.erb"
    end
  end
end