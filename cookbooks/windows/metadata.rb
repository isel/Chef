maintainer       "Cloud Infrastructure"
maintainer_email "csf@ultimatesoftware.com"
license          "our license"
description      "Deploys the UGF software to the environment"
long_description ""
version          "0.0.1"

supports "windows"

recipe "windows::assign_logon_as_a_service_to_administrator", "assign logon as a service to administrator"
recipe "windows::set_administrator_password", "sets the administrator password"

attribute "windows/administrator_password",
  :display_name => "administrator password",
  :required => "required",
  :recipes => ["windows::set_administrator_password"]