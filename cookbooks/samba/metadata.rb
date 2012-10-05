maintainer       "Cloud Infrastructure"
maintainer_email "ugf_ci@ultimatesoftware.com"
license          "our license"
description      "Deploys samba"
long_description ""
version          "0.0.1"

supports "ubuntu"

recipe "samba::default", "Installs samba"
recipe "samba::configure", "Configures samba"

attribute "samba/password",
  :display_name => "password",
  :required => "required",
  :recipes => ["samba::configure"]

attribute "deploy/mule_home",
  :display_name => "mule home",
  :required => "optional",
  :default => "/opt/mule",
  :recipes => ["deploy::launch_mule"]
