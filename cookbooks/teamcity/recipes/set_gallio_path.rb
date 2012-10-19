powershell "Set gallio path" do
  parameters (
    {
        :properties_file => node[:properties_file],
        'key' => 'env.GallioPath',
        'value' => node[:teamcity][:gallio_path],
    }
  )
  source(node[:set_value_in_properties_file_powershell_script])
end
