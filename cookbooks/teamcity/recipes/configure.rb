# consolidated recipes and RightScripts to configure  build agent properties file
require 'yaml'
require 'fileutils'
ruby_scripts_dir = node[:ruby_scripts_dir]

rightscale_marker :begin

# NOTE: please follow the weird back slash repetinion pattern below

configurations = {

  'integration' => [
    {
      'description' => 'Set Agent Type',
      'key' => 'env.AgentType',
      'value' => node[:teamcity][:agent_type]
    },
    {
      'description' => 'Set gallio path',
      'key' => 'env.GallioPath',
      'value' => 'c\:\\\Program Files\\\Gallio\\\bin'
    },
    {
      'description' => 'Set ruby path',
      'key' => 'env.RubyPath',
      'value' => 'c\:\\\ruby192\\\bin\\\ruby.exe'
    },

    {
      'description' => 'Set ncover path',
      'key' => 'env.ncoverPath',
      'value' => 'C\:\\\Program Files\\\NCover'
    },
    {
      'description' => 'Set administrator user for mongo',
      'key' => 'env.db.user',
      'value' => node[:teamcity][:admin_user_mongo]
    },
    {
      'description' => 'Set administrator password for mongo',
      'key' => 'env.db.password',
      'value' => node[:teamcity][:admin_password_mongo]
    },
    {
      'description' => 'Set fxcop path',
      'key' => 'system.FxCopRoot',
      'value' => 'C\:\\\Program Files (x86)\\\Microsoft Visual Studio 10.0\\\Team Tools\\\Static Analysis Tools\\\FxCop',
    },
    {
      'description' => 'Set Web Server Url',
      'key' => 'serverUrl',
      'value' => 'http\://' + node[:teamcity][:web_server_ip]
    },
    {
      'description' => 'Set Agent Name',
      'key' => 'name',
      'value' => node[:teamcity][:agent_name]
    },
    {
      'description' => 'Set Instance Name',
      'key' => 'env.RightScale.Instance.Name',
      'value' => node[:teamcity][:instance_name]
    }
  ],

  'unit' => [
    {
      'description' => 'Set Agent Type',
      'key' => 'env.AgentType',
      'value' => node[:teamcity][:agent_type]
    },
    {
      'description' => 'Set gallio path',
      'key' => 'env.GallioPath',
      'value' => 'c\:\\\Program Files\\\Gallio\\\bin'
    },
    {
      'description' => 'Set ruby path',
      'key' => 'env.RubyPath',
      'value' => 'c\:\\\ruby192\\\bin\\\ruby.exe'
    },
    {
      'description' => 'Set ncover path',
      'key' => 'env.ncoverPath',
      'value' => 'C\:\\\Program Files\\\NCover'
    },
    {
      'description' => 'Set ndepend path',
      'key' => 'env.NDepend',
      'value' => 'c\:\\\NDepend\\\NDepend.Console.exe',
    },
    {
      'description' => 'Set administrator user for mongo',
      'key' => 'env.db.user',
      'value' => node[:teamcity][:admin_user_mongo]
    },
    {
      'description' => 'Set administrator password for mongo',
      'key' => 'env.db.password',
      'value' => node[:teamcity][:admin_password_mongo]
    },
    {
      'description' => 'Set fxcop path',
      'key' => 'system.FxCopRoot',
      'value' => 'C\:\\\Program Files (x86)\\\Microsoft Visual Studio 10.0\\\Team Tools\\\Static Analysis Tools\\\FxCop',
    },
    {
      'description' => 'Set Web Server Url',
      'key' => 'serverUrl',
      'value' => 'http\://' + node[:teamcity][:web_server_ip]
    },
    {
      'description' => 'Set Agent Name',
      'key' => 'name',
      'value' => node[:teamcity][:agent_name]
    },
    {
      'description' => 'Set Instance Name',
      'key' => 'env.RightScale.Instance.Name',
      'value' => node[:teamcity][:instance_name]
    }
  ],


  'ui' => [
    {
      'description' => 'Set Agent Type',
      'key' => 'env.AgentType',
      'value' => node[:teamcity][:agent_type]
    },
    {
      'description' => 'Set ruby path',
      'key' => 'env.RubyPath',
      'value' => 'c\:\\\ruby192\\\bin\\\ruby.exe'
    },
    {
      'description' => 'Configure locale',
      'key' => 'system.file.encoding',
      'value' => 'UTF-8'
    },
    {
      'description' => 'Set Web Server Url',
      'key' => 'serverUrl',
      'value' => 'http\://' + node[:teamcity][:web_server_ip]
    },
    {
      'description' => 'Set Agent Name',
      'key' => 'name',
      'value' => node[:teamcity][:agent_name]
    },
    {
      'description' => 'Set WEB IP',
      'key' => 'env.WebIP',
      'value' => node[:teamcity][:web_ip]
    },
    {
      'description' => 'Set Instance Name',
      'key' => 'env.RightScale.Instance.Name',
      'value' => node[:teamcity][:instance_name]
    }
  ]
}

agent_type = node[:teamcity][:agent_type]

template "#{ruby_scripts_dir}/update_configuration.rb" do
  source 'scripts/update_configuration.erb'
  variables(
    :token_values => configurations[agent_type].to_yaml.to_s,
    :source_file => node[:properties_file],
    :target_file => node[:properties_file]
  )
end

powershell "Setting properties for #{agent_type}" do
  source("ruby #{ruby_scripts_dir}/update_configuration.rb")
end

rightscale_marker :end