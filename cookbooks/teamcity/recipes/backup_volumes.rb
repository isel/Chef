powershell('Backup volumes') do
  parameters({ 'LINEAGE_NAME' => 'TeamCity Web' })
  script = <<-EOF
    $errorActionPreference="Stop"

    # load library functions
    $rsLibDstDirPath = "$env:rs_sandbox_home\RightScript\lib"
    . "$rsLibDstDirPath\tools\ResolveError.ps1"
    #. "$rsLibDstDirPath\tools\Checks.ps1"
    #. "$rsLibDstDirPath\tools\ExtractReturn.ps1"
    . "$rsLibDstDirPath\ebs\EbsBackupVolumes.ps1"

    try
    {
        if (!(Test-Path "${env:RS_SQLS_DATA_VOLUME}:\") -or !(Test-Path "${env:RS_SQLS_LOGS_VOLUME}:\"))
        {
            Write "Volumes not found - nothing to backup. Exit silently."
            exit 0
        }

        Write-Host "Backup method is Snapshots."
        $dataDevices = $(if ($env:RS_SQLS_DATA_DEVICES) { ([string]$env:RS_SQLS_DATA_DEVICES).Split(',') } else { @() })
        $logsDevices = $(if ($env:RS_SQLS_LOGS_DEVICES) { ([string]$env:RS_SQLS_LOGS_DEVICES).Split(',') } else { @() })

        # using defaults for DB_BACKUP_KEEP_* specified in C:\Program Files (x86)\RightScale\RightLink\sandbox\RightScript\lib\ebs\EbsBackupVolumes.ps1
        EbsBackupVolumes $env:RS_SQLS_DATA_VOLUME $env:RS_SQLS_LOGS_VOLUME $env:LINEAGE_NAME $dataDevices $logsDevices
    }
    catch
    {
        ResolveError
        exit 1
    }
  EOF
  source(script)
end