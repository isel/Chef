maintainer       "Cloud Infrastructure"
maintainer_email "csf@ultimatesoftware.com"
license          "our license"
description      "Deploys the UGF software to the environment"
long_description ""
version          "0.0.1"

supports "windows"

recipe "windows::execute_batch", "executes a batch file"

attribute "windows/administrator_password",
  :display_name => "administrator password",
  :required => "required",
  :recipes => ["windows::change_administrator_password"]