template '/RubyScripts/download_artifacts.rb' do
  source 'download_artifacts.erb'
  variables(
    :revision => node[:deploy][:revision],
    :access_key_id => node[:deploy][:aws_access_key_id],
    :secret_access_key => node[:deploy][:aws_secret_access_key]
  )
end

powershell "Downloading artifacts" do
  code <<-EOF
    ruby '/RubyScripts/download_artifacts.rb'
  EOF
end