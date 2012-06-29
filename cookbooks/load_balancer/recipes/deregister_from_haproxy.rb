bash 'Removing instance from haproxy configuration' do
  code <<-EOF
    name='LB - disconnect instance from haproxy'
    parameters="INSTANCE_BACKEND_NAME=text:#{node[:load_balancer][:backend_name]}"
    tags="lb:prefix=#{node[:load_balancer][:prefix]}"
    rs_run_right_script --name "#{name}" --parameter "#{parameters}" --recipient_tags "#{tags}"
  EOF
end
