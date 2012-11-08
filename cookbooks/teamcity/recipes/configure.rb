# consolidated recipes from teamcity cookbook
require 'yaml'

configurations = {

# note weird number of back slashes.
  'integration' => [
    {
      'description' => 'Set ncover path',
      'key' => 'env.ncoverPath',
      'value' => 'C:/Program Files/NCover'
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
      'value' => 'C:/Program Files (x86)/Microsoft Visual Studio 10.0/Team Tools\\\Static Analysis Tools\\\FxCop',
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
      'value' => 'c:/ruby192/bin/ruby.exe',
    }

  ],
  'ui' => [
    # TBD
  ]
}
# copy properties file elsewhere
# update
staging_properties_file = File.join(ENV['TEMP'], File.basename(node[:properties_file]) + '.' + rand(100-999).to_s).gsub(/\\/, '/')

log "Copying vanilla #{node[:properties_file]} to #{staging_properties_file}."

FileUtils.copy_file(node[:properties_file], staging_properties_file)


ruby_scripts_dir = node[:ruby_scripts_dir]

tc_agent_type = node[:teamcity][:tc_agent_type]

# strip legacy prefix
tc_agent_type = tc_agent_type.gsub('env.AgentType=', '')
log "Setting properties for current TC_AGENT_TYPE: #{tc_agent_type}"
configuration = configurations[tc_agent_type]


template "#{ruby_scripts_dir}/update_configuration.rb" do
  source 'scripts/update_configuration.erb'
  variables(
    :token_values => configuration.to_yaml.to_s,
    :source_file => staging_properties_file,
   :target_file =>  staging_properties_file
  )
end
powershell 'Configuring mongo' do
  source("ruby #{ruby_scripts_dir}/update_configuration.rb")
end

# copy updated configuration over
log "Copying final #{staging_properties_file} to #{node[:properties_file]}"
FileUtils.copy_file(staging_properties_file, node[:properties_file])
