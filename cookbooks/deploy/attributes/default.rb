default[:ruby_scripts_dir] = '/RubyScripts'
default[:binaries_directory] = '/DeployScripts_Binaries'
default[:infrastructure_directory] = '/DeployScripts_Infrastructure'
default[:metadata_directory] = '/DeployScripts_Metadata'
default[:deployment_settings_json] = "#{default[:ruby_scripts_dir]}/deployment_settings.json"
default[:deployment_settings_xml] = "#{default[:ruby_scripts_dir]}/deployment_settings.xml"

default[:powershell_x32_dir] = '/Windows/system32/WindowsPowerShell/v1.0'
default[:powershell_x64_dir] = '/Windows/sysnative/WindowsPowerShell/v1.0'

