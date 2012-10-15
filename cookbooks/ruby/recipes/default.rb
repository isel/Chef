include_recipe 'core::download_vendor_artifacts_prereqs'

rs_ruby_path = '/Program Files (x86)/RightScale/RightLink/sandbox/ruby/bin'

template "#{node['ruby_scripts_dir']}/download_ruby.rb" do
  local true
  source "#{node['ruby_scripts_dir']}/download_vendor_artifacts.erb"
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :s3_bucket => node[:core][:s3_bucket],
    :s3_repository => 'Vendor',
    :product => 'ruby',
    :version => '1.9.2-p320',
    :artifacts => 'ruby_windows',
    :target_directory => '/installs',
    :unzip => true
  )
  not_if { File.exist?('/installs/ruby_windows.zip') }
end

powershell 'Install fog and download ruby' do
  script = <<'EOF'
    cd "c:\\Program Files (x86)\\RightScale\\RightLink\\sandbox\\ruby\\bin"
    cmd /c gem install fog -v 1.1.1 --no-rdoc --no-ri
    cmd /c ruby -rubygems #{node['ruby_scripts_dir']}/download_ruby.rb"
EOF
  source(script)
  not_if { File.exist?('/installs/ruby_windows.zip') }
end

powershell 'Install ruby' do
  source('c:\installs\ruby_windows\rubyinstaller-1.9.2-p0.exe /tasks=modpath /silent')
  not_if { File.exist?('/Ruby192') }
end
