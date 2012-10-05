package('samba') { action :install }

chef_gem "ruby-shadow" do
  action :install
  version "2.1.4"
end

