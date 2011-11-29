revision = node[:deploy][:revision]

File.open('~/test', 'w') do |f|
  f.puts("revision: #{revision}")
end