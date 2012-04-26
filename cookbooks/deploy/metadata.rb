maintainer       "Cloud Infrastructure"
maintainer_email "ugf_ci@ultimatesoftware.com"
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
recipe "deploy::download_binaries", "Downloads binaries"
recipe "deploy::download_pims", "Downloads pims"
recipe "deploy::elastic_search", "Deploys ElasticSearch"
recipe "deploy::enable_msmq", "Enables msmq"
recipe "deploy::launch_activemq", "Launches ActiveMQ"
recipe "deploy::launch_mule",  "Launches Mule"
recipe "deploy::mule", "Deploys Mule ESB"
recipe "deploy::engine", "Deploys Engine"
recipe "deploy::foundation_services", "Deploys the foundation rest services"
recipe "deploy::install_event_router_service", "Installs Event Router Service"
recipe "deploy::jspr", "Deploys the web server websites"
recipe "deploy::mongo", "Deploys mongodb"
recipe "deploy::provision", "Provisions basic system data"
recipe "deploy::reindex_elastic_search", "Reindexes ElasticSearch (should be going away)"
recipe "deploy::register_cache_hostname", "Registers the cache hostname and ip in the hosts file"
recipe "deploy::tag_data_version", "Writes a tag denoting what data version has been applied to this server"
recipe "deploy::wait_for_server_with_tag", "Waits for server to have a tag"

attribute "deploy/activemq_port",
  :display_name => "activemq port",
  :required => "optional",
  :default  => "61616",
  :recipes  => ["deploy::launch_activemq"]

attribute "deploy/activemq_version",
  :display_name => "activeMQ version",
  :required => "optional",
  :default  => "5.4.3",
  :recipes  => ["deploy::activemq"]

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
  :recipes  => ["deploy::engine", "deploy::jspr", "deploy::provision"]

attribute "deploy/aws_access_key_id",
  :display_name => "aws access key id",
  :required => "required",
  :recipes => ["deploy::activemq", "deploy::download_binaries", "deploy::download_pims", "deploy::elastic_search", "deploy::mongo"]

attribute "deploy/aws_secret_access_key",
  :display_name => "aws secret access key",
  :required => "required",
  :recipes => ["deploy::activemq", "deploy::download_binaries", "deploy::download_pims", "deploy::elastic_search", "deploy::mongo"]

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
  :recipes => ["deploy::foundation_services", "deploy::register_cache_hostname"]

attribute "deploy/db_port",
  :display_name => "db port",
  :required => "optional",
  :default  => "27017",
  :recipes  => ["deploy::foundation_services", "deploy::mongo", "deploy::provision"]

attribute "deploy/db_server",
  :display_name => "db server",
  :required => "required",
  :recipes => ["deploy::foundation_services", "deploy::provision"]

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
  :recipes => ["deploy::foundation_services"]

attribute "deploy/elastic_search_version",
  :display_name => "elastic search version",
  :required => "optional",
  :default => "0.17.6",
  :recipes => ["deploy::elastic_search"]

attribute "deploy/force_provision",
  :display_name => "force provision",
  :required => "required",
  :recipes => ["deploy::provision"]

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

attribute "deploy/server_manager_features",
  :display_name => "MSMQ features",
  :description => "List of windows MSMQ features to install",
  :required    => "optional",
  :default     => "MSMQ-Server;MSMQ-HTTP-Support;MSMQ-Directory",
  :recipes     => ["deploy::enable_msmq","deploy::install_event_router_service"]

attribute "deploy/service_platform",
  :display_name => "EventRouter HTTP runtime",
  :description => "The .net runtime / affinity the  EventRouter service is hosted",
  :required    => "optional",
  :default     => "v4.0_x86",
  :recipes     => ["deploy::install_event_router_service"]

attribute "deploy/service_port",
  :display_name => "EventRouter HTTP Port",
  :description => "HTTP Port the WCF EventRouter service is listening",
  :required    => "optional",
  :default     => "8989",
  :recipes     => ["deploy::install_event_router_service"]

attribute "deploy/tag_key",
  :display_name => "tag key",
  :required => "optional",
  :recipes => ["deploy::wait_for_server_with_tag"]

attribute "deploy/tag_value",
  :display_name => "tag value",
  :required => "optional",
  :recipes => ["deploy::wait_for_server_with_tag"]

attribute "deploy/tenant",
  :display_name => "tenant",
  :required => "required",
  :recipes => ["deploy::provision"]

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
  :recipes  => ["deploy::launch_activemq", "deploy::launch_mule"]