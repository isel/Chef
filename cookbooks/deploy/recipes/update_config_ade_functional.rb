require 'fileutils'
require_relative "#{node['binaries_directory']}/CI/BuildScripts/Helpers/configuration"
require_relative "#{node['binaries_directory']}/CI/BuildScripts/Helpers/io_utils"
require_relative "#{node['binaries_directory']}/CI/BuildScripts/Deployment/user_acceptance"

@environment = Deployment::UserAcceptance.new(ENV['deployment.name'], ENV['api.infrastructure.url'])
@environment.type = ENV['deployment.type']
@settings = @environment.settings
@checkout_directory = ENV['teamcity.build.checkoutDir'].gsub(/\\/, '/')

configs = FileList["#{@checkout_directory}/bin/Shabti.ConsoleApp.exe.config"]

Helpers::change_all_app_settings(configs, 'AlchemistRepository', "#{@checkout_directory}/Tests/AdeTests/Alexandria/Alchemist/FileRepository")
Helpers::change_all_app_settings(configs, 'TestRepository', "#{@checkout_directory}/Tests/AdeTests/Alexandria/TestData/Default")
Helpers::change_all_app_settings(configs, 'ModelBindings', "#{@checkout_directory}/Tests/AdeTests/Alexandria/Bindings")
Helpers::change_all_app_settings(configs, 'AlexandriaLocation', "#{@checkout_directory}/Tests/AdeTests/Alexandria")
Helpers::change_all_app_settings(configs, 'AdeProjectDirectory', "#{@checkout_directory}/Apps/ADE")
Helpers::change_all_app_settings(configs, 'AdePluginsDirectory', "#{@checkout_directory}/Apps/ADE/plugins")
Helpers::change_all_app_settings(configs, 'AdeLibraryDirectory', "#{@checkout_directory}/Apps/ADE/release/lib")
Helpers::change_all_app_settings(configs, 'BootstrapDirectory', "#{@checkout_directory}/Tests/AdeTests/Alexandria/Bootstrap")
Helpers::change_all_app_settings(configs, 'ResultsDirectory', "#{@checkout_directory}/TestResults")

Helpers::change_all_app_settings(configs, 'AppServer', @settings['app_server'])
Helpers::change_all_app_settings(configs, 'ConnectionString', "Server=#{@settings['database_server']}:#{@settings['database_port']};username=#{node[:deploy][:admin_user_mongo]}(admin);password=#{node[:deploy][:admin_password_mongo]}")