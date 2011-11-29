maintainer       "Isel Fernandez"
maintainer_email "isel_77@hotmail.com"
license          "our license"
description      "Deploys the UGF software to the environment"
long_description ""
version          "0.0.1"

supports "ubuntu"

recipe "deploy::build_scripts", "Deploys the build scripts"
recipe "deploy::elastic_search", "Deploys ElasticSearch"

attribute "deploy/revision",
  :display_name => "Revision",
  :description => "Revision to install",
  :required => "required",
  :recipes => ["deploy::build_scripts"]

attribute "deploy/access_key_id",
  :display_name => "AWS access key id",
  :required => "required",
  :recipes => ["deploy::build_scripts"]

attribute "deploy/secret_access_key",
  :display_name => "AWS secret access key",
  :required => "required",
  :recipes => ["deploy::build_scripts"]

