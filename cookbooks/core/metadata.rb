maintainer       "Cloud Infrastructure"
maintainer_email "ugf_ci@ultimatesoftware.com"
license          "our license"
description      "Installs basic tools to manage any instance"
long_description ""
version          "0.0.1"

supports "ubuntu"

recipe "core::install_gems", "Installs ruby gems"
recipe "core::tag_server_hostname", "Tags the server host name"
recipe "core::tag_server_type", "Tags the server type"
recipe "core::setup_powershell_runtimes", "Allows up the poweshell to run multiple runtimes"

attribute "core/server_type",
  :display_name => "server type",
  :description => "eg: db, app, web, cache",
  :required => "required",
  :recipes => ["core::tag_server_type"]


