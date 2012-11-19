maintainer       "Cloud Infrastructure"
maintainer_email "csf@ultimatesoftware.com"
license          "our license"
description      "Installs basic tools to manage any instance"
long_description ""
version          "0.0.1"

supports "windows"

depends 'rightscale'
depends 'core'

recipe "access_database_engine::default", "Downloads and installs the access database engine"

attribute "core/aws_access_key_id",
  :display_name => "aws access key id",
  :required => "required",
  :recipes => ["access_database_engine::default"]

attribute "core/aws_secret_access_key",
  :display_name => "aws secret access key",
  :required => "required",
  :recipes => ["access_database_engine::default"]

attribute "core/s3_bucket",
  :display_name => "s3 bucket for the UGF platform",
  :description => "i.e. ugfartifacts, ugfproduction",
  :required => "optional",
  :default  => "ugfgate1",
  :recipes => ["access_database_engine::default"]
