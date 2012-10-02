maintainer       "Cloud Infrastructure"
maintainer_email "ugf_ci@ultimatesoftware.com"
license          "our license"
description      "Deploys the UGF software to the environment"
long_description ""
version          "0.0.1"

supports "ubuntu"

recipe "appfabric::clear_all_caches", "Clears all AppFabric caches"
recipe "appfabric::configure", "Configures AppFabric"
recipe "appfabric::install", "Installs AppFabric"
recipe "appfabric::ensure_is_up", "Ensures AppFabric cache are working"
recipe "appfabric::powershell", "Deploys AppFabric Powershell cmdlets"

attribute "appfabric/security",
  :display_name => "appfabric security",
  :required => "required",
  :recipes => ["appfabric::clear_all_caches", "appfabric::configure", "appfabric::ensure_is_up"]

attribute "appfabric/service_password",
  :display_name => "appfabric service password",
  :required => "required",
  :recipes  => ["appfabric::configure"]

