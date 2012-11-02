rightscale_marker :begin

ruby_scripts_dir = node[:ruby_scripts_dir]

template "#{ruby_scripts_dir}/smoke_tests_spec.rb" do
  source 'smoke_tests_spec.erb'
end

template "#{ruby_scripts_dir}/smoke_tests.rb" do
  source 'scripts/smoke_tests.erb'
end

bash 'Running smoke tests' do
  code <<-EOF
    rake --rakefile #{ruby_scripts_dir}/smoke_tests.rb
  EOF
end

rightscale_marker :end
