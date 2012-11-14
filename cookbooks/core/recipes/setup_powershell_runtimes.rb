rightscale_marker :begin

ruby_scripts_dir = node[:ruby_scripts_dir]
Dir.mkdir(ruby_scripts_dir) unless File.exist? ruby_scripts_dir

["#{node[:powershell_x32_dir]}", "#{node[:powershell_x64_dir]}"].each do |dir|
  ['powershell', 'powershell_ise'].each do |app|
    template "#{dir}/#{app}.exe.config" do
      source 'powershell.erb'
    end
  end
end

rightscale_marker :end