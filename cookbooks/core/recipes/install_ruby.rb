include_recipe 'core::download_vendor_artifacts_prereqs'

#todo: check for `ruby -v` instead of the folder
if File.exists?('/opt/ruby')
  log 'Ruby already installed'
else
  ruby_version = '1.9.2-p320'
  executables = ['ruby', 'gem', 'rake', 'rspec', 'rdoc', 'ri', 'bundle']

  template "#{node['ruby_scripts_dir']}/download_ruby.rb" do
    local true
    source "#{node['ruby_scripts_dir']}/download_vendor_artifacts.erb"
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
    end
  end

  bash 'Download ruby' do
    code <<-EOF
    /opt/rightscale/sandbox/bin/ruby -rubygems #{node['ruby_scripts_dir']}/download_ruby.rb
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