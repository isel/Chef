powershell "Set administrator user for mongo" do
  parameters (
    {
       'properties_file' => node['properties_file'],
       'key' => 'env.AdminUserMongo',
       'value' => node[:teamcity][:admin_user_mongo],
    }
  )
  source(node['set_value_in_properties_file_powershell_script'])
end