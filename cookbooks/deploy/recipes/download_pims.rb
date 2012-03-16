ruby_scripts_dir = node['ruby_scripts_dir']
Dir.mkdir(ruby_scripts_dir) unless File.exist? ruby_scripts_dir

template "#{ruby_scripts_dir}/download_pims.rb" do
  source 'scripts/download_artifacts.erb'
  variables(
    :aws_access_key_id => node[:deploy][:aws_access_key_id],
    :aws_secret_access_key => node[:deploy][:aws_secret_access_key],
    :artifacts => node[:deploy][:pims_artifacts],
    :target_directory => node[:deploy][:pims_deploy_scripts_directory],
    :revision => node[:deploy][:pims_revision],
    :s3_directory => 'PIMs'
  )
end

if node[:platform] == "ubuntu"
  bash 'Downloading artifacts' do
    code <<-EOF
      ruby #{ruby_scripts_dir}/download_pims.rb
    EOF
  end
else
  powershell "Downloading pims artifacts" do
    source("ruby #{ruby_scripts_dir}/download_pims.rb")
  end
end
