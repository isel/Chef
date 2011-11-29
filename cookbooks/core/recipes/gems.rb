['fog'].each do |gem|
  gem_package gem do
    action :install
  end
end