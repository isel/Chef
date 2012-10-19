include_recipe 'core::download_product_artifacts_prereqs'

template "#{node[:ruby_scripts_dir]}/download_infrastructure.rb" do
  local true
  source "#{node[:ruby_scripts_dir]}/download_product_artifacts.erb"
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :artifacts => node[:deploy][:infrastructure_artifacts],
    :target_directory => node[:infrastructure_directory],
    :revision => node[:deploy][:infrastructure_revision],
    :s3_bucket => node[:core][:s3_bucket],
    :s3_repository => node[:deploy][:s3_api_repository],
    :s3_directory => 'Services'
  )
end

if node[:platform] == "ubuntu"
  bash 'Downloading artifacts' do
    code <<-EOF
      ruby #{node[:ruby_scripts_dir]}/download_infrastructure.rb
    EOF
  end
else
  powershell "Downloading artifacts" do
    source("ruby #{node[:ruby_scripts_dir]}/download_infrastructure.rb")
  end
end
