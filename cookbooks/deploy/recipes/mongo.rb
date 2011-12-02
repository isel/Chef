template "/etc/mongo_test" do
  source "mongo.erb"
  variables(
    :port => node[:deploy][:mongo_port]
  )
end