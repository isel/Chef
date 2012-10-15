require 'rake'
require 'fileutils'

powershell 'Update TC configuration' do
  parameters()
powershell_script = <<-'EOF'
write-output "Probing RS_REBOOT=${env:RS_REBOOT}"

if ( (${Env:RS_REBOOT} -ne $null) -and (${Env:RS_REBOOT} -match 'true'))  {
   write-output 'Skipping TC configuration change during reboot.'
   $Error.Clear()
   exit 0
   }

$buildServer_java_class_name = 'jetbrains.buildServer.agent.AgentMain'
$build_agent_home ='C:\BuildAgent'
$properties_file = "${build_agent_home}\\conf\\buildAgent.properties"
$setting_value = 'UTF-8'
$setting_name = 'system.file.encoding'

$properties = Get-Content $properties_file
if ($properties -match "^${setting_name}=") {
  Write-output "Updating setting ${setting_name}"
  $properties =  $properties -Replace  "^${setting_name}=.+$", "${setting_name}=${setting_value}"
} else {
  Write-output "Creating setting ${setting_name}"
  $properties += @"
${setting_name}=${setting_value}
"@
}
Set-Content  -literalPath $properties_file -value $properties

# review the service process
Get-WmiObject win32_process -Filter "commandline like '%${buildServer_java_class_name}%'" | select processId,CommandLine | Format-Table -AutoSize -Wrap

$Error.clear()
  EOF
  source(powershell_script)
end


