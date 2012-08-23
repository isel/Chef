template "#{node['ruby_scripts_dir']}/download_pims.rb" do
  source 'scripts/download_artifacts.erb'
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :artifacts => node[:deploy][:pims_artifacts],
    :target_directory => node[:pims_directory],
    :revision => node[:deploy][:pims_revision],
    :s3_bucket => node[:deploy][:s3_bucket],
    :s3_repository => node[:deploy][:s3_repository],
    :s3_directory => 'PIMs'
  )
end

if node[:platform] == "ubuntu"
  bash 'Downloading artifacts' do
    code "ruby #{node['ruby_scripts_dir']}/download_pims.rb"
  end
else
  powershell "Downloading pims artifacts" do
    source("ruby #{node['ruby_scripts_dir']}/download_pims.rb")
  end
end

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