require 'fileutils'
require "#{node['binaries_directory']}/CI/BuildScripts/Helpers/configuration"
require "#{node['binaries_directory']}/CI/BuildScripts/Helpers/io_utils"
require "#{node['binaries_directory']}/CI/BuildScripts/Deployment/user_acceptance"

@environment = Deployment::UserAcceptance.new('RonAuth', 'http://10.81.10.189')
@environment.type = 'user'
@settings = @environment.settings
@checkout_directory = 'C:/RonTesting'

configs = FileList["#{@checkout_directory}/**/*.config"]
puts "found #{configs.count} config files"

Helpers::change_all_app_settings(configs, 'ConnectionString', "Server=#{@settings['database_server']}:#{@settings['database_port']};username=#{node[:deploy][:admin_user_mongo]}(admin);password=#{node[:deploy][:admin_password_mongo]}")
Helpers::change_all_app_settings(configs, 'SearchUri', "http://#{@settings['search_server']}:#{@settings['search_port']}/_search")
Helpers::change_all_app_settings(configs, 'ImageServerAddress', "http://#{@settings['database_server']}/Images/")
Helpers::change_all_app_settings(configs, 'AppServer', @settings['app_server'])
Helpers::change_all_app_settings(configs, 'EngineServer', "#{@settings['engine_server']}:#{@settings['engine_port']}")
Helpers::change_all_app_settings(configs, 'MessagingServer.Uri', "http://#{@settings['messaging_server']}:#{@settings['messaging_port']}")

IOUtils::replace_text_in_files(configs, '<host name="localhost"', "<host name=\"#{@settings['cache_server']}\"")
IOUtils::replace_text_in_files(configs, '<\/hosts>', '</hosts><securityProperties mode="None" protectionLevel="None"/>')

cache_server = @environment.servers.find { |s| s['server']['name'] == 'Cache Server' }
host_name_entry = "#{@settings['cache_server']} #{cache_server['server']['tags']['server:hostname']}"

File.open('C:/Windows/System32/drivers/etc/hosts', 'w') { |file| file.puts host_name_entry }