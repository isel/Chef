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
recipe "deploy::sarmus", "Deploys sarmus"
recipe "deploy::tag_data_version", "Writes a tag denoting what data version has been applied to this server"

attribute "deploy/app_server_host_name",
  :display_name => "app server host name",
  :required => "required",
  :recipes => ["deploy::jspr"]

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

attribute "deploy/elastic_search_port",
  :display_name => "elastic search port",
  :required => "required",
  :recipes => ["deploy::foundation_services"]

attribute "deploy/elastic_search_version",
  :display_name => "elastic search version",
  :required => "required",
  :recipes => ["deploy::elastic_search"]

attribute "deploy/instance_id",
  :display_name => "aws instance id",
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


