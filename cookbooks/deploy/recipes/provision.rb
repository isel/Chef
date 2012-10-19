include_recipe 'core::download_product_artifacts_prereqs'

template "#{node['ruby_scripts_dir']}/download_pims.rb" do
  local true
  source "#{node['ruby_scripts_dir']}/download_product_artifacts.erb"
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :artifacts => node[:deploy][:pims_artifacts],
    :target_directory => node[:pims_directory],
    :revision => node[:deploy][:pims_revision],
    :s3_bucket => node[:core][:s3_bucket],
    :s3_repository => node[:core][:s3_repository],
    :s3_directory => 'PIMs'
  )
end

powershell "Downloading pims artifacts" do
  source("ruby #{node['ruby_scripts_dir']}/download_pims.rb")
end

include_recipe 'appfabric::clear_all_caches'

#todo: register errors on provision using the api service
template "#{node['ruby_scripts_dir']}/provision.rb" do
  source 'scripts/provision.erb'
  variables(
    :app_server => node[:deploy][:app_server],
    :db_server => node[:deploy][:db_server],
    :tenant => node[:deploy][:tenant]
  )
end

powershell "Provisioning data" do
  source("ruby #{node['ruby_scripts_dir']}/provision.rb")
end