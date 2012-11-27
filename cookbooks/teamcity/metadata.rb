maintainer 'Cloud Infrastructure'
maintainer_email 'csf@ultimatesoftware.com'
license 'our license'
description 'Configures TeamCity'
long_description ''
version '0.0.1'

depends 'rightscale'
depends 'windows'

#agent
recipe 'teamcity::configure', 'Configures TeamCity build agent properties file'

#web server
recipe 'teamcity::web_configure', 'Configures the web server to use a database server'
recipe 'teamcity::web_backup_volumes', 'Backups up TeamCity web server'
recipe 'teamcity::web_schedule_backups', 'Schedules backups for the TeamCity web server'
recipe 'teamcity::web_setup_volumes', 'Sets up TeamCity web server volumes'

#database server
recipe 'teamcity::db_configure', 'Configures the database'

attribute 'core/aws_access_key_id',
  :display_name => 'aws access key id',
  :required => 'required',
  :recipes => ['teamcity::web_setup_volumes']

attribute 'core/aws_secret_access_key',
  :display_name => 'aws secret access key',
  :required => 'required',
  :recipes => ['teamcity::web_setup_volumes']

attribute 'deploy/admin_password_mongo',
  :display_name => 'administrator password for mongo',
  :required => 'required',
  :recipes => ['teamcity::configure']

attribute 'deploy/admin_user_mongo',
  :display_name => 'administrator user for mongo',
  :required => 'required',
  :recipes => ['teamcity::configure']

attribute 'mssql/sa_password',
  :display_name => 'sa password',
  :required => 'required',
  :recipes => ['teamcity::db_configure']

attribute 'windows/administrator_password',
  :display_name => 'administrator password',
  :required => 'required',
  :recipes => ['teamcity::web_schedule_backups']

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
  :recipes => ['teamcity::web_configure']

attribute 'teamcity/database_user',
  :display_name => 'database user',
  :required => 'required',
  :recipes => ['teamcity::web_configure', 'teamcity::db_configure']

attribute 'teamcity/database_password',
  :display_name => 'database password',
  :required => 'required',
  :recipes => ['teamcity::web_configure', 'teamcity::db_configure']

attribute 'teamcity/data_volume_size',
  :display_name => 'data volume size',
  :required => 'optional',
  :default => '300',
  :recipes => ['teamcity::web_setup_volumes']

attribute 'teamcity/force_create_volumes',
  :display_name => 'force create volumes',
  :required => 'optional',
  :default => 'False',
  :recipes => ['teamcity::web_setup_volumes']

attribute 'teamcity/lineage_name',
  :display_name => 'lineage name',
  :required => 'optional',
  :default => 'TeamCity Web',
  :recipes => ['teamcity::web_setup_volumes']

attribute 'teamcity/logs_volume_size',
  :display_name => 'logs volume size',
  :required => 'optional',
  :default => '300',
  :recipes => ['teamcity::web_setup_volumes']

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
