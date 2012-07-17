require 'yaml'
# replace the tokens in the properties file in place

$DEBUG = true
local_filename = 'ultimate.properties'
  # our replacement tokens are currently plain, but escape special characters to prevent Regexp from bombing, replace special characters.
  special_chars = %r{
      ([\[$@\\\]])
      }x


def update_properties(local_filename,token_values)
  $stderr.puts token_values.to_yaml if $DEBUG
  f = File.open(local_filename, 'r+'); contents = f.read; f.close
  token_values.each do |token, entry|
    # capture_token = token.gsub(special_chars) { '\\' + $1 }
    $stderr.puts "Probing #{token}" if $DEBUG
    matcher = Regexp.new('(?<token>\{' + token + '\})', Regexp::MULTILINE)
    $stderr.puts matcher.source if $DEBUG
    if matcher.match(contents)
      $stderr.puts "Will replace #{matcher.named_captures[:token].to_s} with #{entry}" if $DEBUG
      contents=contents.gsub(matcher, entry)
      # multiline ?
    end
  end
  File.open(local_filename, 'r+') { |f| f.puts contents }
end


def validate_properties(local_filename,token_values, validation_patterns)
  $stderr.puts token_values.to_yaml
  token_values.each do |token, entry|
    # capture_token = token.gsub(special_chars) { '\\' + $1 }
    $stderr.puts "Probing #{token}" if $DEBUG
    matcher = Regexp.new('(?<token>\{' + token + '\})', Regexp::MULTILINE)
    $stderr.puts matcher.source if $DEBUG
    validation_patterns.each do |contents|
      if matcher.match(contents)
        # use Regular expression negative lookahead grouping syntax
        # to detect the known settings with other then expected values

        entry_miss = '(?!' + entry + ')'
        $stderr.puts "Will replace #{matcher.named_captures[:token].to_s} with #{entry}" if $DEBUG
        #  contents += entry + "\n"
        contents.gsub!(matcher, entry_miss)

        # ( contents  )
      end
    end
  end
  $stderr.puts "Expected contents:\n" + validation_patterns.to_yaml  if $DEBUG


  # not about to write the file contents thus
  # throwing away commented lines would not hurt.
  lines = []
  File.open(local_filename, 'r+') do |file|
    file.each do |line|
      lines << line unless line =~ /^#/
    end
  end
  # need to rinse comment line before it is late!
  contents = lines.join("\n")
  validation_patterns.each do |validation_expr|
    matcher = Regexp.new(validation_expr, Regexp::MULTILINE)
    if matcher.match(contents)
      $stderr.puts "Mismatch with #{validation_expr}" if $DEBUG
    end
  end
  return
end

# spec testing
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
                'xxxxxxxxx' => node[:deploy][:admin_password],
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
update_properties( local_filename,
    token_values
)


# spec testing
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
token_values = {'cache_server' => node[:deploy][:cache_server],
                'xxxxxxxxx' => node[:deploy][:admin_password],
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

# the dictionary of validation patterns has been collected
# from the real life properties file and need matching update
# when the file evolves

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

validate_properties(local_filename,token_values, validation_patterns)