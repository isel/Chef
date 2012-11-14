rightscale_marker :begin

include_recipe 'core::download_vendor_artifacts_prereqs'

artifacts = node[:platform] == 'ubuntu' ? 'jdk_ubuntu' : 'jdk_windows'
target_directory = node[:platform] == 'ubuntu' ? '/' : '/download_jdk'
install_directory = node[:platform] == 'ubuntu' ? '/jdk_ubuntu/jdk1.7.0_07' : '/jdk'

template "#{node[:ruby_scripts_dir]}/download_jdk.rb" do
  local true
  source "#{node[:ruby_scripts_dir]}/download_vendor_artifacts.erb"
  variables(
    :aws_access_key_id => node[:core][:aws_access_key_id],
    :aws_secret_access_key => node[:core][:aws_secret_access_key],
    :s3_bucket => node[:core][:s3_bucket],
    :s3_repository => 'Vendor',
    :product => 'jdk',
    :version => '1.7.0',
    :artifacts => artifacts,
    :target_directory => target_directory,
    :unzip => true
  )
  not_if { File.exist?(install_directory) }
end

if node[:platform] == "ubuntu"
  bash 'Installing jdk' do
    code <<-EOF
      ruby #{node[:ruby_scripts_dir]}/download_jdk.rb
      echo "JAVA_HOME=/jdk_ubuntu/jdk1.7.0_07" >> /etc/profile
      echo "JRE_HOME=/jdk_ubuntu/jdk1.7.0_07" >> /etc/profile
      echo "PATH=\$PATH:/jdk_ubuntu/jdk1.7.0_07/bin" >> /etc/profile

      rm /usr/bin/java
      rm /usr/bin/javac
      rm /usr/bin/javadoc
      rm /usr/bin/javah
      rm /usr/bin/javap
      rm /usr/bin/java_vm
      rm /usr/bin/javaws
      rm /usr/bin/jcontrol

      ln -s /jdk_ubuntu/jdk1.7.0_07/bin/java /usr/bin/java
      ln -s /jdk_ubuntu/jdk1.7.0_07/bin/javac /usr/bin/javac
      ln -s /jdk_ubuntu/jdk1.7.0_07/bin/javadoc /usr/bin/javadoc
      ln -s /jdk_ubuntu/jdk1.7.0_07/bin/javah /usr/bin/javah
      ln -s /jdk_ubuntu/jdk1.7.0_07/bin/javap /usr/bin/javap
      ln -s /jdk_ubuntu/jdk1.7.0_07/jre/bin/java_vm /usr/bin/java_vm
      ln -s /jdk_ubuntu/jdk1.7.0_07/bin/javaws /usr/bin/javaws
      ln -s /jdk_ubuntu/jdk1.7.0_07/bin/jcontrol /usr/bin/jcontrol
    EOF
    not_if { File.exist?(install_directory) }
  end
else
  powershell 'Installing jdk' do
    script = <<-EOF
      ruby #{node[:ruby_scripts_dir]}/download_jdk.rb
      cd /download_jdk/jdk_windows

      cmd /c 'msiexec.exe /i jdk1.7.0_07.msi /qn INSTALLDIR=c:\\jdk'
    EOF
    source(script)
    not_if { File.exist?(install_directory) }
  end

  env('JAVA_HOME') { value 'c:\jdk\bin' }
  env('JRE_HOME') { value 'c:\jdk\bin' }

  env('PATH') do
    action :modify
    delim ::File::PATH_SEPARATOR
    value 'C:\jdk\bin'
  end
end

rightscale_marker :end