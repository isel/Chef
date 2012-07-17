ruby_scripts_dir = node['ruby_scripts_dir']


$DEBUG = false
local_filename =  '/opt/mule/configuration/ultimate.properties'

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
server.application.host={app_server}   )


def validate_properties(local_filename, token_values, validation_patterns)

  token_values.each do |token, entry|
    matcher = Regexp.new('(?<token>\{' + token + '\})', Regexp::MULTILINE)
    validation_patterns.each do |contents|
      if matcher.match(contents)
        # build the Regular expression negative lookahead pattern
        # to detect settings without or with wrong values
        entry_miss = '(?!' + entry + ')'
        # $stderr.puts "Will scan for #{matcher.named_captures[:token].to_s} with #{entry}" if $DEBUG
        contents.gsub!(matcher, entry_miss)
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
      $stderr.puts "ERROR: Mismatch with #{validation_expr}"
    end
  end
  return
end


template "#{ruby_scripts_dir}/local_messaging.rb" do
  source 'scripts/local_messaging.erb'
  variables(
    :mule_port => node[:deploy][:mule_port],
    :activemq_port => node[:deploy][:activemq_port],
    :server_type => node[:core][:server_type]
  )
end

bash 'Running local smoke tests' do
   code <<-EOF
    rake --rakefile #{ruby_scripts_dir}/local_messaging.rb
  EOF
end

# new smoke tests:
# validate that the cluster inputs are provided in the properties file


validate_properties(local_filename, token_values, validation_patterns)