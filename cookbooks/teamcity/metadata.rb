maintainer 'Cloud Infrastructure'
maintainer_email 'csf@ultimatesoftware.com'
license 'our license'
description 'Configures TeamCity'
long_description ''
version '0.0.1'

depends 'rightscale'
depends 'windows'

recipe 'teamcity::configure', 'Configures TeamCity build agent properties file'
recipe 'teamcity::backup_volumes', 'Backups up TeamCity web server'
recipe 'teamcity::schedule_backups', 'Schedules backups for the TeamCity web server'
recipe 'teamcity::setup_database_server', 'Configures the web server to use a database server'
recipe 'teamcity::setup_volumes', 'Sets up TeamCity web server volumes'

attribute 'core/aws_access_key_id',
  :display_name => 'aws access key id',
  :required => 'required',
  :recipes => ['teamcity::setup_volumes']

attribute 'core/aws_secret_access_key',
  :display_name => 'aws secret access key',
  :required => 'required',
  :recipes => ['teamcity::setup_volumes']

attribute 'deploy/admin_password_mongo',
  :display_name => 'administrator password for mongo',
  :required => 'required',
  :recipes => ['teamcity::configure']

attribute 'deploy/admin_user_mongo',
  :display_name => 'administrator user for mongo',
  :required => 'required',
  :recipes => ['teamcity::configure']

attribute 'windows/administrator_password',
  :display_name => 'administrator password',
  :required => 'required',
  :recipes => ['teamcity::schedule_backups']

attribute 'teamcity/agent_name',
  :display_name => 'build agent name',
  :required => 'required',
  :recipes => ['teamcity::configure']

attribute 'teamcity/agent_type',
  :display_name => 'agent type',
  :required => 'required',
  :recipes => ['teamcity::configure']

attribute 'teamcity/database_server',
  :display_name => 'database server',
  :required => 'required',
  :recipes => ['teamcity::setup_database_server']

attribute 'teamcity/database_user',
  :display_name => 'database user',
  :required => 'required',
  :recipes => ['teamcity::setup_database_server']

attribute 'teamcity/database_password',
  :display_name => 'database password',
  :required => 'required',
  :recipes => ['teamcity::setup_database_server']

attribute 'teamcity/data_volume_size',
  :display_name => 'data volume size',
  :required => 'optional',
  :default => '300',
  :recipes => ['teamcity::setup_volumes']

attribute 'teamcity/force_create_volumes',
  :display_name => 'force create volumes',
  :required => 'optional',
  :default => 'False',
  :recipes => ['teamcity::setup_volumes']

attribute 'teamcity/lineage_name',
  :display_name => 'lineage name',
  :required => 'optional',
  :default => 'TeamCity Web',
  :recipes => ['teamcity::setup_volumes']

attribute 'teamcity/logs_volume_size',
  :display_name => 'logs volume size',
  :required => 'optional',
  :default => '300',
  :recipes => ['teamcity::setup_volumes']

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
