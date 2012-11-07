# consolidated recipes from teamcity cookbook
require 'yaml'

configurations = {


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
staging_properties_file = File.join(ENV['TEMP'], File.basename(node[:properties_file]) + Random.rand(100-999).to_s)

FileUtils.copy_file(node[:properties_file]), staging_properties_file)


# keyed by agent_type
=begin
TC_AGENT_TYPE => text:env.AgentType=integration (from ServerTemplate)
=end

tc_agent_type = node[:teamcity][:tc_agent_type]

# strip legacy prefix
tc_agent_type.gsub('env.AgentType=', '')

configuration = configurations[tc_agent_type]

configuration.each do |settings|
  puts settings['description']
  powershell 'update properties' do
    parameters ({
      'properties_file' => staging_properties_file,
      'key' => settings['key'],
      'value' => settings['value']
    })
    source(node[:set_value_in_properties_file_powershell_script])
  end

# copy updated configuration over

  FileUtils.copy_file(staging_properties_file, node[:properties_file]))
