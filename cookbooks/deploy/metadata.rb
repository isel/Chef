maintainer       "Isel Fernandez"
maintainer_email "isel_77@hotmail.com"
license          "our license"
description      "Deploys the UGF software to the environment"
long_description ""
version          "0.0.1"

supports "ubuntu"

recipe "deploy::download_artifacts", "Downloads artifacts"
recipe "deploy::elastic_search", "Deploys ElasticSearch"
recipe "deploy::jspr", "Deploys the web server websites"
recipe "deploy::mongo", "Deploys mongodb"
recipe "deploy::sarmus", "Deploys sarmus"

attribute "deploy/revision",
  :display_name => "revision",
  :required => "required",
  :recipes => ["deploy::sarmus", "deploy::download_artifacts"]

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

attribute "deploy/mongo_port",
  :display_name => "mongo port",
  :required => "required",
  :recipes => ["deploy::mongo"]

attribute "deploy/mongo_version",
  :display_name => "mongo version",
  :required => "required",
  :recipes => ["deploy::mongo"]

attribute "deploy/elastic_search_version",
  :display_name => "elastic search version",
  :required => "required",
  :recipes => ["deploy::elastic_search"]

attribute "deploy/app_server_host_name",
  :display_name => "app server host name",
  :required => "required",
  :recipes => ["deploy::jspr"]


