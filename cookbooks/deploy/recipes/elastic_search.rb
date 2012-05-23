ruby_scripts_dir = node['ruby_scripts_dir']
hostname = node[:hostname]
elastic_search_port = node[:deploy][:elastic_search_port]
install_via_git_download = node[:deploy][:install_via_git_download]
deploy_folder = '/opt/ElasticSearch/'
elastic_search_plugins = node[:deploy][:elastic_search_plugins]
elastic_search_plugins = '' if elastic_search_plugins.nil?
elastic_search_files  =  node['elastic_search_files']

log "Elastic Search Plugins to be installed: (#{elastic_search_plugins})"

sleep_interval = 10
@plugin_directories = {'elasticsearch-head'  => 'head',
                'bigdesk' => 'bigdesk'}


if !File.exists?(deploy_folder)
  install_dir = "elasticsearch-#{node[:deploy][:elastic_search_version]}"
  bash 'Install elastic search prerequisites' do
    code <<-EOF
      apt-get -yqq install openjdk-6-jre
      EOF
  end

  template "#{ruby_scripts_dir}/download_vendor_drop.rb" do
    source 'scripts/download_vendor_drop.erb'
    variables(
      :aws_access_key_id => node[:deploy][:aws_access_key_id],
      :aws_secret_access_key => node[:deploy][:aws_secret_access_key],
      :install_dir => install_dir,
      :product => 'ElasticSearch',
      :version => node[:deploy][:elastic_search_version],
      :filelist => [elastic_search_files, elastic_search_plugins].join(',')
    )
  end

  bash 'Downloading artifacts' do
    code <<-EOF
      ruby #{ruby_scripts_dir}/download_vendor_drop.rb
    EOF
  end

  bash 'set up directory  links' do
    code <<-EOF
      pushd #{deploy_folder}
      ln -s #{install_dir} current
      mv *servicewrapper*/service current/bin/
      rm -Rf *servicewrapper*
    EOF
  end

  bash 'configure Elastic Search as a service' do
    code <<-EOF
      pushd #{deploy_folder}
      current/bin/service/elasticsearch install

      echo 'Set up rcelasticsearch as a shortcut to the service wrapper'
      ln -s `readlink -f current/bin/service/elasticsearch` /usr/local/bin/rcelasticsearch

      echo 'Configuring Cluster'
      echo "cluster.name: UFCluster" >> /opt/ElasticSearch/current/config/elasticsearch.yml
      sed -i "s@set.default.ES_HOME=@#set.default.ES_HOME=@" /opt/ElasticSearch/current/bin/service/elasticsearch.conf

      echo 'Starting the service'
      service elasticsearch start
    EOF
  end
  log 'Elastic Search service is installed and started.'

  elastic_search_plugins.split(',').each do |plugin|
    bash "set up plugin #{plugin}" do
      plugin_directory = @plugin_directories[plugin]
      code <<-EOF

      set +e
      DEPLOY_FOLDER="#{deploy_folder}"
      PLUGIN_FOLDER="current/plugins/#{plugin_directory}/_site"
      pushd $DEPLOY_FOLDER

      mkdir -p $PLUGIN_FOLDER
      PLUGIN_DIR=`find . -maxdepth 1 -type d -name '*#{plugin}*'`
      echo "Linking the #{plugin} directory $PLUGIN_DIR"
      cp -R $PLUGIN_DIR/* $PLUGIN_FOLDER
      popd
      echo 'Restarting the service'
      service elasticsearch restart
      EOF

    end
  end
  log "Elastic Search Plugins are installed: #{elastic_search_plugins}"

  bash 'reinstall plugins from developer github' do
    code <<-EOF
    set +e
    DEPLOY_FOLDER="#{deploy_folder}"
    pushd $DEPLOY_FOLDER
    cd current
    echo "run the install"
    ./bin/plugin -install lukas-vlcek/bigdesk
    ./bin/plugin -install Aconex/elasticsearch-head
    popd
    EOF
    not_if { install_via_git_download.nil? || install_via_git_download == ''}
  end
  log 'ElasticSearch Plugins are reinstalled from developer git repository.'
else
  log 'ElasticSearch is already installed.'
end
