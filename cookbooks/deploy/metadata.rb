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
  :description => "Revision to install",
  :required => "required",
  :recipes => ["deploy::sarmus"]


