include_recipe 'core::download_vendor_artifacts_prereqs'

template "#{node['ruby_scripts_dir']}/download_ruby.rb" do
  local true
  source "#{node['ruby_scripts_dir']}/download_vendor_artifacts.erb"
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :product => 'ruby',
    :version => '1.9.2-p320',
    :filelist => 'ruby'
  )
end

bash 'Install fog' do
  code <<-EOF
    ENV['RUBYGEMS_BINARY_PATH'] ||= 'gem'
    gem install fog -v 1.1.1 --no-rdoc --no-ri
  EOF
end

bash 'Download ruby' do
  code <<-EOF
    /opt/rightscale/sandbox/bin/ruby -rubygems #{node['ruby_scripts_dir']}/download_ruby.rb
  EOF
end
