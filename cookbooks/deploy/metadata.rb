maintainer       "Isel Fernandez"
maintainer_email "isel_77@hotmail.com"
license          "our license"
description      "Deploys the UGF software to the environment"
long_description ""
version          "0.0.1"

supports "ubuntu"

recipe "deploy::download_artifacts", "Downloads artifacts"
recipe "deploy::elastic_search", "Deploys ElasticSearch"
recipe "deploy::foundation_services", "Deploys the foundation rest services"
recipe "deploy::jspr", "Deploys the web server websites"
recipe "deploy::mongo", "Deploys mongodb"
recipe "deploy::provision", "Provisions basic system data"
recipe "deploy::reindex_elastic_search", "Reindexes ElasticSearch (should be going away)"
recipe "deploy::sarmus", "Deploys sarmus"
recipe "deploy::smoke_tests_global", "Runs global smoke tests"
recipe "deploy::smoke_tests_local", "Runs local smoke tests"
recipe "deploy::tag_data_version", "Writes a tag denoting what data version has been applied to this server"

attribute "deploy/app_server",
  :display_name => "app server",
  :required => "required",
  :recipes => ["deploy::jspr", "deploy::smoke_tests_local"]

attribute "deploy/artifacts",
  :display_name => "artifacts",
  :required => "required",
  :recipes => ["deploy::download_artifacts"]

attribute "deploy/aws_access_key_id",
  :display_name => "aws access key id",
  :required => "required",
  :recipes => ["deploy::download_artifacts"]

attribute "deploy/aws_secret_access_key",
  :display_name => "aws secret access key",
  :required => "required",
  :recipes => ["deploy::download_artifacts"]

attribute "deploy/cache_server",
  :display_name => "cache server",
  :required => "required",
  :recipes => ["deploy::foundation_services", "deploy::provision"]

attribute "deploy/db_server",
  :display_name => "db server",
  :required => "required",
  :recipes => ["deploy::foundation_services", "deploy::provision"]

attribute "deploy/deployment_name",
  :display_name => "deployment name",
  :required => "required",
  :recipes => ["deploy::smoke_tests_global"]

attribute "deploy/elastic_search_port",
  :display_name => "elastic search port",
  :required => "required",
  :recipes => ["deploy::foundation_services"]

attribute "deploy/elastic_search_version",
  :display_name => "elastic search version",
  :required => "required",
  :recipes => ["deploy::elastic_search"]

attribute "deploy/mongo_port",
  :display_name => "mongo port",
  :required => "required",
  :recipes => ["deploy::mongo"]

attribute "deploy/mongo_version",
  :display_name => "mongo version",
  :required => "required",
  :recipes => ["deploy::mongo"]

attribute "deploy/revision",
  :display_name => "revision",
  :required => "required",
  :recipes => ["deploy::sarmus", "deploy::download_artifacts", "deploy::tag_data_version"]

attribute "deploy/sarmus_port",
  :display_name => "sarmus port",
  :required => "required",
  :recipes => ["deploy::foundation_services", "deploy::provision"]

### attributes used from other cookbooks
attribute "core/server_type",
  :display_name => "server type",
  :description => "eg: db, app, web, cache",
  :required => "required",
  :recipes => ["deploy::smoke_tests_local"]



