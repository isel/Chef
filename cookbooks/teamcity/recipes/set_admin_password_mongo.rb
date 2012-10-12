powershell "Set administrator password for mongo" do
  parameters (
    {
       'properties_file' => node['properties_file'],
       'key' => 'env.AdminPasswordMongo',
       'value' => node[:teamcity][:admin_password_mongo],
    }
  )
  source(node['set_value_in_properties_file_powershell_script'])
end