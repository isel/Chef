maintainer       "Cloud Infrastructure"
maintainer_email "ugf_ci@ultimatesoftware.com"
license          "our license"
description      "Installs ADE plugins"
long_description ""
version          "0.0.1"

supports "windows"

depends 'core'

recipe "ade_plugins::default", "Downloads and installs the ADE plugins"

attribute "core/aws_access_key_id",
  :display_name => "aws access key id",
  :required => "required",
  :recipes => ["ade_plugins::default"]

attribute "core/aws_secret_access_key",
  :display_name => "aws secret access key",
  :required => "required",
  :recipes => ["ade_plugins::default"]

attribute "core/s3_bucket",
  :display_name => "s3 bucket for the UGF platform",
  :description => "i.e. ugfgate1, ugfgate2",
  :required => "optional",
  :default  => "ugfgate1",
  :recipes => ["ade_plugins::default"]

attribute "core/s3_repository",
  :display_name => "s3 repository for the UGF platform",
  :required => "optional",
  :default => "GlobalIncite",
  :recipes => ["ade_plugins::default"]


attribute "deploy/s3_repository",
  :display_name => "s3 repository for the UGF platform",
  :required => "optional",
  :default => "GlobalIncite",
  :recipes => ["ade_plugins::default"]

attribute "ade_plugins/plugins_artifacts",
  :display_name => "plugins artifacts",
  :required => "required",
  :recipes => ["ade_plugins::default"]

attribute "ade_plugins/plugins_revision",
  :display_name => "plugins revision",
  :required => "required",
  :recipes => ["ade_plugins::default"]

