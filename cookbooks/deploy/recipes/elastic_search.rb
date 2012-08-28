include_recipe 'core::download_vendor_artifacts_prereqs'

deploy_folder = '/opt/elasticsearch'
elastic_search_files = 'elasticsearch,servicewrapper'
cluster_name = 'UFCluster'

if File.exists?(deploy_folder)
  log 'ElasticSearch is already installed.'
else
  bash 'Install elastic search prerequisites' do
    code 'apt-get -yqq install openjdk-6-jre'
  end

  template "#{node['ruby_scripts_dir']}/download_elastic_search.rb" do
    local true
    source "#{node['ruby_scripts_dir']}/download_vendor_artifacts.erb"
    variables(
      :aws_access_key_id => node[:core][:aws_access_key_id],
        :aws_secret_access_key => node[:core][:aws_secret_access_key],
        :s3_bucket => node[:core][:s3_bucket],
        :s3_repository => 'Vendor',
        :product => 'elasticsearch',
        :version => node[:search_version],
        :artifacts => "#{elastic_search_files},#{node[:search_plugins]}",
        :target_directory => '/downloads',
        :unzip => true
    )
  end

  bash 'Downloading elastic search' do
    code "ruby #{node['ruby_scripts_dir']}/download_elastic_search.rb"
  end

  bash 'Configure elastic search' do
    code <<-EOF
      mv /downloads/elasticsearch /opt
      mv /downloads/servicewrapper/service /opt/elasticsearch/bin

      pushd #{deploy_folder}
      chmod -R +x+X bin/**

      bin/service/elasticsearch install

      ln -s `readlink -f bin/service/elasticsearch` /usr/local/bin/rcelasticsearch

      echo "cluster.name: #{cluster_name}" >> #{deploy_folder}/config/elasticsearch.yml
      sed -i "s@set.default.ES_HOME=@#set.default.ES_HOME=@" #{deploy_folder}/bin/service/elasticsearch.conf

      # service elasticsearch start
    EOF
  end

  @plugin_directories = {
    'elasticsearch-head' => 'plugins/head/_site',
    'bigdesk' => 'plugins/bigdesk/_site',
    'analysis-icu' => 'plugins/analysis-icu',
    'analysis-phonetic' => 'plugins/analysis-phonetic'
  }

  node[:search_plugins].split(',').each do |plugin|
    plugin_directory = @plugin_directories[plugin]
    bash "set up plugin #{plugin}" do
      code <<-EOF
      set +e
      pushd #{deploy_folder}
      mkdir -p #{plugin_directory}

      cp -R /downloads/#{plugin}/* #{plugin_directory}
      popd
      # service elasticsearch restart
      EOF
      not_if { plugin_directory.nil? }
    end
  end

  bash('starting elastic search') { code 'service elasticsearch start' }
end

template("#{node['ruby_scripts_dir']}/wait_for_elastic_search.rb") { source 'scripts/wait_for_elastic_search.erb' }

bash('wait for elastic search') { code "ruby #{node['ruby_scripts_dir']}/wait_for_elastic_search.rb" }
