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

  template "#{ruby_scripts_dir}/download_elastic_search.rb" do
    source 'scripts/download_elastic_search.erb'
    variables(
      :install_dir => install_dir,
      :version => node[:deploy][:elastic_search_version],
      :aws_access_key_id => node[:deploy][:aws_access_key_id],
      :aws_secret_access_key => node[:deploy][:aws_secret_access_key]
    )
  end

  bash 'Downloading artifacts' do
    code <<-EOF
      ruby #{ruby_scripts_dir}/download_elastic_search.rb
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
else
  log 'Elastic Search is already installed.'
end

