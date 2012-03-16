bash 'deploy elastic search' do
  code <<-EOF
    echo 'deploying elastic search'
    service elasticsearch restart

    echo 'recreate /opt/Indexer directory'
    rm --recursive --force /opt/Indexer
    mkdir /opt/Indexer

    echo 'updating indexer code'
    cp #{node['binaries_directory']}/ElasticSearch/* /opt/Indexer

    echo 'fixing permissions'
    chmod 755 /opt/Indexer/*

    echo 'issue reindex command'
    cd /opt/Indexer
    ./indexOnData new
  EOF
end