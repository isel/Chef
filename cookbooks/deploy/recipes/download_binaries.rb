ruby_scripts_dir = node['ruby_scripts_dir']
Dir.mkdir(ruby_scripts_dir) unless File.exist? ruby_scripts_dir

#todo: App Server should not download the models, we need to try removing that artifact

template "#{ruby_scripts_dir}/download_binaries.rb" do
  source 'scripts/download_artifacts.erb'
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :artifacts => node[:deploy][:binaries_artifacts],
    :target_directory => node[:binaries_directory],
    :revision => node[:deploy][:binaries_revision],
    :s3_bucket => node[:core][:s3_bucket],
    :s3_repository => node[:core][:s3_repository],
    :s3_directory => 'Binaries'
  )
end

if node[:platform] == "ubuntu"
  bash 'Downloading artifacts' do
    code <<-EOF
      ruby #{ruby_scripts_dir}/download_binaries.rb
    EOF
  end
else
  powershell "Downloading artifacts" do
    source("ruby #{ruby_scripts_dir}/download_binaries.rb")
  end
end
