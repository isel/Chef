maintainer       "Cloud Infrastructure"
maintainer_email "ugf_ci@ultimatesoftware.com"
license          "our license"
description      "Deploys the UGF software to the environment"
long_description ""
version          "0.0.1"

supports "ubuntu"

recipe "jspr::default", "Deploys the jspr website"

attribute "deploy/app_server",
  :display_name => "app server",
  :required => "required",
  :recipes  => ["jspr::default"]

attribute "deploy/domain",
  :display_name => "domain",
  :recipes => ["jspr::default"]

attribute "deploy/tenant",
  :display_name => "tenant",
  :required => "required",
  :recipes => ["jspr::default"]
