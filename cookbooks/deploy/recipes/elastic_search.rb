include_recipe 'core::download_vendor_artifacts_prereqs'

elastic_search_port = node[:deploy][:elastic_search_port]
install_via_git_download = node[:deploy][:install_via_git_download]
verify_completion = node[:deploy][:verify_completion]
deploy_folder = '/opt/elasticsearch'
elastic_search_plugins = node[:deploy][:elastic_search_plugins]
elastic_search_files = 'elasticsearch,servicewrapper'
cluster_name = 'UFCluster'
sleep_interval = 10

if !File.exists?(deploy_folder)
  bash 'Install elastic search prerequisites' do
    code <<-EOF
      apt-get -yqq install openjdk-6-jre
    EOF
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
      :version => node[:deploy][:elastic_search_version],
      :artifacts => "#{elastic_search_files},#{elastic_search_plugins}",
      :target_directory => '/opt'
    )
  end

  bash 'Downloading elastic search' do
    code <<-EOF
      ruby #{node['ruby_scripts_dir']}/download_elastic_search.rb
    EOF
  end

  bash 'Configure elastic search' do
    code <<-EOF
      pushd #{deploy_folder}

      mv *servicewrapper*/service bin/
      rm -Rf *servicewrapper*

      bin/service/elasticsearch install

      ln -s `readlink -f bin/service/elasticsearch` /usr/local/bin/rcelasticsearch

      echo "cluster.name: #{cluster_name}" >> #{deploy_folder}/config/elasticsearch.yml
      sed -i "s@set.default.ES_HOME=@#set.default.ES_HOME=@" #{deploy_folder}/bin/service/elasticsearch.conf

      service elasticsearch start
    EOF
  end
  log 'Elastic Search service is installed and started.'

  @plugin_directories = {'elasticsearch-head' => 'plugins/head/_site',
                         'bigdesk' => 'plugins/bigdesk/_site',
                         'analysis-icu' => 'plugins/analysis-icu',
                         'analysis-phonetic' => 'plugins/analysis-phonetic'}

  elastic_search_plugins.split(',').each do |plugin|
    plugin_directory = @plugin_directories[plugin]
    bash "set up plugin #{plugin}" do
      code <<-EOF
      set +e
      DEPLOY_FOLDER="#{deploy_folder}"
      PLUGIN_FOLDER="#{plugin_directory}"
      pushd $DEPLOY_FOLDER
      mkdir -p $PLUGIN_FOLDER

      PLUGIN_DIR=`find . -maxdepth 1 -type d -name '*#{plugin}*'`
      echo "Copying the #{plugin} directory $PLUGIN_DIR contents to $PLUGIN_FOLDER"
      cp -R $PLUGIN_DIR/* $PLUGIN_FOLDER
      popd
      echo 'Restarting the service'
      service elasticsearch restart
      EOF
      not_if { plugin_directory.nil? }
    end
  end
  log "Elastic Search Plugins installed: #{elastic_search_plugins}"

  bash 'reinstall plugins from developer github' do
    code <<-EOF
    set +e
    pushd #{deploy_folder}
    ./bin/plugin -install bigdesk
    ./bin/plugin -install elasticsearch-head
    ./bin/plugin -install elasticsearch/elasticsearch-analysis-phonetic/1.2.0
    ./bin/plugin -install elasticsearch/elasticsearch-analysis-icu/1.5.0
    popd
    EOF
    not_if { install_via_git_download.nil? || install_via_git_download == '' }
  end
else
  log 'ElasticSearch is already installed.'
end

bash 'Confirm Elastic Search is operational' do
  code <<-EOF
  set +e
  LAST_RETRY=0
  RETRY_CNT=20
  STATUS=
  echo 'Waiting for ElasticSearch to become available on port #{elastic_search_port}'
  while  [ "-$STATUS" = '-' ] ; do
    STATUS=`netstat -an | grep :#{elastic_search_port}`
    RETRY_CNT=`expr $RETRY_CNT - 1`
    if [ "$RETRY_CNT" -eq "$LAST_RETRY" ] ; then
       echo "Exhausted retries"
       exit 1
    fi
    echo "Retries left: $RETRY_CNT"
    sleep #{sleep_interval}
  done
  EOF
  not_if { verify_completion.nil? || verify_completion == '' }
end

