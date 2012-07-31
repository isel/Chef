ruby_scripts_dir = node['ruby_scripts_dir']
Dir.mkdir(ruby_scripts_dir) unless File.exist? ruby_scripts_dir

cookbook_file "#{ruby_scripts_dir}/download_vendor_drop.erb" do
  source "scripts/download_vendor_drop.erb" # this is the value that would be inferred from the path parameter
  mode "0644"
  cookbook "deploy"
end

template "#{ruby_scripts_dir}/download_ruby.rb" do
  source "#{ruby_scripts_dir}/download_vendor_drop.erb"
  variables(
    :aws_access_key_id => node[:deploy][:aws_access_key_id],
    :aws_secret_access_key => node[:deploy][:aws_secret_access_key],
    :product => 'ruby',
    :version => '1.9.2-p320',
    :filelist => 'ruby'
  )
end
