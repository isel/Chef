powershell "Set ncover path" do
  parameters (
    {
        'properties_file' => 'C:\BuildAgent\conf\buildAgent.properties',
        'key' => 'env.ncoverPath',
        'value' => 'C\:\Program Files\NCover',
    }
  )
  source(node['set_value_in_properties_file__powershell_script'])
end
