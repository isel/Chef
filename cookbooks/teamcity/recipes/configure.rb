# consolidated recipes from teamcity cookbook
require 'yaml'

configurations = {

# note weird number of back slashes.
  'integration' => [
    {
      'description' => 'Set ncover path',
      'key' => 'env.ncoverPath',
      'value' => 'C\:\\\Program Files\\\NCover'
    },
    {
      'description' => 'Set administrator password for mongo',
      'key' => 'env.AdminPasswordMongo',
      'value' => node[:teamcity][:admin_password_mongo]
    },
    {
      'description' => 'Set administrator user for mongo',
      'key' => 'env.AdminUserMongo',
      'value' => node[:teamcity][:admin_user_mongo]
    },
    {
      'description' => 'Set fxcop path',
      'key' => 'system.FxCopRoot',
      'value' => 'C\:\\Program Files (x86)\\\Microsoft Visual Studio 10.0\\\Team Tools\\\Static Analysis Tools\\\FxCop',
    },
    { 'description' => 'Set gallio path',
      'key' => 'env.GallioPath',
      'value' => node[:teamcity][:gallio_path],
    },
    {
      'description' => 'Configure locale',
      'key' => 'system.file.encoding',
      'value' => 'UTF-8'
    },
    {
      'description' => 'Set ruby path',
      'key' => 'env.RubyPath',
      'value' => 'c:\\\ruby192\\\bin\\\ruby.exe',
    }

  ],
  'ui' => [
    # TBD
  ]
}
# copy properties file elsewhere
# update
staging_properties_file = File.join(ENV['TEMP'], File.basename(node[:properties_file]) + '.' + rand(100-999).to_s).gsub(/\\/,'/')

log "Copying vanilla #{node[:properties_file]} to #{staging_properties_file}."

FileUtils.copy_file(node[:properties_file], staging_properties_file)



tc_agent_type = node[:teamcity][:tc_agent_type]

# strip legacy prefix
tc_agent_type = tc_agent_type.gsub('env.AgentType=', '')
log "Setting properties for current TC_AGENT_TYPE: #{tc_agent_type}"
configuration = configurations[tc_agent_type]

configuration.each do |settings|
  Log "Updating #{settings['description']}" + "\n" + settings.to_yaml.to_s


  powershell 'update properties : '+ staging_properties_file do
    parameters ({
      'properties_file' => staging_properties_file,
      'key' => settings['key'],
      'value' => settings['value']
    })
    powershell_script = node[:set_value_in_properties_file_powershell_script]
    source(powershell_script)
    sleep 10
  end
# copy updated configuration over
end
log "Copying final #{staging_properties_file} to #{node[:properties_file]}"
FileUtils.copy_file(staging_properties_file, node[:properties_file])
