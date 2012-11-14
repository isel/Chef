maintainer       "Cloud Infrastructure"
maintainer_email "ugf_ci@ultimatesoftware.com"
license          "our license"
description      "Installs rsyslog to windows"
long_description ""
version          "0.0.1"

supports 'windows'

depends 'rightscale'
depends 'core'

recipe "rsyslog::default", "Downloads and installs rsyslog on windows"
recipe "rsyslog::configure", "Configures rsyslog on windows"

attribute "core/aws_access_key_id",
  :display_name => "aws access key id",
  :required => "required",
  :recipes => ["rsyslog::default"]

attribute "core/aws_secret_access_key",
  :display_name => "aws secret access key",
  :required => "required",
  :recipes => ["rsyslog::default"]

attribute "core/s3_bucket",
  :display_name => "s3 bucket for the UGF platform",
  :description => "i.e. ugfartifacts, ugfproduction",
  :required => "optional",
  :default  => "ugfgate1",
  :recipes => ["rsyslog::default"]

attribute "logging/remote_server",
  :display_name => "remote log server",
  :required => "required",
  :recipes => ["rsyslog::configure"]
