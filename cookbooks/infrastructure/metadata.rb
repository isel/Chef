maintainer       "Cloud Infrastructure"
maintainer_email "csf@ultimatesoftware.com"
license          "our license"
description      "Deploys the UGF software to the environment"
long_description ""
version          "0.0.1"

supports "ubuntu"

depends "rightscale"
depends "logging"

recipe "infrastructure::api", "Deploys Infrastructure api services"
recipe "infrastructure::smoke_tests", "Smoke tests"

