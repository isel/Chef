maintainer       "Isel Fernandez"
maintainer_email "isel_77@hotmail.com"
license          "our license"
description      "Deploys the UGF software to the environment"
long_description ""
version          "0.0.1"

supports "ubuntu"

recipe "deploy::elastic_search", "Deploys ElasticSearch"
recipe "deploy::mongo", "Deploys mongodb"
recipe "deploy::sarmus", "Deploys sarmus"

attribute "deploy/revision",
  :display_name => "Revision",
  :required => "required",
  :recipes => ["deploy::sarmus"]

attribute "deploy/mongo_port",
  :display_name => "Mongo Port",
  :required => "required",
  :recipes => ["deploy::mongo"]

attribute "deploy/mongo_version",
  :display_name => "Mongo Version",
  :required => "required",
  :recipes => ["deploy::mongo"]

attribute "deploy/elastic_search_version",
  :display_name => "Elastic Search Version",
  :required => "required",
  :recipes => ["deploy::elastic_search"]


