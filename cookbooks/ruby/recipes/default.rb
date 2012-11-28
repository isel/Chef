#rightscale_marker :begin

include_recipe 'core::download_vendor_artifacts_prereqs'

ruby_version = '1.9.2-p320'

if node[:platform] == "ubuntu"
  if File.exists?('/opt/ruby')
    log 'Ruby already installed'
  else
    ruby_version = '1.9.2-p320'
    executables = ['ruby', 'gem', 'rake', 'rspec', 'rdoc', 'ri', 'bundle']

    template "#{node[:ruby_scripts_dir]}/download_ruby.rb" do
      local true
      source "#{node[:ruby_scripts_dir]}/download_vendor_artifacts.erb"
      variables(
        :aws_access_key_id => node[:core][:aws_access_key_id],
        :aws_secret_access_key => node[:core][:aws_secret_access_key],
        :s3_bucket => node[:core][:s3_bucket],
        :s3_repository => 'Vendor',
        :product => 'ruby',
        :version => ruby_version,
        :artifacts => 'ruby',
        :target_directory => '/root/src',
        :unzip => true
      )
    end

    ruby_block 'Install fog' do
      block do
        ENV['RUBYGEMS_BINARY_PATH'] ||= 'gem'
        system("/opt/rightscale/sandbox/bin/gem install fog -v 1.1.1 --no-rdoc --no-ri")
        system("/opt/rightscale/sandbox/bin/gem install xml-simple -v 1.1.1 --no-rdoc --no-ri")
      end
    end

    bash 'Download ruby' do
      code <<-EOF
      /opt/rightscale/sandbox/bin/ruby -rubygems #{node[:ruby_scripts_dir]}/download_ruby.rb
      EOF
    end

    bash 'Install ruby from source' do
      code <<-EOF
      apt-get -y install \
                 build-essential \
                 libreadline-dev \
                 libssl-dev \
                 libyaml-dev \
                 libffi-dev \
                 libncurses-dev \
                 libdb-dev \
                 libgdbm-dev \
                 tk-dev

      cd ~/src/ruby
      chmod 777 configure
      chmod 777 tool/ifchange

      ./configure --enable-shared --prefix=/opt/ruby/#{ruby_version}

      make all
      make test
      make install

      cd /opt/ruby

      rm -f active
      rm /usr/bin/ruby
      rm /usr/bin/gem
      rm /usr/bin/rake

      ln -fs #{ruby_version} active
      #{executables.map { |exe| "ln -fs /opt/ruby/active/bin/#{exe} /usr/bin/#{exe} \n" }.join}
      EOF
    end
  end
else
  template "#{node[:ruby_scripts_dir]}/download_ruby.rb" do
    local true
    source "#{node[:ruby_scripts_dir]}/download_vendor_artifacts.erb"
    variables(
      :aws_access_key_id => node[:core][:aws_access_key_id],
      :aws_secret_access_key => node[:core][:aws_secret_access_key],
      :s3_bucket => node[:core][:s3_bucket],
      :s3_repository => 'Vendor',
      :product => 'ruby',
      :version => ruby_version,
      :artifacts => 'ruby_windows',
      :target_directory => '/installs',
      :unzip => true
    )
    not_if { File.exist?('/installs/ruby_windows.zip') }
  end

  powershell 'Install fog and download ruby' do
    script = <<'EOF'
    cd "c:\\Program Files (x86)\\RightScale\\RightLink\\sandbox\\ruby\\bin"
    cmd /c gem install fog -v 1.1.1 --no-rdoc --no-ri
    cmd /c gem install xml-simple -v 1.1.1 --no-rdoc --no-ri
    cmd /c ruby -rubygems c:\\RubyScripts\\download_ruby.rb
EOF
    source(script)
    not_if { File.exist?('/installs/ruby_windows.zip') }
  end

  powershell 'Install ruby' do
    source('c:\\installs\\ruby_windows\\rubyinstaller-1.9.2-p0.exe /tasks=modpath /silent')
    not_if { File.exist?('/Ruby192') }
  end
end

#rightscale_marker :end

