ruby_scripts_dir = node['ruby_scripts_dir']
hostname = node[:hostname]
elastic_search_port = node[:deploy][:elastic_search_port]
install_via_git_download = node[:deploy][:install_via_git_download]
verify_completion = node[:deploy][:verify_completion]
deploy_folder = '/opt/ElasticSearch'
elastic_search_plugins = node[:deploy][:elastic_search_plugins]
elastic_search_plugins = '' if elastic_search_plugins.nil?
elastic_search_files = node['elastic_search_files']
cluster_name = 'UFCluster'
status_text = ""
sleep_interval = 10

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
      echo "cluster.name: #{cluster_name}" >> #{deploy_folder}/current/config/elasticsearch.yml
      sed -i "s@set.default.ES_HOME=@#set.default.ES_HOME=@" #{deploy_folder}/current/bin/service/elasticsearch.conf

      echo 'Starting the service'
      service elasticsearch start
    EOF
  end
  log 'Elastic Search service is installed and started.'

  @plugin_directories = {'elasticsearch-head' => 'current/plugins/head/_site',
                         'bigdesk' => 'current/plugins/bigdesk/_site',
                         'analysis-icu' => 'current/plugins/analysis-icu',
                         'analysis-phonetic' => 'current/plugins/analysis-phonetic'}

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
    DEPLOY_FOLDER="#{deploy_folder}"
    pushd $DEPLOY_FOLDER
    cd current
    echo "run the install"
    ./bin/plugin -install lukas-vlcek/bigdesk
    ./bin/plugin -install Aconex/elasticsearch-head

    echo 'ElasticSearch Plugins are reinstalled from developer git repository.'
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


@expected_plugins = %w( analysis-phonetic analysis-icu bigdesk head  tail )

@expected_plugins = elastic_search_plugins.split(',')

raw_log = "#{deploy_folder}/current/logs/#{cluster_name}.log"

if File.exists?(raw_log)
rawdata = File.open(raw_log, 'r:UTF-8')
contents = rawdata.read.split(/\n/)
processed_lines = [];
$stderr.puts "Processing #{contents.length} lines"
begin

  plugin_filter = Regexp.new('\[plugins\s+\]')


  processed_lines = contents.select { |item| item.include?('plugins') }
  $stderr.puts "Processing #{processed_lines.length} lines"

  last_log_line = contents.select { |item| plugin_filter.match(item) }.last
  $stderr.puts "Processing last log entry: #{last_log_line.chomp}"
  @loaded_plugins = []
  @site_plugins = []
  # capture entries -
  # NOTE ruby seems to ignore non greedy regex postfix

  if Regexp.new('loaded\s+\[([^\]]+)?\]').match(last_log_line)
    @loaded_plugins << $1.split(/\s*,\s*/)
    $stderr.puts "Found regular plugins: #{ @loaded_plugins.inspect }"
  end

  if Regexp.new('sites\s+\[([^\]]+)?\]').match(last_log_line)
    @site_plugins << $1.split(/\s*,\s*/)
    $stderr.puts "Found site plugins: #{@site_plugins.inspect}"
  end
  $stderr.puts "Comparing #{ [@site_plugins.flatten + @loaded_plugins.flatten].flatten }  with #{@expected_plugins.flatten}"
  @missing_plugins = @expected_plugins - [@site_plugins.flatten + @loaded_plugins.flatten].flatten
  if @missing_plugins.nil?  || @missing_plugins.length == 0
    errors = 0
    status_text = 'Found all plugins'
  else
    status_text = "Detected missing plugins: #{@missing_plugins}"
    errors = 1
  end
rescue
  errors = 0
  failures = 1
  status_text = "Unable to parse log: #{raw_log}"
end
else
  failures = 1
  status_text = "Log file not found : #{raw_log}"

end
puts "#{final_result.chomp}"
if errors || failures
  exit 1
end
