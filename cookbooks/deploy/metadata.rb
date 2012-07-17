maintainer       "Cloud Infrastructure"
maintainer_email "ugf_ci@ultimatesoftware.com"
license          "our license"
description      "Deploys the UGF software to the environment"
long_description ""
version          "0.0.1"

supports "ubuntu"

recipe "deploy::update_configuration_tokens" , "Updates Mule properties file"
recipe "deploy::validate_configuration_tokens" , "Validates that inputs in Mule properties file are current"
recipe "deploy::activemq", "Deploys ActiveMQ"
recipe "deploy::adjust_ulimit", "Adjusts open files limit for log4j"
recipe "deploy::appfabric_configure", "Configures AppFabric"
recipe "deploy::appfabric_ensure_is_up", "Ensures AppFabric cache are working"
recipe "deploy::appfabric_powershell", "Deploys AppFabric Powershell cmdlets"
recipe "deploy::download_binaries", "Downloads binaries"
recipe "deploy::download_infrastructure", "Downloads infrastructure api"
recipe "deploy::download_pims", "Downloads pims"
recipe "deploy::elastic_search", "Deploys ElasticSearch"
recipe "deploy::enable_msmq", "Enables msmq"
recipe "deploy::engine", "Deploys Engine"
recipe "deploy::event_router_service", "Installs Event Router Service"
recipe "deploy::foundation_services", "Deploys the foundation rest services"
recipe "deploy::jspr", "Deploys the web server websites"
recipe "deploy::launch_activemq", "Launches ActiveMQ"
recipe "deploy::launch_mule",  "Launches Mule"
recipe "deploy::mongo", "Deploys mongodb"
recipe "deploy::mule", "Deploys Mule ESB"
recipe "deploy::provision", "Provisions basic system data"
recipe "deploy::recycle_mule", "Recycle mule"
recipe "deploy::register_cache_hostname", "Registers the cache hostname and ip in the hosts file"
recipe "deploy::reindex_elastic_search", "Reindexes ElasticSearch (should be going away)"
recipe "deploy::tag_data_version", "Writes a tag denoting what data version has been applied to this server"

attribute "deploy/activemq_port",
  :display_name => "activemq port",
  :required => "optional",
  :default  => "61616",
  :recipes  => ["deploy::launch_activemq"]

attribute "deploy/activemq_version",
  :display_name => "activeMQ version",
  :required => "optional",
  :default  => "5.6.0",
  :recipes  => ["deploy::activemq"]

attribute "deploy/appfabric_caches",
  :display_name => "appfabric caches",
  :required => "optional",
  :default => "default,TokenStore,SaasPolicy,EntityModel,Securables,Messages,Views,Enumerations,BusinessProcess",
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

attribute "deploy/messaging_server",
:display_name => "messaging_server",
:description => "Private IP address messaging_server host in this deployment",
:required => "required",
:recipes  => ["deploy::event_router_service", "deploy::foundation_services", "deploy:mule"]

attribute "deploy/app_server",
  :display_name => "app server",
  :required => "required",
  :recipes  => ["deploy::engine", "deploy::jspr", "deploy::provision", "deploy:mule"]

attribute "deploy/aws_access_key_id",
  :display_name => "aws access key id",
  :required => "required",
  :recipes => ["deploy::activemq", "deploy::download_binaries", "deploy::download_infrastructure", "deploy::download_pims", "deploy::elastic_search", "deploy::mongo"]

attribute "deploy/aws_secret_access_key",
  :display_name => "aws secret access key",
  :required => "required",
  :recipes => ["deploy::activemq", "deploy::download_binaries", "deploy::download_infrastructure", "deploy::download_pims", "deploy::elastic_search", "deploy::mongo"]

attribute "deploy/binaries_artifacts",
  :display_name => "binaries artifacts",
  :required => "required",
  :recipes => ["deploy::download_binaries"]

attribute "deploy/binaries_revision",
  :display_name => "binaries revision",
  :required => "required",
  :recipes => ["deploy::download_binaries", "deploy::tag_data_version"]

attribute "deploy/cache_server",
  :display_name => "cache server",
  :required => "required",
  :recipes => ["deploy::foundation_services", "deploy::register_cache_hostname", "deploy:mule"]

attribute "deploy/db_port",
  :display_name => "db port",
  :required => "optional",
  :default  => "27017",
  :recipes  => ["deploy::event_router_service", "deploy::foundation_services", "deploy::mongo", "deploy::provision", "deploy:mule"]

attribute "deploy/db_server",
  :display_name => "db server",
  :required => "required",
  :recipes => ["deploy::event_router_service", "deploy::foundation_services", "deploy::provision", "deploy:mule"]

attribute "deploy/engine_server",
  :display_name => "engine server",
  :required => "required",
  :recipes => ["deploy::mule"]

attribute "deploy/engine_port",
  :display_name => "droolz engine port",
  :required => "optional",
  :default => "8080",
  :recipes => ["deploy::mule"]

attribute "deploy/web_server",
  :display_name => "web server",
  :required => "required",
  :recipes => ["deploy::mule"]

