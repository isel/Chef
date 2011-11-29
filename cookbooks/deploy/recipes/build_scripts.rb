revision = node[:deploy][:revision]
message = "revision: #{revision}"

Chef::Log.info(message)
Chef::Log.info(`ruby -v`)

File.open('/test', 'w') do |f|
  f.puts(message)
end