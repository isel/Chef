revision = node[:deploy][:revision]
message = "revision: #{revision}"

Chef::Log.info(message)

File.open('/test', 'w') do |f|
  f.puts(message)
end