require 'fog'

revision = node[:deploy][:revision]
message = "pulling build scripts from revision: #{revision}"

Chef::Log.info(message)

storage = Fog::Storage.new(
  :provider => 'AWS',
  :aws_access_key_id => node[:deploy][:access_key_id],
  :aws_secret_access_key => node[:deploy][:secret_access_key])

bucket = storage.directories.find{ |d| d.key == 'ugfartifacts' }

file = bucket.files.get("GlobalIncite/#{revision}/CI.zip")

deploy_folder = '/DeployScripts'
Dir.mkdir(deploy_folder)

File.open("#{deploy_folder}/CI.zip", 'wb') do |local_file|
  local_file.write(file.body)
end

