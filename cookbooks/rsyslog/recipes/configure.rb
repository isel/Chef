rightscale_marker :begin

raise "Ubuntu not supported" if node[:platform] == "ubuntu"

agent_dir = "#{ENV['ProgramFiles(x86)']}\\RSyslog\\Agent"

template "#{agent_dir}\\settings.reg" do
  source 'settings.erb'
  variables(
    :remote_log_server => node[:rsyslog][:remote_log_server],
    :header => '<% syslogprifac %>%syslogver% %timereported:::date-rfc3339% %source% %syslogappname% %syslogprocid% %syslogmsgid% %syslogstructdata%'
  )
end

powershell 'Import rsyslog settings' do
  parameters( { 'AGENT_DIR' => agent_dir } )
  script = <<EOF
    $general_options = Get-Item -Path Registry::HKEY_LOCAL_MACHINE\\SOFTWARE\\Wow6432Node\\Adiscon\\RSyslogAgent\\General | Select-Object -ExpandProperty Property
    if ($general_options.count -lt 2) { regedit /s "$env:AGENT_DIR\\settings.reg" }
EOF
  source(script)
end

powershell 'Restart service' do
  source('Restart-Service "RSyslogWindowsAgent"')
end

rightscale_marker :end

