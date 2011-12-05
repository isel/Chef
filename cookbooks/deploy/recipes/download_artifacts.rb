ruby_scripts_dir = '/RubyScripts'
Dir.mkdir(ruby_scripts_dir) unless Dir.exist? ruby_scripts_dir

template "#{ruby_scripts_dir}/download_artifacts.rb" do
  source 'download_artifacts.erb'
  variables(
    :revision => node[:deploy][:revision],
    :access_key_id => node[:deploy][:aws_access_key_id],
    :secret_access_key => node[:deploy][:aws_secret_access_key]
  )
end

powershell "Downloading artifacts" do
  source("ruby #{ruby_scripts_dir}/download_artifacts.rb")
end