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
recipe "deploy::configure_load_balancer_forwarding", "Adds an entry vhost (frontend) that forwards requests to the next target"
recipe "deploy::download_artifacts", "Downloads artifacts"
recipe "deploy::download_binaries", "Downloads binaries"
recipe "deploy::download_pims", "Downloads pims"
recipe "deploy::elastic_search", "Deploys ElasticSearch"
recipe "deploy::enable_msmq", "Enables msmq"
recipe "deploy::launch_activemq", "Launches ActiveMQ"
recipe "deploy::launch_mule",  "Launches Mule"
recipe "deploy::mule", "Deploys Mule ESB"
recipe "deploy::engine", "Deploys Engine"
recipe "deploy::foundation_services", "Deploys the foundation rest services"
recipe "deploy::jspr", "Deploys the web server websites"
recipe "deploy::mongo", "Deploys mongodb"
recipe "deploy::provision", "Provisions basic system data"
recipe "deploy::register_appserver_with_haproxy", "Registers an app server with each load balancer"
recipe "deploy::reindex_elastic_search", "Reindexes ElasticSearch (should be going away)"
recipe "deploy::smoke_tests_global", "Runs global smoke tests"
recipe "deploy::smoke_tests_local_app", "Runs local app server smoke tests"
recipe "deploy::smoke_tests_local_cache", "Runs local cache server smoke tests"
recipe "deploy::smoke_tests_local_db", "Runs local db server smoke tests"
recipe "deploy::smoke_tests_local_engine", "Runs local engine server smoke tests"
recipe "deploy::smoke_tests_local_messaging", "Runs local messaging server smoke tests"
recipe "deploy::smoke_tests_local_web", "Runs local web server smoke tests"
recipe "deploy::register_cache_hostname", "Registers the cache hostname and ip in the hosts file"
recipe "deploy::tag_data_version", "Writes a tag denoting what data version has been applied to this server"

attribute "deploy/app_listener_names",
  :display_name => "app listener names",
  :description => "specifies which HAProxy servers pool to use",
  :required => "optional",
  :default  => "api80,api81,api82",
  :recipes => ["deploy::register_appserver_with_haproxy"]

attribute "deploy/backend_name",
  :display_name => "backend name",
  :description => "A unique name for each back end e.g. (RS_INSTANCE_UUID)",
  :required => "required",
  :recipes  => ["deploy::register_appserver_with_haproxy"]

attribute "deploy/dns_name",
  :display_name => "dns name",
  :description => "DNS name of the front ends",
  :required => "required",
  :recipes  => ["deploy::register_appserver_with_haproxy"]

attribute "deploy/max_connections_per_lb",
  :display_name => "max connection per load balancer",
  :description => "Maximum number of connections per server",
  :required => "optional",
  :default  => "255",
  :recipes  => ["deploy::register_appserver_with_haproxy"]

attribute "deploy/health_check_uri",
  :display_name => "health check uri",
  :description => "Page to report the heart beat so the lb knows whether the server is up or not",
  :required => "optional",
  :default  => "/HealthCheck.html",
  :recipes  => ["deploy::register_appserver_with_haproxy"]

attribute "deploy/private_ssh_key",
  :display_name => "private ssh key",
  :description => "The ssh key used to connect to the load balancer",
  :required => "required",
  :recipes  => ["deploy::register_appserver_with_haproxy"]

attribute "deploy/web_server_ports",
  :display_name => "web server ports",
  :required => "optional",
  :default  => "80,81,82",
  :recipes  => ["deploy::register_appserver_with_haproxy"]

attribute "deploy/session_stickiness",
  :display_name => "session stickiness",
  :required => "optional",
  :default  => "false",
  :recipes  => ["deploy::register_appserver_with_haproxy"]

attribute "deploy/activemq_port",
  :display_name => "activemq port",
  :required => "optional",
  :default  => "61616",
  :recipes  => ["deploy::launch_activemq", "deploy::smoke_tests_local_messaging"]

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
  :recipes => ["deploy::download_binaries", "deploy::tag_data_version"]

attribute "deploy/cache_server",
  :display_name => "cache server",
  :required => "required",
  :recipes => ["deploy::foundation_services", "deploy::register_cache_hostname"]

attribute "deploy/db_port",
  :display_name => "db port",
  :required => "optional",
  :default  => "27017",
  :recipes  => ["deploy::foundation_services", "deploy::mongo", "deploy::provision", "deploy::smoke_tests_global", "deploy::smoke_tests_local_app"]

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

attribute "deploy/lb_application",
  :display_name => "lb application",
  :description => "Sets the directory for your application's web files (/home/webapps/APPLICATION/current/). If you have multiple applications, you can run the code checkout script multiple times, each with a different value for APPLICATION, so each application will be stored in a unique directory. This must be a valid directory name. Do not use symbols in the name.",
  :required => "optional",
  :default => "globalincite",
  :recipes => ["deploy::configure_load_balancer_forwarding"]

attribute "deploy/lb_maintenance_page",
  :display_name => "lb maintenance page",
  :description => "Optional path for a maintenance page, relative to document root (i.e., "".../current/public""). The file must exist in the subtree of the vhost, which will be served by the web server if it's present. If ignored, it will default to '/system/maintenance.html'.",
  :required => "optional",
  :default => "/system/maintenance.html",
  :recipes => ["deploy::configure_load_balancer_forwarding"]

attribute "deploy/lb_website_dns",
  :display_name => "lb website dns",
  :description => "The fully qualified domain name that the server will accept traffic for. Ex: www.globalincite.com",
  :required => "required",
  :recipes => ["deploy::configure_load_balancer_forwarding"]

attribute "deploy/mongo_version",
  :display_name => "mongo version",
  :required => "optional",
  :default => "2.0.1",
  :recipes => ["deploy::mongo"]

attribute "deploy/mule_port",
  :display_name => "mule port",
  :required => "optional",
  :default  => "8585",
  :recipes  => ["deploy::launch_mule", "deploy::smoke_tests_local_messaging"]

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

attribute "deploy/revision",
  :display_name => "revision",
  :required => "required",
  :recipes => ["deploy::download_artifacts"]

attribute "deploy/server_manager_features",
  :display_name => "MSMQ features",
  :description => "List of windows MSMQ features to install",
  :required    => "optional",
  :default     => "MSMQ-Server;MSMQ-HTTP-Support;MSMQ-Directory;MSMS-NoSuchFeature",
  :recipes     => ["deploy::enable_msmq"]

attribute "deploy/tenant",
  :display_name => "tenant",
  :required => "required",
  :recipes => ["deploy::provision", "deploy::smoke_tests_global"]

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

### attributes used from other cookbooks
attribute "core/server_type",
  :display_name => "server type",
  :description => "eg: db, app, web, cache",
  :required => "required",
  :recipes => ["deploy::smoke_tests_local_app", "deploy::smoke_tests_local_cache", "deploy::smoke_tests_local_db", "deploy::smoke_tests_local_web" "deploy::smoke_tests_local_messaging"]
