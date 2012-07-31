maintainer       "Cloud Infrastructure"
maintainer_email "ugf_ci@ultimatesoftware.com"
license          "our license"
description      "Installs basic tools to manage any instance"
long_description ""
version          "0.0.1"

supports "ubuntu"

recipe "core::install_gems", "Installs ruby gems"
recipe "core::install_ruby", "Installs ruby from source"
recipe "core::netsh_advfirewall_management", "Disables Windows Firewall"
recipe "core::set_rightscale_account", "sets the Rightscale account"
recipe "core::setup_powershell_runtimes", "Allows up the poweshell to run multiple runtimes"
recipe "core::tag_server_hostname", "Tags the server host name"
recipe "core::tag_server_type", "Tags the server type"

attribute "core/aws_access_key_id",
  :display_name => "aws access key id",
  :required => "required",
  :recipes => ["core::install_ruby"]

attribute "core/aws_secret_access_key",
  :display_name => "aws secret access key",
  :required => "required",
  :recipes => ["core::install_ruby"]

attribute "core/server_type",
  :display_name => "server type",
  :description => "eg: db, app, web, cache, messaging, or search",
  :required => "required",
  :recipes => ["core::tag_server_type"]
