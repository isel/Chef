maintainer       "Cloud Infrastructure"
maintainer_email "ugf_ci@ultimatesoftware.com"
license          "our license"
description      "Deploys the UGF software to the environment"
long_description ""
version          "0.0.1"

supports "ubuntu"

depends "rightscale"
depends 'core'
depends 'appfabric'

recipe "deploy::add_admin_replica_set", "Add admin user for mongo with replica set"
recipe "deploy::download_binaries", "Downloads binaries"
recipe "deploy::download_infrastructure", "Downloads infrastructure api"
recipe "deploy::foundation_services", "Deploys the foundation rest services"
recipe "deploy::initiate_replica_set_via_tags", "Initiate replica set via tags for mongodb"
recipe "deploy::mongo", "Deploys mongodb"
recipe "deploy::provision", "Provisions basic system data"
recipe "deploy::register_cache_hostname", "Registers the cache hostname and ip in the hosts file"
recipe "deploy::tag_data_version", "Writes a tag denoting what data version has been applied to this server"
recipe "deploy::wait_for_secondary_dbs", "Waits for secondary db servers to become operational"

# Attributes from core cookbook
attribute "core/api_infrastructure_url",
  :display_name => "api infrastructure url",
  :required => "required",
  :recipes => ["deploy::foundation_services"]

attribute "core/aws_access_key_id",
  :display_name => "aws access key id",
  :required => "required",
  :recipes => ["deploy::download_binaries", "deploy::download_infrastructure", "deploy::provision", "deploy::mongo"]

attribute "core/aws_secret_access_key",
  :display_name => "aws secret access key",
  :required => "required",
  :recipes => ["deploy::download_binaries", "deploy::download_infrastructure", "deploy::provision", "deploy::mongo"]

attribute "core/deployment_uri",
  :display_name => "deployment uri",
  :required => "required",
  :recipes => ["deploy::foundation_services"]

attribute "core/s3_bucket",
  :display_name => "s3 bucket for the UGF platform",
  :required => "optional",
  :default  => "ugfgate1",
  :recipes  => ["deploy::download_binaries", "deploy::download_infrastructure", "deploy::mongo", "deploy::provision"]

attribute "core/s3_repository",
  :display_name => "s3 repository for the UGF platform",
  :required => "optional",
  :default => "GlobalIncite",
  :recipes => ["deploy::download_binaries", "deploy::provision"]


# Attributes from deploy cookbook
attribute "deploy/admin_password_mongo",
  :display_name => "admin password for mongo",
  :required => "required",
  :recipes  => ["deploy::add_admin_replica_set", "deploy::foundation_services", "deploy::provision"]

attribute "deploy/admin_user_mongo",
  :display_name => "admin user for mongo",
  :required => "required",
  :recipes  => ["deploy::add_admin_replica_set", "deploy::foundation_services", "deploy::provision"]

attribute "deploy/app_server",
  :display_name => "app server",
  :required => "required",
  :recipes  => ["deploy::provision"]

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

attribute "deploy/db_server",
  :display_name => "db server",
  :required => "required",
  :recipes => ["deploy::foundation_services", "deploy::provision"]

attribute "deploy/deployment_name",
  :display_name => "deployment name",
  :required => "required",
  :recipes => ["deploy::initiate_replica_set_via_tags", "deploy::register_cache_hostname", "deploy::wait_for_secondary_dbs"]

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
  :recipes => ["deploy::add_admin_replica_set", "deploy::initiate_replica_set_via_tags", "deploy::wait_for_secondary_dbs"]

attribute "deploy/mongo_version",
  :display_name => "mongo version",
  :required => "optional",
  :default => "2.0.1",
  :recipes => ["deploy::mongo"]

attribute "deploy/metadata_artifacts",
  :display_name => "metadata artifacts",
  :required => "required",
  :recipes => ["deploy::provision"]

attribute "deploy/metadata_revision",
  :display_name => "metadata revision",
  :required => "required",
  :recipes => ["deploy::provision"]

attribute "deploy/s3_api_repository",
  :display_name => "s3 repository for the services api",
  :required => "optional",
  :default  => "Infrastructure",
  :recipes  => ["deploy::download_infrastructure"]

attribute "deploy/server_name",
  :display_name => "server name",
  :required => "required",
  :recipes => ["deploy::initiate_replica_set_via_tags"]

attribute "deploy/tenant",
  :display_name => "tenant",
  :required => "required",
  :recipes => ["deploy::provision"]

attribute "deploy/use_replication",
  :display_name => "use replication",
  :description => "Should use replication set (true/false)",
  :required => "required",
  :recipes => ["deploy::add_admin_replica_set", "deploy::initiate_replica_set_via_tags"]

