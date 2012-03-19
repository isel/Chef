maintainer       "Isel Fernandez"
maintainer_email "isel_77@hotmail.com"
license          "our license"
description      "Deploys the UGF software to the environment"
long_description ""
version          "0.0.1"

supports "ubuntu"

recipe "deploy::activemq", "Deploys ActiveMQ"
recipe "deploy::adjust_ulimit", "Adjusts open files limit for log4j"
recipe "deploy::appfabric_configure", "Configures AppFabric"
recipe "deploy::appfabric_powershell", "Deploys AppFabric Powershell cmdlets"
recipe "deploy::appfabric_ensure_is_up", "Ensures AppFabric cache are working"
recipe "deploy::download_artifacts", "Downloads artifacts"
recipe "deploy::download_binaries", "Downloads binaries"
recipe "deploy::download_pims", "Downloads pims"
recipe "deploy::elastic_search", "Deploys ElasticSearch"
recipe "deploy::launch_activemq", "Launches ActiveMQ"
recipe "deploy::launch_mule",  "Launches Mule"
recipe "deploy::mule", "Deploys Mule ESB"
recipe "deploy::engine", "Deploys Engine"
recipe "deploy::foundation_services", "Deploys the foundation rest services"
recipe "deploy::jspr", "Deploys the web server websites"
recipe "deploy::mongo", "Deploys mongodb"
recipe "deploy::provision", "Provisions basic system data"
recipe "deploy::reindex_elastic_search", "Reindexes ElasticSearch (should be going away)"
recipe "deploy::sarmus", "Deploys sarmus"
recipe "deploy::smoke_tests_global", "Runs global smoke tests"
recipe "deploy::smoke_tests_local_app", "Runs local app server smoke tests"
recipe "deploy::smoke_tests_local_cache", "Runs local cache server smoke tests"
recipe "deploy::smoke_tests_local_db", "Runs local db server smoke tests"
recipe "deploy::smoke_tests_local_engine", "Runs local engine server smoke tests"
recipe "deploy::smoke_tests_local_messaging", "Runs local messaging server smoke tests"
recipe "deploy::smoke_tests_local_web", "Runs local web server smoke tests"
recipe "deploy::register_cache_hostname", "Registers the cache hostname and ip in the hosts file"
recipe "deploy::tag_data_version", "Writes a tag denoting what data version has been applied to this server"

attribute "deploy/appfabric_caches",
  :display_name => "appfabric caches",
  :required => "optional",
  :default => "default,TokenStore,SaasPolicy,EntityModel,Securables,Messages,Views,Enumerations",
  :recipes => ["deploy::appfabric_configure", "deploy::appfabric_ensure_is_up"]

attribute "deploy/appfabric_security",
  :display_name => "appfabric security",
  :required => "required",
  :recipes => ["deploy::appfabric_configure"]

attribute "deploy/appfabric_service_user",
  :display_name => "appfabric service user",
  :required => "optional",
  :default => "appfabric",
  :recipes => ["deploy::appfabric_configure"]

attribute "deploy/appfabric_service_password",
  :display_name => "appfabric service password",
  :required => "required",
  :recipes => ["deploy::appfabric_configure"]

attribute "deploy/appfabric_shared_drive",
  :display_name => "appfabric shared drive",
  :required => "optional",
  :default => "appfabric_caching",
  :recipes => ["deploy::appfabric_configure"]

attribute "deploy/appfabric_shared_folder",
  :display_name => "appfabric shared folder",
  :required => "optional",
  :default => "c:\\appfabric_caching",
  :recipes => ["deploy::appfabric_configure"]

attribute "deploy/app_server",
  :display_name => "app server",
  :required => "required",
  :recipes => ["deploy::engine", "deploy::jspr", "deploy::provision",
     "deploy::smoke_tests_global", "deploy::smoke_tests_local_app",
     "deploy::smoke_tests_local_engine", "deploy::smoke_tests_local_web"]

attribute "deploy/artifacts",
  :display_name => "artifacts",
  :required => "required",
  :recipes => ["deploy::download_artifacts"]

attribute "deploy/aws_access_key_id",
  :display_name => "aws access key id",
  :required => "required",
  :recipes => ["deploy::download_artifacts", "deploy::download_binaries", "deploy::download_pims", "deploy::elastic_search"]

attribute "deploy/aws_secret_access_key",
  :display_name => "aws secret access key",
  :required => "required",
  :recipes => ["deploy::download_artifacts", "deploy::download_binaries", "deploy::download_pims", "deploy::elastic_search"]

attribute "deploy/binaries_artifacts",
  :display_name => "binaries artifacts",
  :required => "required",
  :recipes => ["deploy::download_binaries"]

attribute "deploy/binaries_revision",
  :display_name => "binaries revision",
  :required => "required",
  :recipes => ["deploy::download_binaries", "deploy::sarmus", "deploy::tag_data_version"]

