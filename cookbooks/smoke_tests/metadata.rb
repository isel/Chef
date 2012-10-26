maintainer "Cloud Infrastructure"
maintainer_email "ugf_ci@ultimatesoftware.com"
license "our license"
description "Contains local and global smoke tests for UGF cloud environments"
long_description ""
version "0.0.1"

supports "ubuntu"

recipe "smoke_tests::global", "Runs global smoke tests"

recipe "smoke_tests::local_app", "Runs local app server smoke tests"
recipe "smoke_tests::sanity_app", "Runs sanity app server smoke tests"

recipe "smoke_tests::local_cache", "Runs local cache server smoke tests"
recipe "smoke_tests::local_db", "Runs local db server smoke tests"
recipe "smoke_tests::local_loadbalancer", "Runs local load balancer server smoke tests"
recipe "smoke_tests::local_web", "Runs local web server smoke tests"

### attributes used from other cookbooks
attribute "core/server_type",
  :display_name => "server type",
  :description => "eg: db, app, web, cache",
  :required => "required",
  :recipes => [
    "smoke_tests::sanity_app",
    "smoke_tests::local_app", "smoke_tests::local_cache", "smoke_tests::local_db", "smoke_tests::local_loadbalancer",
    "smoke_tests::local_web"
  ]

attribute "deploy/admin_password_mongo",
  :display_name => "admin password for mongo",
  :required => "required",
  :recipes  => ["smoke_tests::global", "smoke_tests::local_db"]

attribute "deploy/admin_user_mongo",
  :display_name => "admin user for mongo",
  :required => "required",
  :recipes  => ["smoke_tests::global", "smoke_tests::local_db"]

attribute "deploy/app_server",
  :display_name => "app server",
  :required => "required",
  :recipes => ["smoke_tests::global", "smoke_tests::local_app", "smoke_tests::local_web"]

attribute "deploy/domain",
  :display_name => "domain",
  :recipes => ["smoke_tests::local_web"]

attribute "deploy/db_server",
  :display_name => "db server",
  :required => "required",
  :recipes => ["smoke_tests::global", "smoke_tests::local_app"]

attribute "deploy/tenant",
  :display_name => "tenant",
  :required => "required",
  :recipes => ["smoke_tests::global"]
