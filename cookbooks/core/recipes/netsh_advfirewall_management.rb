require 'rake'
require 'fileutils'

log "Probing RS_REBOOT=#{ENV['RS_REBOOT']}"

if ENV['RS_REBOOT'] == 'true'
  log 'Skipping firewall configuration change during reboot.'
  exit(0)
end


powershell 'Disable firewall' do
  parameters (
  )
powershell_script = <<-'EOF'
write-output "Probing RS_REBOOT=${env:RS_REBOOT}"

if ( (${Env:RS_REBOOT} -ne $null) -and (${Env:RS_REBOOT} -match 'true'))  {
   write-output 'Skipping script execution during reboot'
   $Error.Clear()
   exit 0
  }

<#
* Core netsh command syntax  for Widows Firewall Advanced Security
http://technet.microsoft.com/en-us/library/cc771920(v=ws.10).aspx
* No equivalent servermanagercmd option.
#>

# Note the single trailing whitespace
$settings_detailed = @{
  'Domain Profile Settings: ' = $null;
  'Private Profile Settings: ' = $null ;
  'Public Profile Settings: ' = $null
}

$settings_array = ( invoke-expression "netsh.exe advfirewall show allprofiles" ) `
                  |where-object {$_ -match 'State' -or $_ -match ' Settings: ' }
# group together the headers and settings per state
for ($cnt = 0; $cnt -lt $settings_array.length - 1; $cnt += 2 ) {
  if ( $settings_detailed.ContainsKey($settings_array[$cnt]) ){
    $setting_str = $settings_array[$cnt + 1]
    if ( $setting_str -match  '^State\s*(?<setting>ON|OFF)\s*$' ) {
      $value =  $matches['setting']
    } else {
      $value = $null
    }
    $settings_detailed.Set_Item($settings_array[$cnt] , $value )
  }
}

write-output $settings_detailed |  format-table


# evaluate $action_required - whether we need to run netsh
# through setting enumerator  walk
# finding other then $expected_value

$expected_value = 'OFF'
$action_required = $false

foreach ($en in $settings_detailed.GetEnumerator()) {
  if  ( $en.Value -ne $expected_value ) {
    write-output ( [string]::Join(' ',  ( 'Wrong settings for:', $en.Name, '=', $en.Value )))
    $action_required =$true
  }
}

$Error.clear()

if ($action_required -eq $false){
  write-output 'Windows Firewall is already disabled'
} else {
  write-output 'Disable Windows Firewall'
  invoke-expression 'netsh.exe advfirewall set allprofiles state off'
}

$Error.clear()
EOF
  source(powershell_script)
end


