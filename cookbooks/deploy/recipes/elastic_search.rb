ruby_scripts_dir = node['ruby_scripts_dir']
hostname = node[:hostname]
elastic_search_port = node[:deploy][:elastic_search_port]
verify_completion = node[:deploy][:verify_completion]
# temporary code
install_via_git_download = node[:deploy][:install_via_git_download]
deploy_folder = '/opt/ElasticSearch/'
sleep_interval = 10

if !File.exists?(deploy_folder)
  install_dir = "elasticsearch-#{node[:deploy][:elastic_search_version]}"
  bash 'install elastic search prerequisites' do
    code <<-EOF
      apt-get -yqq install openjdk-6-jre
      apt-get -yqq install python-dev
      apt-get -yqq install python-setuptools
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

  bash 'set up plugins' do
    code <<-EOF

    set +e
    DEPLOY_FOLDER="#{deploy_folder}"
    pushd $DEPLOY_FOLDER

    mkdir -p current/plugins/bigdesk/_site
    PLUGIN_DIR=`find . -maxdepth 1 -type d -name '*bigdesk*'`
    echo "Linking the bigdesk directory PLUGIN_DIR"
    cp -R $PLUGIN_DIR/* current/plugins/bigdesk/_site
    popd

    pushd $DEPLOY_FOLDER
    echo "Linking the elasticsearch-head directory $PLUGIN_DIR to plugins and Aconex"
    mkdir -p current/plugins/head/_site
    PLUGIN_DIR=`find . -maxdepth 1 -type d -name '*elasticsearch-head*'`
    cp -R $PLUGIN_DIR/* current/plugins/head/_site
    popd
    echo 'Restarting the service'
    service elasticsearch restart
    EOF
  end
  log 'Elastic Search Plugins are installed.'

  if !install_via_git_download.nil?  && install_via_git_download != ''
    bash 'install and set up plugins' do
      deploy_folder = '/opt/ElasticSearch/'
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
    end
    log 'ElasticSearch Plugins are installed from git repository.'
  end

else
  log 'ElasticSearch is already installed.'
end

if !verify_completion.nil? && verify_completion != ''
  bash 'verify the availability of ElasticSearch' do
    code <<-EOF
    LAST_RETRY=0
    RETRY_CNT=20
    HTTP_STATUS=0
    RESULT=1
    echo 'waiting for ElasticSearch to be serving HTTP on #{elastic_search_port}'
    while  [ "$RESULT" -ne "0" ] ; do
      HTTP_STATUS=`curl --write-out %{http_code} --silent --output /dev/null  http://#{hostname}:#{elastic_search_port}`
      expr $HTTP_STATUS : '302\\|200' > /dev/null
      RESULT=$?
      echo "get HTTP status code $HTTP_STATUS, $RESULT"
      RETRY_CNT=`expr $RETRY_CNT - 1`
      if [ "$RETRY_CNT" -eq "$LAST_RETRY" ] ; then
         echo "Exhausted retries"
         exit 1
      fi
      echo "Retries left: $RETRY_CNT"
      sleep #{sleep_interval}
    done
  EOF
  end
end
