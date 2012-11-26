maintainer       "Cloud Infrastructure"
maintainer_email "csf@ultimatesoftware.com"
license          "our license"
description      "Deploys the UGF software to the environment"
long_description ""
version          "0.0.1"

supports "windows"

recipe "mssql::set_sa_password", "sets sa password"

attribute "mssql/sa_password",
  :display_name => "sa password",
  :required => "required",
  :recipes => ["mssql::set_sa_password"]