powershell "Set ncover path" do
  parameters (
    {
        'properties_file' => node['properties_file'],
        'key' => 'env.ncoverPath',
        'value' => 'C\:\Program Files\NCover',
    }
  )
  source(node['set_value_in_properties_file_powershell_script'])
end
