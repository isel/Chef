ruby_scripts_dir = node[:ruby_scripts_dir]
Dir.mkdir(ruby_scripts_dir) unless File.exist? ruby_scripts_dir

cookbook_file "#{ruby_scripts_dir}/download_vendor_artifacts.erb" do
  source "download_vendor_artifacts.erb" # this is the value that would be inferred from the path parameter
  mode "0644"
end