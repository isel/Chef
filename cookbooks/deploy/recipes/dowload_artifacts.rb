
template '/RubyScripts/download_artifacts.rb' do
  source 'download_artifacts.erb'
end

bash "Downloading artifacts" do
  variables(
    :revision => node[:deploy][:revision],
    :access_key_id => node[:deploy][:aws_access_key_id],
    :secret_access_key => node[:deploy][:aws_secret_access_key]
  )
  code <<-EOF
    ruby '/RubyScripts/download_artifacts.rb'
  EOF
end