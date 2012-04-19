maintainer       "Cloud Infrastructure"
maintainer_email "ugf_ci@ultimatesoftware.com"
license          "our license"
description      "Configures TeamCity"
long_description ""
version          "0.0.1"

recipe "teamcity::set_fxcop_path", "Sets fxcop path in the build agent properties file"
recipe "teamcity::set_gallio_path", "Sets gallio path in the build agent properties file"
recipe "teamcity::set_ncover_path", "Sets ncover path in the build agent properties file"
recipe "teamcity::set_ruby_path", "Sets ruby path in the build agent properties file"

attribute "teamcity/gallio_path",
  :display_name => "gallio path",
  :required => "required",
  :recipes => ["teamcity::set_gallio_path"]
