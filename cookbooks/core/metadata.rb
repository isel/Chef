maintainer       "Cloud Infrastructure"
maintainer_email "ugf_ci@ultimatesoftware.com"
license          "our license"
description      "Installs basic tools to manage any instance"
long_description ""
version          "0.0.1"

supports "ubuntu"

depends "rightscale"

recipe "core::download_product_artifacts_prereqs", "Sets up prereqs for downloading product artifacts"
recipe "core::download_vendor_artifacts_prereqs", "Sets up prereqs for downloading vendor artifacts"
recipe "core::get_deployment_settings", "Gets the deployment settings from the services api"
recipe "core::netsh_advfirewall_management", "Disables Windows Firewall"
recipe "core::set_rightscale_account", "sets the Rightscale account"
recipe "core::setup_powershell_runtimes", "Allows up the poweshell to run multiple runtimes"
recipe "core::tag_server_hostname", "Tags the server host name"
recipe "core::tag_server_type", "Tags the server type"

attribute "core/api_infrastructure_url",
  :display_name => "api infrastructure url",
  :required => "required",
  :recipes => ["core::get_deployment_settings"]

attribute "core/deployment_uri",
  :display_name => "deployment uri",
  :required => "required",
  :recipes => ["core::get_deployment_settings"]

attribute "core/server_type",
  :display_name => "server type",
  :description => "eg: db, app, web, cache, messaging, or search",
  :required => "required",
  :recipes => ["core::tag_server_type"]