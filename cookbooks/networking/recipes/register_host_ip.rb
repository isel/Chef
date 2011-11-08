host_file = 'C:/Windows/System32/drivers/etc/hosts'

puts host_file

File.open('c:\test.txt', 'a+') { |file| file.puts host_file }