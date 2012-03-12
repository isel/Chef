bash 'deploy elastic search' do
  code <<-EOF
    echo 'deploying elastic search'
    service elasticsearch restart

    echo 'recreate /opt/Indexer directory'
    rm --recursive --force /opt/Indexer
    mkdir /opt/Indexer

    echo 'updating indexer code'
    cp #{node['deploy_scripts_dir']}/ElasticSearch/* /opt/Indexer

    echo 'fixing permissions'
    chmod 755 /opt/Indexer/*
  EOF
  template '/opt/Indexer/indexOnData' do
    source 'index_on_data.erb'
    # the variable is not yet used
    variables(
      :elastic_search_port  => node[:deploy][:elastic_search_port]
    )
    mode 0755
  end
  code <<-EOF2
    echo 'issue reindex command'
    cd /opt/Indexer
    ./indexOnData new
  EOF2
end