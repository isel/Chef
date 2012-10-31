include_recipe 'core::download_product_artifacts_prereqs'

template "#{node[:ruby_scripts_dir]}/download_metadata.rb" do
  local true
  source "#{node[:ruby_scripts_dir]}/download_product_artifacts.erb"
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :artifacts => node[:deploy][:metadata_artifacts],
    :target_directory => node[:metadata_directory],
    :revision => node[:deploy][:metadata_revision],
    :s3_bucket => node[:core][:s3_bucket],
    :s3_repository => node[:core][:s3_repository],
    :s3_directory => 'Metadata'
  )
end

powershell "Downloading metadata" do
  source("ruby #{node[:ruby_scripts_dir]}/download_metadata.rb")
end

include_recipe 'appfabric::clear_all_caches'

#todo: register errors on provision using the api service
template "#{node[:ruby_scripts_dir]}/provision.rb" do
  source 'scripts/provision.erb'
  variables(
    :tenant => node[:deploy][:tenant],
    :db_user => node[:deploy][:admin_user_mongo],
    :db_password => node[:deploy][:admin_password_mongo]
  )
end

powershell "Provisioning data" do
  source("ruby #{node[:ruby_scripts_dir]}/provision.rb")
end