attribute "deploy/cache_server",
  :display_name => "cache server",
  :required => "required",
  :recipes => ["deploy::foundation_services", "deploy::register_cache_hostname"]

attribute "deploy/db_server",
  :display_name => "db server",
  :required => "required",
  :recipes => ["deploy::foundation_services", "deploy::provision", "deploy::smoke_tests_global", "deploy::smoke_tests_local_app"]

attribute "deploy/deployment_name",
  :display_name => "deployment name",
  :required => "required",
  :recipes => ["deploy::register_cache_hostname"]

attribute "deploy/domain",
  :display_name => "domain",
  :recipes => ["deploy::jspr"]

attribute "deploy/elastic_search_port",
  :display_name => "elastic search port",
  :required => "optional",
  :default => "9200",
  :recipes => ["deploy::foundation_services", "deploy::smoke_tests_local_app"]

attribute "deploy/elastic_search_version",
  :display_name => "elastic search version",
  :required => "optional",
  :default => "0.17.6",
  :recipes => ["deploy::elastic_search"]

attribute "deploy/engine_server",
  :display_name => "engine server",
  :required => "required",
  :recipes => ["deploy::smoke_tests_global"]

attribute "deploy/force_provision",
  :display_name => "force provision",
  :required => "required",
  :recipes => ["deploy::provision"]

attribute "deploy/mongo_port",
  :display_name => "mongo port",
  :required => "optional",
  :default => "28017",
  :recipes => ["deploy::mongo"]

attribute "deploy/mongo_version",
  :display_name => "mongo version",
  :required => "optional",
  :default => "2.0.1",
  :recipes => ["deploy::mongo"]

attribute "deploy/mule_version",
  :display_name => "mule version",
  :required => "optional",
  :default => "3.2.1",
  :recipes => ["deploy::mule"]

attribute "deploy/pims_artifacts",
  :display_name => "pims artifacts",
  :required => "required",
  :recipes => ["deploy::download_pims"]

attribute "deploy/pims_revision",
  :display_name => "pims revision",
  :required => "required",
  :recipes => ["deploy::download_pims"]

attribute "deploy/ipaddress",
  :display_name => "ipaddress of the host",
  :required => "required",
  :recipes => ["deploy::launch_mule"]

attribute "deploy/activemq_version",
  :display_name => "activeMQ version",
  :required => "optional",
  :default => "5.4.3",
  :recipes => ["deploy::activemq"]

attribute "deploy/activemq_port",
  :display_name => "activemq port",
  :required => "optional",
  :default => "61616",
  :recipes => ["deploy::launch_activemq", "deploy::smoke_tests_local_messaging"]

attribute "deploy/mule_port",
  :display_name => "mule port",
  :required => "optional",
  :default => "8585",
  :recipes => ["deploy::lunch_mule", "deploy::smoke_tests_local_messaging"]

attribute "deploy/ulimit_files",
  :display_name => "setting for log4j",
  :required => "optional",
  :default => "8192",
  :recipes => ["deploy::adjust_ulimit", "deploy:launch_mule"]

attribute "deploy/revision",
  :display_name => "revision",
  :required => "required",
  :recipes => ["deploy::download_artifacts"]

attribute "deploy/sarmus_port",
  :display_name => "sarmus port",
  :required => "optional",
  :default => "27017",
  :recipes => ["deploy::foundation_services", "deploy::provision", "deploy::smoke_tests_global", "deploy::smoke_tests_local_app"]

attribute "deploy/sarmus_loglevel",
  :display_name => "sarmus loglevel",
  :required => "optional",
  :default => "4",
  :recipes => ["deploy::sarmus"]

attribute "deploy/sarmus_logsize",
  :display_name => "sarmus logsize",
  :required => "optional",
  :default => "209715200",
  :recipes => ["deploy::sarmus"]

attribute "deploy/sarmus_days_to_keep_logs",
  :display_name => "sarmus days to keep logs",
  :required => "optional",
  :default => "2",
  :recipes => ["deploy::sarmus"]

attribute "deploy/tenant",
  :display_name => "tenant",
  :required => "required",
  :recipes => ["deploy::provision", "deploy::smoke_tests_global"]

attribute "deploy/use_mocked_website",
  :display_name => "use mocked website",
  :description => "used to mock jspr to be able to run the ui tests",
  :required => "optional",
  :default => "false",
  :recipes => ["deploy::jspr"]

### attributes used from other cookbooks
attribute "core/server_type",
  :display_name => "server type",
  :description => "eg: db, app, web, cache",
  :required => "required",
  :recipes => ["deploy::smoke_tests_local_app", "deploy::smoke_tests_local_cache", "deploy::smoke_tests_local_db", "deploy::smoke_tests_local_web"]



