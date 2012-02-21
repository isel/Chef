maintainer       "Isel Fernandez"
maintainer_email "isel_77@hotmail.com"
license          "our license"
description      "Deploys the UGF software to the environment"
long_description ""
version          "0.0.1"

supports "ubuntu"

recipe "deploy::appfabric_configure", "Configures AppFabric"
recipe "deploy::appfabric_powershell", "Deploys AppFabric Powershell cmdlets"
recipe "deploy::appfabric_ensure_is_up", "Ensures AppFabric cache are working"
recipe "deploy::download_artifacts", "Downloads artifacts"
recipe "deploy::elastic_search", "Deploys ElasticSearch"
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
recipe "deploy::smoke_tests_local_web", "Runs local web server smoke tests"
recipe "deploy::register_cache_hostname", "Registers the cache hostname and ip in the hosts file"
recipe "deploy::tag_data_version", "Writes a tag denoting what data version has been applied to this server"

attribute "deploy/appfabric_caches",
  :display_name => "appfabric caches",
  :required => "required",
  :recipes => ["deploy::appfabric_configure", "deploy::appfabric_ensure_is_up"]

attribute "deploy/appfabric_security",
  :display_name => "appfabric security",
  :required => "required",
  :recipes => ["deploy::appfabric_configure"]

attribute "deploy/appfabric_service_user",
  :display_name => "appfabric service user",
  :required => "required",
  :recipes => ["deploy::appfabric_configure"]

attribute "deploy/appfabric_service_password",
  :display_name => "appfabric service password",
  :required => "required",
  :recipes => ["deploy::appfabric_configure"]

attribute "deploy/appfabric_shared_drive",
  :display_name => "appfabric shared drive",
  :required => "required",
  :recipes => ["deploy::appfabric_configure"]

attribute "deploy/appfabric_shared_folder",
  :display_name => "appfabric shared folder",
  :required => "required",
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
  :recipes => ["deploy::download_artifacts", "deploy::elastic_search"]

attribute "deploy/aws_secret_access_key",
  :display_name => "aws secret access key",
  :required => "required",
  :recipes => ["deploy::download_artifacts", "deploy::elastic_search"]

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
  :required => "required",
  :recipes => ["deploy::foundation_services", "deploy::smoke_tests_local_app"]

attribute "deploy/elastic_search_version",
  :display_name => "elastic search version",
  :required => "required",
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
  :required => "required",
  :recipes => ["deploy::mongo"]

attribute "deploy/mongo_version",
  :display_name => "mongo version",
  :required => "required",
  :recipes => ["deploy::mongo"]

attribute "deploy/revision",
  :display_name => "revision",
  :required => "required",
  :recipes => ["deploy::sarmus", "deploy::download_artifacts", "deploy::tag_data_version"]

attribute "deploy/sarmus_port",
  :display_name => "sarmus port",
  :required => "required",
  :recipes => ["deploy::foundation_services", "deploy::provision", "deploy::smoke_tests_global", "deploy::smoke_tests_local_app"]

attribute "deploy/tenant",
  :display_name => "tenant",
  :required => "required",
  :recipes => ["deploy::provision", "deploy::smoke_tests_global"]

### attributes used from other cookbooks
attribute "core/server_type",
  :display_name => "server type",
  :description => "eg: db, app, web, cache",
  :required => "required",
  :recipes => ["deploy::smoke_tests_local_app", "deploy::smoke_tests_local_cache", "deploy::smoke_tests_local_db", "deploy::smoke_tests_local_web"]



