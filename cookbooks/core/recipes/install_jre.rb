include_recipe 'core::download_vendor_artifacts_prereqs'

if node[:platform] == "ubuntu"
  template "#{node['ruby_scripts_dir']}/download_jre.rb" do
    local true
    source "#{node['ruby_scripts_dir']}/download_vendor_artifacts.erb"
    variables(
      :aws_access_key_id => node[:core][:aws_access_key_id],
      :aws_secret_access_key => node[:core][:aws_secret_access_key],
      :s3_bucket => node[:core][:s3_bucket],
      :s3_repository => 'Vendor',
      :product => 'jre',
      :version => '1.7.0',
      :artifacts => 'jre_ubuntu',
      :target_directory => '/',
      :unzip => true
    )
    not_if { File.exist?('/jre_ubuntu/jre1.7.0') }
  end

  bash 'Installing jre' do
    code <<-EOF
      ruby #{node['ruby_scripts_dir']}/download_jre.rb
      echo "JAVA_HOME=/jre_ubuntu/jre1.7.0" >> /etc/profile
      echo "JRE_HOME=/jre_ubuntu/jre1.7.0" >> /etc/profile
      echo "PATH=\$PATH:/jre_ubuntu/jre1.7.0/bin" >> /etc/profile

      rm /usr/bin/java
      rm /usr/bin/javac
      rm /usr/bin/javadoc
      rm /usr/bin/javah
      rm /usr/bin/javap
      rm /usr/bin/java_vm
      rm /usr/bin/javaws
      rm /usr/bin/jcontrol

      ln -s /jre_ubuntu/jre1.7.0/bin/java /usr/bin/java
      ln -s /jre_ubuntu/jre1.7.0/bin/java_vm /usr/bin/java_vm
      ln -s /jre_ubuntu/jre1.7.0/bin/javaws /usr/bin/javaws
      ln -s /jre_ubuntu/jre1.7.0/bin/jcontrol /usr/bin/jcontrol
    EOF
    not_if { File.exist?('/jre_ubuntu/jre1.7.0') }
  end
else
  template "#{node['ruby_scripts_dir']}/download_jre.rb" do
    local true
    source "#{node['ruby_scripts_dir']}/download_vendor_artifacts.erb"
    variables(
      :aws_access_key_id => node[:core][:aws_access_key_id],
      :aws_secret_access_key => node[:core][:aws_secret_access_key],
      :s3_bucket => node[:core][:s3_bucket],
      :s3_repository => 'Vendor',
      :product => 'jre',
      :version => '1.7.0',
      :artifacts => 'jre_windows',
      :target_directory => '/download_jre',
      :unzip => true
    )
    not_if { File.exist?('/jre') }
  end

  powershell 'Installing jre' do
    script = <<-EOF
      ruby #{node['ruby_scripts_dir']}/download_jre.rb
      cd /download_jre/jre_windows

      cmd /c 'msiexec.exe /i jre1.7.0.msi /qn INSTALLDIR=c:\\jre'

      [System.Environment]::SetEnvironmentVariable('JAVA_HOME', 'c:\\jre\\bin', 'machine')
      [System.Environment]::SetEnvironmentVariable('JRE_HOME', 'c:\\jre\\bin', 'machine')
    EOF
    source(script)
    not_if { File.exist?('/jre') }
  end
end