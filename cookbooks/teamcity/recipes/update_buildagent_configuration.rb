powershell 'Update TC configuration' do
  parameters (
    {
        'properties_file' => node['properties_file'],
        'key' => 'system.file.encoding',
        'value' => 'UTF-8'
    }
  )
  source(node['set_value_in_properties_file_powershell_script'])
end
