template "#{node['ruby_scripts_dir']}/wait_for_server_with_tag.rb" do
  source 'scripts/wait_for_server_with_tag.erb'
  variables(
    :deployment_name => node[:deploy][:deployment_name],
    :tag_key => node[:deploy][:tag_key],
    :tag_value => node[:deploy][:tag_value],
    :timeout => '30*60'
  )
end

if node[:platform] == "ubuntu"
  bash "Waiting for server with tag: #{node[:deploy][:tag_key]}" do
    code <<-EOF
        ruby #{node['ruby_scripts_dir']}/wait_for_server_with_tag.rb
    EOF
    only_if { node[:deploy][:tag_key] && node[:deploy][:tag_value] }
  end
else
  powershell "Waiting for server with tag: #{node[:deploy][:tag_key]}" do
    source("ruby #{node['ruby_scripts_dir']}/wait_for_server_with_tag.rb")
    only_if { node[:deploy][:tag_key] && node[:deploy][:tag_value] }
  end
end