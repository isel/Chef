revision = node[:deploy][:revision]

puts "revision: #{revision}"

File.open('/test', 'w') do |f|
  f.puts("revision: #{revision}")
end