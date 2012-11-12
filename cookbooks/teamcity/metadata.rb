maintainer 'Cloud Infrastructure'
maintainer_email 'ugf_ci@ultimatesoftware.com'
license 'our license'
description 'Configures TeamCity'
long_description ''
version '0.0.1'

depends 'rightscale'

recipe 'teamcity::configure', 'Configures TeamCity build agent properties file'

attribute 'teamcity/admin_password_mongo',
  :display_name => 'administrator password for mongo',
  :required => 'required',
  :recipes => ['teamcity::configure', 'teamcity::set_admin_password_mongo']

attribute 'teamcity/admin_user_mongo',
  :display_name => 'administrator user for mongo',
  :required => 'required',
  :recipes => ['teamcity::configure', 'teamcity::set_admin_user_mongo']

attribute 'teamcity/agent_name',
  :display_name => 'build agent name',
  :required => 'required',
  :recipes => ['teamcity::configure']

attribute 'teamcity/agent_type',
  :display_name => 'agent type',
  :required => 'required',
  :recipes => ['teamcity::configure']

attribute 'teamcity/instance_name',
  :display_name => 'instance name',
  :required => 'required',
  :recipes => ['teamcity::configure']

attribute 'teamcity/web_ip',
  :display_name => 'web ip',
  :required => 'optional',
  :default => '',
  :recipes => ['teamcity::configure']

attribute 'teamcity/web_server_ip',
  :display_name => 'teamcity server ip',
  :required => 'required',
  :recipes => ['teamcity::configure']
