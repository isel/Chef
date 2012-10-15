maintainer       "Cloud Infrastructure"
maintainer_email "ugf_ci@ultimatesoftware.com"
license          "our license"
description      "Installs basic tools to manage any instance"
long_description ""
version          "0.0.1"

supports "ubuntu"

recipe "core::download_vendor_artifacts_prereqs", "Sets up prereqs for downloading vendor artifacts"
recipe "core::get_deployment_settings", "Gets the deployment settings from the services api"
recipe "core::install_jdk", "Installs jdk for windows and ubuntu"
recipe "core::install_ruby", "Installs ruby from source"
recipe "core::netsh_advfirewall_management", "Disables Windows Firewall"
recipe "core::set_rightscale_account", "sets the Rightscale account"
recipe "core::setup_powershell_runtimes", "Allows up the poweshell to run multiple runtimes"
recipe "core::tag_server_hostname", "Tags the server host name"
recipe "core::tag_server_type", "Tags the server type"

attribute "core/api_infrastructure_url",
  :display_name => "api infrastructure url",
  :required => "required",
  :recipes => ["core::get_deployment_settings"]

attribute "core/aws_access_key_id",
  :display_name => "aws access key id",
  :required => "required",
  :recipes => ["core::install_ruby", "core::install_jdk"]

attribute "core/aws_secret_access_key",
  :display_name => "aws secret access key",
  :required => "required",
  :recipes => ["core::install_ruby", "core::install_jdk"]

attribute "core/deployment_uri",
  :display_name => "deployment uri",
  :required => "required",
  :recipes => ["core::get_deployment_settings"]

attribute "core/server_type",
  :display_name => "server type",
  :description => "eg: db, app, web, cache, messaging, or search",
  :required => "required",
  :recipes => ["core::tag_server_type"]

attribute "core/s3_bucket",
  :display_name => "s3 bucket for the UGF platform",
  :description => "i.e. ugfartifacts, ugfproduction",
  :required => "optional",
  :default  => "ugfgate1",
  :recipes => ["core::install_ruby", "core::install_jdk"]
