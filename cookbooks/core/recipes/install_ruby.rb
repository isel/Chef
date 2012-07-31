include_recipe 'core::download_vendor_artifacts_prereqs'

ruby_version = '1.9.2-p320'

template "#{node['ruby_scripts_dir']}/download_ruby.rb" do
  local true
  source "#{node['ruby_scripts_dir']}/download_vendor_artifacts.erb"
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :product => 'ruby',
    :version => ruby_version,
    :artifacts => 'ruby',
    :target_directory => '/root/src'
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

    ./configure --enable-shared --prefix=/opt/ruby/#{ruby_version} 2>&1 | tee log-1-configure.txt

    make all 2>&1 | tee log-2-build.txt
    make test 2>&1 | tee log-3-test.txt
    make install 2>&1 | tee log-4-install.txt

    cd /opt/ruby
    rm -f active && ln -sf #{ruby_version} active
    ln -fs /usr/local/bin/ruby /opt/ruby/active/ruby

    export PATH=/opt/ruby/active/bin:$PATH
    export MANPATH=/opt/ruby/active/share/man
  EOF
end


