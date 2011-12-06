ruby_scripts_dir = '/RubyScripts'
Dir.mkdir(ruby_scripts_dir) unless File.exist? ruby_scripts_dir

template "#{ruby_scripts_dir}/download_artifacts.rb" do
  source 'scripts/download_artifacts.erb'
  variables(
    :revision => node[:deploy][:revision],
    :access_key_id => node[:deploy][:aws_access_key_id],
    :secret_access_key => node[:deploy][:aws_secret_access_key],
    :artifacts => node[:deploy][:artifacts]
  )
end

if node[:platform] == "ubuntu"
  bash 'Downloading artifacts' do
    code <<-EOF
      ruby #{ruby_scripts_dir}/download_artifacts.rb
    EOF
  end
else
  powershell "Downloading artifacts" do
    source("ruby #{ruby_scripts_dir}/download_artifacts.rb")
  end
end
