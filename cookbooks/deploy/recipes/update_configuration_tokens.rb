# replace tokens in mule properties file

require 'fileutils'
require 'yaml'

$DEBUG = false

mule_configuration_dir='/opt/mule/configuration'
properties_filename = '/opt/mule/configuration/ultimate.properties'
properties_backup_filename = "#{properties_filename}.BAK"


# using tokens instead of variable reference in the hash
# to allow for name collision.

token_values = {
    'db_server' => node[:deploy][:db_server],
    'db_port' => node[:deploy][:db_port],
    'appserver' => node[:deploy][:app_server],
    'app_server' => node[:deploy][:app_server],
    'search_port' => node[:deploy][:elastic_search_port],
    'search_server' => node[:deploy][:search_server],
    'messaging_server_port' => node[:deploy][:messaging_server_port],
    'engine_server' => node[:deploy][:engine_server],
    'cache_server' => node[:deploy][:cache_server],
    'messaging_server' => node[:deploy][:messaging_server],
    'engine_port' => node[:deploy][:engine_port],
    'web_server' => node[:deploy][:web_server],
}


def update_properties(local_filename, token_values)
  f = File.open(local_filename, 'r+'); contents = f.read; f.close
  token_values.each do |token, entry|
    matcher = Regexp.new('(\{' + token + '\})', Regexp::MULTILINE)
    while matcher.match(contents) # multiline ?
      $stderr.puts "Will replace #{matcher.source} with #{entry}" if $DEBUG
      contents=contents.gsub(matcher, entry)
    end
  end
  File.open(local_filename, 'r+') { |f| f.puts contents }
end

# replace tokens in mule properties file
if File.exists?(mule_configuration_dir)

  if !File.exists?(properties_backup_filename)
    FileUtils.cp(properties_filename, properties_backup_filename)
    log "properties file backed up"
  end
  update_properties(properties_filename, token_values)
  log "Properties updated"
end
