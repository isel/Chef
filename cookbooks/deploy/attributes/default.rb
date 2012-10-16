default['ruby_scripts_dir'] = '/RubyScripts'
default['binaries_directory'] = '/DeployScripts_Binaries'
default['infrastructure_directory'] = '/DeployScripts_Infrastructure'
default[:pims_directory] = '/DeployScripts_PIMs'
default[:deployment_settings_json] = "#{default['ruby_scripts_dir']}/deployment_settings.json"
default[:deployment_settings_xml] = "#{default['ruby_scripts_dir']}/deployment_settings.xml"

default[:powershell_x32_dir] = '/Windows/system32/WindowsPowerShell/v1.0'
default[:powershell_x64_dir] = '/Windows/sysnative/WindowsPowerShell/v1.0'

default[:activemq_version] = '5.6.0'
default[:mule_plugins] = ['mmc-agent-mule3-app-3.3.0', 'mmc-distribution-console-app-3.3.0']
default[:mule_version] = '3.3.0'
default[:search_plugins] = 'bigdesk,elasticsearch-head,analysis-phonetic,analysis-icu'
default[:search_version] = '0.19.3'
default[:ulimit_files] = '8192'