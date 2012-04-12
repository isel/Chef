# Erase all existence of "standard" ruby 1.8 and replace it with the RVM installed/default ruby
if node[:platform] == "ubuntu"

  ruby_scripts_dir = node['ruby_scripts_dir']
  puts "Processing template (need a different path for rvm cookbook) " + File.join(File.dirname(__FILE__), '/scripts/download_vendor_drop.erb' )

  template "#{ruby_scripts_dir}/download_vendor_drop.rb" do
    source 'scripts/download_vendor_drop.erb'
    variables(
      :aws_access_key_id => node[:aws][:access_key_id],
      :aws_secret_access_key => node[:aws][:secret_access_key],
      :product => 'ruby',
      :version => '1.9.2-p318',
      :filelist => 'ruby',
      :deploy_folder => '/opt/rvm/archives/',
      :no_explode => '1'
    )
  end

  # TODO  copy the rvm-installer (8K )
  # note -  during the normal run the system
  # ruby is avaliable.
  if 0
  bash 'Remove rvm directory' do
    code <<-EOF
      rm -rf /opt/rvm
      mkdir -p /opt/rvm/archives
    EOF
  end
  end

  bash 'Download ruby from s3 to cache rvm install' do
    code <<-EOF
      ruby #{ruby_scripts_dir}/download_vendor_drop.rb
      cd /opt/rvm
      tar xjvf archives/ruby-1.9.2-p318.tar.bz2
    EOF
  end

  # TODO  fetch yaml-0.1.4.tar.gz
  # where is the version defined ?
  # inside the  wayneeseguin-rvm-master.tgz
  # which we do not control

  # if !File.exists?(node[:rvm][:install_path])
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


    #temporary override the version variable 1.9.2-p318
    bash "Install RVM for all users" do
      code <<-EOF
        echo "/tmp/rvm --path #{node[:rvm][:install_path]} #{node[:rvm][:version]}"
        /tmp/rvm --path #{node[:rvm][:install_path]} #{node[:rvm][:version]}
        echo "switching to #{node[:rvm][:bin_path]}
        #{node[:rvm][:bin_path]} reload
      EOF
    end

    bash "Installing #{node[:rvm][:ruby]} as RVM's default ruby" do
      code <<-EOF
#        #{node[:rvm][:bin_path]} install #{node[:rvm][:ruby]}
         /opt/rvm/bin/rvm install --verbose  ruby-1.9.2-p318

#
#         #{node[:rvm][:bin_path]} --default use #{node[:rvm][:ruby]}
          /opt/rvm/bin/rvm install --default use ruby-1.9.2-p318

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
#  else
#    Chef::Log.info("RVM and default ruby are already installed. Skipping setup")
#  end
else
  Chef::Log.info("Your platform (#{node[:platform]}) is not supported by this recipe!")
end