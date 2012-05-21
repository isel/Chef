ruby_scripts_dir = node['ruby_scripts_dir']

if !File.exists?('/opt/ElasticSearch')
  install_dir = "elasticsearch-#{node[:deploy][:elastic_search_version]}"
  bash 'install elastic search prerequisites' do
    code <<-EOF
      apt-get -y install openjdk-6-jre
      apt-get -y install python-dev
      apt-get -y install python-setuptools
      easy_install -U setuptools
      easy_install pymongo
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
      :filelist => node[:deploy][:elastic_search_filelist]
#      :filelist => 'elasticsearch,servicewrapper,bigdesk,elasticsearch-head'
    )
  end

  bash 'Downloading artifacts' do
    code <<-EOF
      ruby #{ruby_scripts_dir}/download_vendor_drop.rb
    EOF
  end

  bash 'set up directory  links' do
    deploy_folder = '/opt/ElasticSearch/'
    code <<-EOF
      pushd #{deploy_folder}
      ln -s #{install_dir} current
      mv *servicewrapper*/service current/bin/
      rm -Rf *servicewrapper*
    EOF
  end


  bash 'setup Elastic Search as a service' do
    code <<-EOF
      cd /opt/ElasticSearch
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
  bash 'set up plugins' do
    deploy_folder = '/opt/ElasticSearch/'
    code <<-EOF

    set +e
    DEPLOY_FOLDER="${deploy_folder}"
    pushd $DEPLOY_FOLDER

    mkdir -p current/plugins/bigdesk/_site
    PLUGIN_DIR=`find . -maxdepth 1 -type d -name '*bigdesk*'`
    echo "Linking the bigdesk directory PLUGIN_DIR"
    cp -R $PLUGIN_DIR/* current/plugins/bigdesk/_site
    echo "run the install"
    mkdir -p  current/lukas-vlcek
    cp -R $PLUGIN_DIR/* current/lukas-vlcek
    cd current
    ./bin/plugin -install lukas-vlcek/bigdesk
    popd

    pushd #{deploy_folder}
    echo "Linking the elasticsearch-head directory $PLUGIN_DIR to plugins and Aconex"
    mkdir -p current/plugins/head/_site
    PLUGIN_DIR=`find . -maxdepth 1 -type d -name '*elasticsearch-head*'`
    mkdir -p current/Aconex
    cp -R $PLUGIN_DIR/* current/Aconex
    cd current
    echo "run the install"
    ./bin/plugin  -install Aconex/elasticsearch-head
    popd


      EOF
    end


else
  log 'Elastic Search is already installed.'
end