attribute "deploy/deployment_name",
  :display_name => "deployment name",
  :required => "required",
  :recipes => ["deploy::register_cache_hostname"]

attribute "deploy/domain",
  :display_name => "domain",
  :recipes => ["deploy::jspr"]

attribute "deploy/search_server",
  :display_name => "search_server",
  :recipes => ["deploy::foundation_services", "deploy:mule"]

attribute "deploy/elastic_search_port",
  :display_name => "elastic search port",
  :required => "optional",
  :default => "9200",
  :recipes => ["deploy::foundation_services", "deploy:mule"]

attribute "deploy/elastic_search_version",
  :display_name => "elastic search version",
  :required => "optional",
  :default => "0.19.3",
  :recipes => ["deploy::elastic_search"]

attribute "deploy/elastic_search_plugins",
  :display_name => "elastic search plugins",
  :required => "optional",
  :default => "bigdesk,elasticsearch-head,analysis-phonetic,analysis-icu",
  :recipes => ["deploy::elastic_search"]

attribute "deploy/infrastructure_artifacts",
  :display_name => "infrastructure artifacts",
  :required => "required",
  :recipes => ["deploy::download_infrastructure"]

attribute "deploy/infrastructure_revision",
  :display_name => "infrastructure revision",
  :required => "required",
  :recipes => ["deploy::download_infrastructure"]

attribute "deploy/mongo_version",
  :display_name => "mongo version",
  :required => "optional",
  :default => "2.0.1",
  :recipes => ["deploy::mongo"]

attribute "deploy/mule_port",
  :display_name => "mule port",
  :required => "optional",
  :default  => "8585",
  :recipes  => ["deploy::launch_mule"]

attribute "deploy/messaging_server_port",
  :display_name => "messaging server port",
  :required => "optional",
  :default  => "8081",
  :recipes  => ["deploy::event_router_service", "deploy::foundation_services", "deploy::mule"]

attribute "deploy/mule_version",
  :display_name => "mule version",
  :required => "optional",
  :default => "3.3.0",
  :recipes => ["deploy::mule","deploy::recycle_mule"]

attribute "deploy/mule_plugins",
  :display_name => "Mule plugins",
  :description => "List of Mule plugins to install",
  :required    => "optional",
  :default     => "mmc-agent-mule3-app-3.3.0.zip,mmc-distribution-console-app-3.3.0.zip",
  :recipes     => ["deploy::mule","deploy::launch_mule"]

attribute "deploy/pims_artifacts",
  :display_name => "pims artifacts",
  :required => "required",
  :recipes => ["deploy::download_pims"]

attribute "deploy/pims_revision",
  :display_name => "pims revision",
  :required => "required",
  :recipes => ["deploy::download_pims"]

attribute "deploy/s3_api_repository",
  :display_name => "s3 repository for the services api",
  :required => "optional",
  :default  => "Infrastructure",
  :recipes  => ["deploy::download_infrastructure"]

attribute "deploy/s3_bucket",
  :display_name => "s3 bucket for the UGF platform",
  :required => "optional",
  :default  => "ugfartifacts",
  :recipes  => ["deploy::download_binaries", "deploy::download_infrastructure", "deploy::download_pims"]

attribute "deploy/s3_repository",
  :display_name => "s3 repository for the UGF platform",
  :required => "optional",
  :default  => "GlobalIncite",
  :recipes  => ["deploy::download_binaries", "deploy::download_pims"]

attribute "deploy/service_platform",
  :display_name => "EventRouter HTTP runtime",
  :description => "The .net runtime / affinity the  EventRouter service is hosted",
  :required    => "optional",
  :default     => "v4.0_x86",
  :recipes     => ["deploy::event_router_service"]

attribute "deploy/service_port",
  :display_name => "EventRouter HTTP Port",
  :description => "HTTP Port the WCF EventRouter service is listening",
  :required    => "optional",
  :default     => "8989",
  :recipes     => ["deploy::event_router_service"]

attribute "deploy/tenant",
  :display_name => "tenant",
  :required => "required",
  :recipes => ["deploy::engine", "deploy::jspr", "deploy::provision"]

attribute "deploy/ulimit_files",
  :display_name => "setting for log4j",
  :required => "optional",
  :default  => "8192",
  :recipes  => ["deploy::adjust_ulimit", "deploy::launch_mule"]

attribute "deploy/use_mocked_website",
  :display_name => "use mocked website",
  :description => "used to mock jspr to be able to run the ui tests",
  :required => "optional",
  :default => "false",
  :recipes => ["deploy::jspr"]

attribute "deploy/verify_completion",
  :display_name => "run checks",
  :required => "optional",
  :default  => "1",
  :recipes  => ["deploy::launch_activemq", "deploy::launch_mule","deploy::elastic_search"]

attribute "deploy/install_via_git_download" ,
:display_name => "install from plugin developer github ignoring snapshot stored on s3 ",
:required => "optional",
:default  => "",
:recipes  => ["deploy::elastic_search"]

