include_recipe 'core::download_vendor_artifacts_prereqs'

if !File.exists?('/usr/local/mongodb')
  version = node[:deploy][:mongo_version]

  template "#{node['ruby_scripts_dir']}/download_mongo.rb" do
    local true
    source "#{node['ruby_scripts_dir']}/download_vendor_artifacts.erb"
    variables(
      :aws_access_key_id => node[:core][:aws_access_key_id],
      :aws_secret_access_key => node[:core][:aws_secret_access_key],
      :s3_bucket => node[:core][:s3_bucket],
      :s3_repository => 'Vendor',
      :product => 'mongo',
      :version => version,
      :artifacts => 'mongo',
      :target_directory => '/usr/local',
      :unzip => true
    )
  end

  bash 'Downloading mongo' do
    code <<-EOF
      ruby #{node['ruby_scripts_dir']}/download_mongo.rb
      mv /usr/local/mongo /usr/local/mongodb
      chmod a+x /usr/local/mongodb/bin/*
    EOF
  end
else
  log 'Mongo already downloaded.'
end
