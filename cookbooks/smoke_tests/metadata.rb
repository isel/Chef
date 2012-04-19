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
recipe "smoke_tests::local_messaging", "Runs local messaging server smoke tests"
recipe "smoke_tests::local_web", "Runs local web server smoke tests"

attribute "smoke_tests/engine_server",
  :display_name => "engine server",
  :required => "required",
  :recipes => ["smoke_tests::global"]

### attributes used from other cookbooks
attribute "core/server_type",
  :display_name => "server type",
  :description => "eg: db, app, web, cache",
  :required => "required",
  :recipes => ["smoke_tests::local_app", "smoke_tests::local_cache", "smoke_tests::local_db", "smoke_tests::local_web" "smoke_tests::local_messaging"]

attribute "deploy/activemq_port",
  :display_name => "activemq port",
  :required => "optional",
  :default => "61616",
  :recipes => ["smoke_tests::local_messaging"]

attribute "deploy/app_server",
  :display_name => "app server",
  :required => "required",
  :recipes => ["smoke_tests::global", "smoke_tests::local_app","smoke_tests::local_engine", "smoke_tests::local_web"]

attribute "deploy/db_port",
  :display_name => "db port",
  :required => "optional",
  :default => "27017",
  :recipes => ["smoke_tests::global", "smoke_tests::local_app"]

attribute "deploy/db_server",
  :display_name => "db server",
  :required => "required",
  :recipes => ["smoke_tests::global", "smoke_tests::local_app"]

attribute "deploy/elastic_search_port",
  :display_name => "elastic search port",
  :required => "optional",
  :default => "9200",
  :recipes => ["smoke_tests::local_app"]

attribute "deploy/mule_port",
  :display_name => "mule port",
  :required => "optional",
  :default => "8585",
  :recipes => ["smoke_tests::local_messaging"]

attribute "deploy/tenant",
  :display_name => "tenant",
  :required => "required",
  :recipes => ["smoke_tests::global"]



