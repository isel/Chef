include_recipe 'core::download_product_artifacts_prereqs'

template "#{node['ruby_scripts_dir']}/download_plugins.rb" do
  local true
  source "#{node['ruby_scripts_dir']}/download_product_artifacts.erb"
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :artifacts => node[:ade_plugins][:plugins_artifacts],
    :target_directory => node[:plugins_directory],
    :revision => node[:ade_plugins][:plugins_revision],
    :s3_bucket => node[:core][:s3_bucket],
    :s3_repository => node[:core][:s3_repository],
    :s3_directory => 'Plugins'
  )
end

powershell "Downloading plugins" do
  source("ruby #{node['ruby_scripts_dir']}/download_plugins.rb")
end

