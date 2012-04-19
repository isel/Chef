ruby_scripts_dir = node['ruby_scripts_dir']

template "#{ruby_scripts_dir}/local_db.rb" do
  source 'scripts/local_db.erb'
  variables(:server_type => node[:core][:server_type])
end

bash 'Running local smoke tests' do
  code <<-EOF
    rake --rakefile #{ruby_scripts_dir}/local_db.rb
  EOF
end
