default['ruby_scripts_dir'] = '/RubyScripts'
default['binaries_directory'] = '/DeployScripts_Binaries'
default['ruby187'] = '/opt/rightscale/sandbox/bin/ruby'

default[:app_listener_names] = 'api80,api81,api82'
default[:app_server_ports] = '80,81,82'
default[:health_check_uri] = '/HealthCheck.html'
default[:maintenance_page] = '/system/maintenance.html'
default[:max_connections_per_lb] = 255
default[:server_timeout] = 300000
default[:session_stickiness] = 'false'
default[:web_server_port] = '80'