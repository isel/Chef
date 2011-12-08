if !File.exists?('/opt/ElasticSearch')
  install_dir = "elasticsearch-#{node[:deploy][:elastic_search_version]}"
  bash 'install elastic search' do
    code <<-EOF
      echo 'Installing prerequisites'
      apt-get -y install openjdk-6-jre
      apt-get -y install python-dev
      apt-get -y install python-setuptools
      easy_install -U setuptools
      easy_install pymongo

      echo 'Install Elastic Search'
      mkdir /opt/ElasticSearch
      cd /opt/ElasticSearch

      wget https://github.com/downloads/elasticsearch/elasticsearch/#{install_dir}.tar.gz
      tar xvf #{install_dir}.tar.gz
      ln -s #{install_dir} current
      rm #{install_dir}.tar.gz

      echo 'Setup Service environment'
      wget http://github.com/elasticsearch/elasticsearch-servicewrapper/tarball/master
      tar -xvf master
      mv *servicewrapper*/service current/bin/
      rm -Rf *servicewrapper*
      rm master

      echo 'Setup Elastic Search as a service'
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
else
  Chef::Log.info('Elastic Search is already installed.')
end

