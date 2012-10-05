package('samba') { action :install }

gem_package "ruby-shadow" do
  action :install
  version "2.1.4"
end

