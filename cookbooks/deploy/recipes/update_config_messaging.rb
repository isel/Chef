require 'fileutils'
require "#{node['binaries_directory']}/CI/BuildScripts/Helpers/configuration"
require "#{node['binaries_directory']}/CI/BuildScripts/Helpers/io_utils"
require "#{node['binaries_directory']}/CI/BuildScripts/Deployment/user_acceptance"

@environment = Deployment::UserAcceptance.new(ENV['deployment.name'], ENV['api.infrastructure.url'])
@environment.type = ENV['deployment.type']
@settings = @environment.settings
@checkout_directory = ENV['teamcity.build.checkoutDir'].gsub(/\\/, '/')

properties_filename = "#{@checkout_directory}/events/configuration/DIY/ultimate.properties"

token_values = {
    'app_server' => "#{@settings['app_server']}",
    'cache_server' => "#{@settings['cache_server']}",
    'db_password' => "#{node[:deploy][:admin_password_mongo]}",
    'db_port' => "#{@settings['database_port']}",
    'db_server' => "#{@settings['database_server']}",
    'db_user' => "#{node[:deploy][:admin_user_mongo]}",
    'engine_port' => "#{@settings['engine_port']}",
    'engine_server' => "#{@settings['engine_server']}",
    'messaging_port' => "#{@settings['messaging_port']}",
    'messaging_server' => "#{@settings['messaging_server']}",
    'search_port' => "#{@settings['search_port']}",
    'search_server' => "#{@settings['search_server']}",
    'web_server' => "#{@settings['web_server']}"
}

Helpers::update_properties(properties_filename, properties_filename, token_values)