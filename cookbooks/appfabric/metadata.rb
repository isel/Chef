maintainer       "Cloud Infrastructure"
maintainer_email "ugf_ci@ultimatesoftware.com"
license          "our license"
description      "Deploys the UGF software to the environment"
long_description ""
version          "0.0.1"

supports "windows"

depends 'core'

recipe "appfabric::clear_all_caches", "Clears all AppFabric caches"
recipe "appfabric::configure", "Configures AppFabric"
recipe "appfabric::install", "Installs AppFabric"
recipe "appfabric::ensure_is_up", "Ensures AppFabric cache are working"
recipe "appfabric::powershell", "Deploys AppFabric Powershell cmdlets"

attribute "core/aws_access_key_id",
  :display_name => "aws access key id",
  :required => "required",
  :recipes => ["access_database_engine::default"]

attribute "core/aws_secret_access_key",
  :display_name => "aws secret access key",
  :required => "required",
  :recipes => ["access_database_engine::default"]

attribute "core/s3_bucket",
  :display_name => "s3 bucket for the UGF platform",
  :description => "i.e. ugfartifacts, ugfproduction",
  :required => "optional",
  :default => "ugfgate1",
  :recipes => ["access_database_engine::default"]

attribute "appfabric/security",
  :display_name => "appfabric security",
  :required => "required",
  :recipes => ["appfabric::clear_all_caches", "appfabric::configure", "appfabric::ensure_is_up"]

attribute "appfabric/service_password",
  :display_name => "appfabric service password",
  :required => "required",
  :recipes  => ["appfabric::configure"]

