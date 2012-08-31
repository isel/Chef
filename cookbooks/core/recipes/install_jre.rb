include_recipe 'core::download_vendor_artifacts_prereqs'

if node[:platform] == "ubuntu"
#  if File.exists?('/usr/local/mongodb')
#    log 'Mongo already downloaded.'
#  else
#    version = node[:deploy][:mongo_version]
#
#    template "#{node['ruby_scripts_dir']}/download_mongo.rb" do
#      local true
#      source "#{node['ruby_scripts_dir']}/download_vendor_artifacts.erb"
#      variables(
#        :aws_access_key_id => node[:core][:aws_access_key_id],
#          :aws_secret_access_key => node[:core][:aws_secret_access_key],
#          :s3_bucket => node[:core][:s3_bucket],
#          :s3_repository => 'Vendor',
#          :product => 'mongo',
#          :version => version,
#          :artifacts => 'mongo',
#          :target_directory => '/usr/local',
#          :unzip => true
#      )
#    end
#
#    bash 'Downloading mongo' do
#      code <<-EOF
#      ruby #{node['ruby_scripts_dir']}/download_mongo.rb
#      mv /usr/local/mongo /usr/local/mongodb
#      chmod a+x /usr/local/mongodb/bin/*
#      EOF
#    end
#  end
#  bash 'Installing ruby gems' do
#    code <<-EOF
#apt-get install -y libyaml-dev
#apt-cache policy libyaml-dev
#
#gem install psych -v 1.3.2 --no-rdoc --no-ri
#
#gem update --system
#
##{gems.map {|g| "gem install #{g['gem']} -v #{g['version']} --no-rdoc --no-ri \n"}.join}
#    EOF
#  end
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
  end

  powershell 'Installing jre' do
    script = <<-EOF
      ruby #{node['ruby_scripts_dir']}/download_jre.rb
      cd /download_jre/jre_windows
Write-Output "before if"
      if (Test-Path("c:\jre")) {
        Write-Output "JRE already installed"
        Exit 0
      }
Write-Output "before msiexec"

      cmd /c 'msiexec.exe /i jre1.7.0.msi /qn INSTALLDIR=c:\jre'
Write-Output "before env vars"

      [System.Environment]::SetEnvironmentVariable('JAVA_HOME', 'c:\jre\bin', 'machine')
      [System.Environment]::SetEnvironmentVariable('JRE_HOME', 'c:\jre\bin', 'machine')
    EOF
    source(script)
  end
end