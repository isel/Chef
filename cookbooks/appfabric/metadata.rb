maintainer       "Cloud Infrastructure"
maintainer_email "ugf_ci@ultimatesoftware.com"
license          "our license"
description      "Deploys the UGF software to the environment"
long_description ""
version          "0.0.1"

supports "ubuntu"

recipe "appfabric::configure", "Configures AppFabric"
recipe "appfabric::ensure_is_up", "Ensures AppFabric cache are working"
recipe "appfabric::powershell", "Deploys AppFabric Powershell cmdlets"

attribute "appfabric/caches",
  :display_name => "appfabric caches",
  :required => "optional",
  :default => "default,TokenStore,SaasPolicy,EntityModel,Securables,Messages,Views,Enumerations,BusinessProcess",
  :recipes => ["appfabric::configure", "appfabric::ensure_is_up"]

attribute "appfabric/security",
  :display_name => "appfabric security",
  :required => "required",
  :recipes => ["appfabric::configure"]

attribute "appfabric/service_password",
  :display_name => "appfabric service password",
  :required => "required",
  :recipes  => ["appfabric::configure"]

attribute "appfabric/service_user",
  :display_name => "appfabric service user",
  :required => "optional",
  :default => "appfabric",
  :recipes => ["appfabric::configure"]

attribute "appfabric/shared_drive",
  :display_name => "appfabric shared drive",
  :required => "optional",
  :default => "appfabric_caching",
  :recipes => ["appfabric::configure"]

attribute "appfabric/shared_folder",
  :display_name => "appfabric shared folder",
  :required => "optional",
  :default => "c:\\appfabric_caching",
  :recipes => ["appfabric::configure"]