powershell('Setting sa password') do
  parameters ({ 'PASSWORD' => node[:mssql][:sa_password] })
  script = <<-EOF
    add-pssnapin sqlserverCmdletSnapin100

    Invoke-Sqlcmd -Query "ALTER LOGIN [sa] WITH PASSWORD='$env:PASSWORD'"
  EOF
  source(script)
end