maintainer       "Isel Fernandez"
maintainer_email "isel_77@hotmail.com"
license          "our license"
description      "Installs basic tools to manage any instance"
long_description ""
version          "0.0.1"

supports "ubuntu"

recipe "core::install_gems", "Installs ruby gems"
recipe "core::tag_server_type", "Tags the server type"

attribute "core/server_type",
  :display_name => "server type",
  :description => "eg: db, app, web, cache",
  :required => "required",
  :recipes => ["core::tag_server_type"]


