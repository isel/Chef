# replace the tokens in the properties file in place
require 'fileutils'
require 'yaml'

$DEBUG = false

local_filename = $DEBUG ? 'ultimate.properties' :
    '/opt/mule/configuration/ultimate.properties'

backup_filename = "#{local_filename}.BAK"
if $DEBUG

  node = {:deploy => {:cache_server => '10.81.19.190',
                      :admin_password => '_P@SSw0rd',
                      :db_server => '10.81.16.153',
                      :db_port => '27017',
                      :app_server => '10.81.19.116',
                      :search_port => '9200',
                      :search_server => '10.81.23.107',
                      :messaging_server_port => '8081',
                      :messaging_server => '10.81.30.54',
                      :engine_server => '10.81.26.150',
                      :engine_port => '8080',
                      :web_server => '10.81.28.45',
  }}

end

# NOTE - passing the string keyed hash instead of variable reference
# to allow name collision.
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
    matcher = Regexp.new('(?<token>\{' + token + '\})', Regexp::MULTILINE)
    while matcher.match(contents) # multiline ?
      $stderr.puts "Will replace #{matcher.source} #{matcher.named_captures[:token].to_s} with #{entry}" if $DEBUG
      contents=contents.gsub(matcher, entry)
    end
  end
  File.open(local_filename, 'r+') { |f| f.puts contents }
end

FileUtils.cp(local_filename, backup_filename) if !File.exists?(backup_filename)
update_properties(local_filename, token_values)
