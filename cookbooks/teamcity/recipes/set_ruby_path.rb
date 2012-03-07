powershell "Set ruby path" do
  parameters (
    {
        'properties_file' => node['properties_file'],
        'key' => 'env.RubyPath',
        'value' => 'c:\\ruby192\\bin\\ruby.exe',
    }
  )
  source(node['set_value_in_properties_file_powershell_script'])
end
