# replace the tokens in the properties file in place
require 'fileutils'
require 'yaml'

$DEBUG = true

local_filename = 'ultimate.properties'

node = {:deploy => {:cache_server => '10.81.19.190',
                    :admin_password => '_P@SSw0rd',
                    :db_server => '10.81.16.153',
                    :db_port => '27017',
                    :appserver => '10.81.19.116',
                    :app_server => '10.81.19.116',
                    :search_port => '9200',
                    :search_server => '10.81.23.107',
                    :messaging_server_port => '8081',
                    :messaging_server => '10.81.30.54',
                    :engine_server => '10.81.26.150',
                    :engine_port => '8888',
                    :web_server => '10.81.28.45',
}}

# NOTE - passing the string keyed hash instead of variable reference
# to allow name collision.
token_values = {'cache_server' => node[:deploy][:cache_server],
                'db_server' => node[:deploy][:db_server],
                'db_port' => node[:deploy][:db_port],
                'appserver' => node[:deploy][:app_server],
                'app_server' => node[:deploy][:app_server],
                'search_port' => node[:deploy][:elastic_search_port],
                'search_server' => node[:deploy][:search_server],
                'messaging_server_port' => node[:deploy][:messaging_server_port],
                #  new inputs
                'messaging_server' => node[:deploy][:messaging_server],
                'engine_server' => node[:deploy][:engine_server],
                'engine_port' => node[:deploy][:engine_port],
                'web_server' => node[:deploy][:web_server],
}

# validation pattern dictionary s constructed from the actual
# 'ultimate.properties'
# via command findstr "{" ultimate.properties
# The list needs to be kep up to date with that file

validation_patterns = %w(
dbserver.host={db_server}
dbserver.port={db_port}
server.engine.host={engine_server}
server.engine.port={engine_port}
app.host={app_server}
cache.host={cache_server}
messaging.host={messaging_server}
search.host={search_server}
webserver.host={web_server}
service.droolz.port={engine_port}
server.application.host={appserver}   )


def validate_properties(local_filename, token_values, validation_patterns)

  token_values.each do |token, entry|
    matcher = Regexp.new('(?<token>\{' + token + '\})', Regexp::MULTILINE)
    validation_patterns.each do |contents|
      if matcher.match(contents)
        # build the Regular expression negative lookahead pattern
        # to detect settings without expected values

        entry_miss = '(?!' + entry + ')'
        $stderr.puts "Will scan for #{matcher.named_captures[:token].to_s} with #{entry}" if $DEBUG
        contents.gsub!(matcher, entry_miss)

        # ( contents  )
      end
    end
  end
  $stderr.puts "Validation patterns:\n" + validation_patterns.to_yaml if $DEBUG

  # prune commented lines
  lines = []
  File.open(local_filename, 'r+') do |file|
    file.each do |line|
      lines << line unless line =~ /^#/
    end
  end

  contents = lines.join("\n")
  validation_patterns.each do |validation_expr|
    matcher = Regexp.new(validation_expr, Regexp::MULTILINE)
    if matcher.match(contents)
      $stderr.puts "Mismatch with #{validation_expr}" if $DEBUG
    end
  end
  return
end

validate_properties(local_filename, token_values, validation_patterns)