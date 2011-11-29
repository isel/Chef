node[:gems].each do |gem|
  gem_package gem[:name] do
    action :install
  end
end