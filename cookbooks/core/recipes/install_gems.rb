Chef::Log.info(`gem update --system`)

gems = node[:gems]
Chef::Log.info("gems: #{gems}")

['fog'].each do |gem|
  gem_package gem do
    action :install
  end
end