powershell "Set fxcop path" do
  parameters (
    {
        :properties_file => node[:properties_file],
        'key' => 'system.FxCopRoot',
        'value' => 'C\:\\Program Files (x86)\\\Microsoft Visual Studio 10.0\\\Team Tools\\\Static Analysis Tools\\\FxCop',
    }
  )
  source(node[:set_value_in_properties_file_powershell_script])
end
