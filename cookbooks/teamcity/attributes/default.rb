default['ruby_scripts_dir'] = '/RubyScripts'

default['set_value_in_properties_file__powershell_script'] = <<-POWERSHELL_SCRIPT
if (Get-Content $env:properties_file| Select-String "$env:key=" -quiet)
{
    Write-Output "Replacing $env:key in agent properties file"
    (Get-Content ($env:properties_file)) | Foreach-Object {$_ -replace "^$env:key=.+$", ("$env:key=" + $env:value)} | Set-Content  ($env:properties_file)
}
else
{
    Write-Output "Writing $env:key to properties file"
    Add-Content $env:properties_file "`n"
    Add-Content $env:properties_file "$env:key=$env:value"
}
POWERSHELL_SCRIPT


