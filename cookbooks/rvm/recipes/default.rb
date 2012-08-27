# Erase all existence of "standard" ruby 1.8 and replace it with the RVM installed/default ruby
if node[:platform] == "ubuntu"

  if File.exists?(node[:rvm][:install_path])
    Chef::Log.info("RVM and default ruby are already installed. Skipping setup")
  else
    bindir=::File.join(node[:rvm][:install_path], 'bin')
    node[:rvm][:bin_path] = ::File.join(node[:rvm][:install_path], "bin", "rvm")

    # Required to compile some rubies
    package "libssl-dev"

    bash "Download the RVM install script" do
      code <<-EOF
        wget -O /tmp/rvm https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer
        chmod +x /tmp/rvm
      EOF
      creates "/tmp/rvm"
    end

    bash "Install RVM for all users" do
      code <<-EOF
        /tmp/rvm --path #{node[:rvm][:install_path]} #{node[:rvm][:version]}
        #{node[:rvm][:bin_path]} reload
      EOF
    end

    bash "Installing #{node[:rvm][:ruby]} as RVM's default ruby" do
      code <<-EOF
        #{node[:rvm][:bin_path]} install #{node[:rvm][:ruby]}
        #{node[:rvm][:bin_path]} --default use #{node[:rvm][:ruby]}
      EOF
    end

    %w{libopenssl-ruby1.8 libreadline-ruby1.8 libruby1.8 libshadow-ruby1.8 ruby ruby1.8 ruby1.8-dev}.each do |p|
      package p do
        action :remove
      end
    end

    bash "Symlink RVM binaries to /usr/bin" do
      code "for bin in `ls #{bindir}`; do ln -sf #{bindir}/$bin /usr/bin/$bin; done;"
      creates "/usr/bin/ruby"
      action :run
    end
  end
else
  Chef::Log.info("Your platform (#{node[:platform]}) is not supported by this recipe!")
end