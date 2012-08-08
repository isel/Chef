maintainer "Cloud Infrastructure"
maintainer_email "ugf_ci@ultimatesoftware.com"
license "our license"
description "Contains local and global smoke tests for UGF cloud environments"
long_description ""
version "0.0.1"

supports "ubuntu"

recipe "smoke_tests::global", "Runs global smoke tests"
recipe "smoke_tests::local_app", "Runs local app server smoke tests"
recipe "smoke_tests::local_cache", "Runs local cache server smoke tests"
recipe "smoke_tests::local_db", "Runs local db server smoke tests"
recipe "smoke_tests::local_engine", "Runs local engine server smoke tests"
recipe "smoke_tests::local_loadbalancer", "Runs local load balancer server smoke tests"
recipe "smoke_tests::local_messaging", "Runs local messaging server smoke tests"
recipe "smoke_tests::local_search", "Runs local elasticsearch smoke tests"
recipe "smoke_tests::local_web", "Runs local web server smoke tests"

### attributes used from other cookbooks

attribute "core/server_type",
  :display_name => "server type",
  :description => "eg: db, app, web, cache",
  :required => "required",
  :recipes => [
    "smoke_tests::local_app", "smoke_tests::local_cache", "smoke_tests::local_db", "smoke_tests::local_engine",
    "smoke_tests::local_loadbalancer", "smoke_tests::local_messaging", "smoke_tests::local_web"
  ]

attribute "deploy/app_server",
  :display_name => "app server",
  :required => "required",
  :recipes => ["smoke_tests::global", "smoke_tests::local_app", "smoke_tests::local_engine", "smoke_tests::local_messaging", "smoke_tests::local_web"]

attribute "deploy/db_server",
  :display_name => "db server",
  :required => "required",
  :recipes => ["smoke_tests::global", "smoke_tests::local_app", "smoke_tests::local_messaging"]

attribute "deploy/cache_server",
  :display_name => "cache server",
  :required => "required",
  :recipes => ["smoke_tests::local_messaging"]

attribute "deploy/engine_server",
  :display_name => "engine server",
  :required => "required",
  :recipes => ["smoke_tests::global", "smoke_tests::local_messaging"]

attribute "deploy/messaging_server",
  :display_name => "messaging server",
  :required => "required",
  :recipes => ["smoke_tests::global", "smoke_tests::local_messaging"]

attribute "deploy/search_server",
  :display_name => "search_server",
  :required => "required",
  :recipes => ["smoke_tests::local_app", "smoke_tests::local_messaging"]

attribute "deploy/tenant",
  :display_name => "tenant",
  :required => "required",
  :recipes => ["smoke_tests::global"]

attribute "deploy/web_server",
  :display_name => "web server",
  :required => "required",
  :recipes => ["smoke_tests::local_messaging"]
