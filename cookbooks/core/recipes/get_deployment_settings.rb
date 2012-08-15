template "#{node['ruby_scripts_dir']}/get_deployment_settings.rb" do
  source 'scripts/get_deployment_settings.erb'
  variables(
    :api_infrastructure_url => node['core']['api_infrastructure_url'],
    :deployment_uri => node['core']['deployment_uri'],
  )
end

if node[:platform] == "ubuntu"
  bash 'Downloading artifacts' do
    code <<-EOF
      ruby #{node['ruby_scripts_dir']}/get_deployment_settings.rb
    EOF
  end
else
  powershell "Downloading artifacts" do
    source("ruby #{node['ruby_scripts_dir']}/get_deployment_settings.rb")
  end
end

