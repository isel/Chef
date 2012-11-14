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
  source("regedit /s \"#{agent_dir}\\settings.reg\"")
end

powershell 'Start service' do
  script = <<EOF
    Set-Service "RSyslogWindowsAgent" -startupType automatic
    Restart-Service "RSyslogWindowsAgent"
EOF
  source(script)
end

rightscale_marker :end

