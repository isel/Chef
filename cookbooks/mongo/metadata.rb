maintainer       "Cloud Infrastructure"
maintainer_email "csf@ultimatesoftware.com"
license          "our license"
description      "Installs mongo"
long_description ""
version          "0.0.1"

supports "ubuntu"
supports "windows"

depends 'core'
depends "rightscale"

recipe "mongo::default", "Downloads and installs the mongo"
recipe "mongo::configure" , "Configures mongodb"

attribute "core/aws_access_key_id",
  :display_name => "aws access key id",
  :required => "required",
  :recipes => ["mongo::default"]

attribute "core/aws_secret_access_key",
  :display_name => "aws secret access key",
  :required => "required",
  :recipes => ["mongo::default"]

attribute "core/s3_bucket",
  :display_name => "s3 bucket for the UGF platform",
  :description => "i.e. ugfartifacts, ugfproduction",
  :required => "optional",
  :default  => "ugfgate1",
  :recipes => ["mongo::default"]

attribute "deploy/admin_password_mongo",
  :display_name => "admin password for mongo",
  :required => "required",
  :recipes  => ["mongo::configure"]

attribute "deploy/admin_user_mongo",
  :display_name => "admin user for mongo",
  :required => "required",
  :recipes  => ["mongo::configure"]

attribute "deploy/db_replica_set_name",
  :display_name => "db replica set name",
  :required => "required",
  :recipes => ["mongo::configure", "mongo::default"]

attribute "deploy/mongo_version",
  :display_name => "mongo version",
  :required => "optional",
  :default => "2.0.1",
  :recipes => ["mongo::default"]

