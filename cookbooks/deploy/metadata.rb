maintainer       "Cloud Infrastructure"
maintainer_email "ugf_ci@ultimatesoftware.com"
license          "our license"
description      "Deploys the UGF software to the environment"
long_description ""
version          "0.0.1"

supports "ubuntu"

depends 'core'
depends 'appfabric'

recipe "deploy::activemq", "Deploys ActiveMQ"
recipe "deploy::activemq_configure", "Configures ActiveMQ"
recipe "deploy::adjust_ulimit", "Adjusts open files limit for log4j"
recipe "deploy::download_binaries", "Downloads binaries"
recipe "deploy::download_infrastructure", "Downloads infrastructure api"
recipe "deploy::elastic_search", "Deploys ElasticSearch"
recipe "deploy::event_router_service", "Installs Event Router Service"
recipe "deploy::foundation_services", "Deploys the foundation rest services"
recipe "deploy::initiate_replica_set_via_tags", "Initiate replica set via tags for mongodb"
recipe "deploy::jspr", "Deploys the web server websites"
recipe "deploy::launch_mule", "Launches Mule"
recipe "deploy::mongo", "Deploys mongodb"
recipe "deploy::mule", "Deploys Mule ESB"
recipe "deploy::mule_configure", "Configures Mule ESB"
recipe "deploy::provision", "Provisions basic system data"
recipe "deploy::recycle_mule", "Recycle mule"
recipe "deploy::register_cache_hostname", "Registers the cache hostname and ip in the hosts file"
recipe "deploy::reindex_elastic_search", "Reindexes ElasticSearch (should be going away)"
recipe "deploy::tag_data_version", "Writes a tag denoting what data version has been applied to this server"
recipe "deploy::validate_configuration_tokens", "Validates that inputs in Mule properties file are current"
recipe "deploy::wait_for_secondary_dbs", "Waits for secondary db servers to become operational"

# Attributes from core cookbook
attribute "core/api_infrastructure_url",
  :display_name => "api infrastructure url",
  :required => "required",
  :recipes => ["deploy::foundation_services"]

attribute "core/aws_access_key_id",
  :display_name => "aws access key id",
  :required => "required",
  :recipes => ["deploy::activemq", "deploy::download_binaries", "deploy::download_infrastructure",
    "deploy::provision", "deploy::elastic_search", "deploy::mongo"]

attribute "core/aws_secret_access_key",
  :display_name => "aws secret access key",
  :required => "required",
  :recipes => ["deploy::activemq", "deploy::download_binaries", "deploy::download_infrastructure",
    "deploy::provision", "deploy::elastic_search", "deploy::mongo"]

attribute "core/deployment_uri",
  :display_name => "deployment uri",
  :required => "required",
  :recipes => ["deploy::foundation_services"]

attribute "core/s3_bucket",
  :display_name => "s3 bucket for the UGF platform",
  :required => "optional",
  :default  => "ugfgate1",
  :recipes  => ["deploy::activemq", "deploy::download_binaries", "deploy::download_infrastructure",
    "deploy::elastic_search", "deploy::mongo", "deploy::mule", "deploy::provision"]

attribute "core/s3_repository",
  :display_name => "s3 repository for the UGF platform",
  :required => "optional",
  :default => "GlobalIncite",
  :recipes => ["deploy::download_binaries", "deploy::provision"]


# Attributes from deploy cookbook
attribute "deploy/admin_password_mongo",
  :display_name => "admin password for mongo",
  :required => "required",
  :recipes  => ["deploy::mule_configure"]

attribute "deploy/admin_user_mongo",
  :display_name => "admin user for mongo",
  :required => "required",
  :recipes  => ["deploy::mule_configure"]

attribute "deploy/app_server",
  :display_name => "app server",
  :required => "required",
  :recipes  => ["deploy::jspr","deploy::mule_configure", "deploy::provision"]

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
  :recipes => ["deploy::event_router_service", "deploy::foundation_services",
    "deploy::mule_configure", "deploy::register_cache_hostname"]

attribute "deploy/db_server",
  :display_name => "db server",
  :required => "required",
  :recipes => ["deploy::event_router_service", "deploy::foundation_services",
    "deploy::mule_configure", "deploy::provision"]

attribute "deploy/deployment_name",
  :display_name => "deployment name",
  :required => "required",
  :recipes => ["deploy::initiate_replica_set_via_tags", "deploy::register_cache_hostname", "deploy::wait_for_secondary_dbs"]

attribute "deploy/domain",
  :display_name => "domain",
  :recipes => ["deploy::jspr"]

attribute "deploy/infrastructure_artifacts",
  :display_name => "infrastructure artifacts",
  :required => "required",
  :recipes => ["deploy::download_infrastructure"]

attribute "deploy/infrastructure_revision",
  :display_name => "infrastructure revision",
  :required => "required",
  :recipes => ["deploy::download_infrastructure"]

attribute "deploy/is_primary_db",
  :display_name => "is primary db server",
  :description => "This db is primary server (true/false)",
  :required => "required",
  :recipes => ["deploy::initiate_replica_set_via_tags", "deploy::wait_for_secondary_dbs"]

attribute "deploy/messaging_server",
  :display_name => "messaging server",
  :description => "Private IP address messaging_server host in this deployment",
  :required => "required",
  :recipes => ["deploy::event_router_service", "deploy::foundation_services",
    "deploy::mule", "deploy::mule_configure"]

attribute "deploy/mongo_version",
  :display_name => "mongo version",
  :required => "optional",
  :default => "2.0.1",
  :recipes => ["deploy::mongo"]

attribute "deploy/mule_home",
  :display_name => "mule home",
  :required => "optional",
  :default => "/opt/mule",
  :recipes => ["deploy::launch_mule"]

attribute "deploy/pims_artifacts",
  :display_name => "pims artifacts",
  :required => "required",
  :recipes => ["deploy::provision"]

attribute "deploy/pims_revision",
  :display_name => "pims revision",
  :required => "required",
  :recipes => ["deploy::provision"]

attribute "deploy/s3_api_repository",
  :display_name => "s3 repository for the services api",
  :required => "optional",
  :default  => "Infrastructure",
  :recipes  => ["deploy::download_infrastructure"]

attribute "deploy/search_server",
  :display_name => "search_server",
  :recipes => ["deploy::foundation_services", "deploy::mule_configure"]

attribute "deploy/server_name",
  :display_name => "server name",
  :required => "required",
  :recipes => ["deploy::initiate_replica_set_via_tags"]

attribute "deploy/tenant",
  :display_name => "tenant",
  :required => "required",
  :recipes => ["deploy::jspr", "deploy::mule_configure", "deploy::provision"]

attribute "deploy/use_replication",
  :display_name => "use replication",
  :description => "Should use replication set (true/false)",
  :required => "required",
  :recipes => ["deploy::initiate_replica_set_via_tags"]

attribute "deploy/web_server",
  :display_name => "web server",
  :required => "required",
  :recipes  => ["deploy::mule_configure"]
