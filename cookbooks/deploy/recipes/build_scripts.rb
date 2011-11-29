revision = node[:deploy][:revision]

File.open('~/test', 'w') do |f|
  puts "revision: #{revision}"
  f.puts("revision: #{revision}")
end