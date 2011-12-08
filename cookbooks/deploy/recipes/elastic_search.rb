ruby_scripts_dir = '/RubyScripts'
template "#{ruby_scripts_dir}/wait_for_tag.rb" do
  source 'scripts/wait_for_tag.erb'
  variables(
    :instance_id => node[:deploy][:instance_id],
    :timeout => 60 * 60
  )
end


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

bash 'Waiting for data to be provisioned' do
  code <<-EOF
    ruby #{ruby_scripts_dir}/wait_for_tag.rb
  EOF
end

#bash 'deploy elastic search' do
#  code <<-EOF
#    echo 'deploying elastic search'
#    service elasticsearch restart
#
#    echo 'recreate /opt/Indexer directory'
#    rm --recursive --force /opt/Indexer
#    mkdir /opt/Indexer
#
#    echo 'updating indexer code'
#    cp /DeployScripts/ElasticSearch/* /opt/Indexer
#
#    echo 'fixing permissions'
#    chmod 755 /opt/Indexer/*
#
#    echo 'issue reindex command'
#    cd /opt/Indexer
#    ./indexOnData new
#  EOF
#end