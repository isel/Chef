powershell('Setup volumes') do
  parameters(
    {
      'DATA_VOLUME_SIZE' => '300',
      'LOGS_VOLUME_SIZE' => '300',
      'FORCE_CREATE_VOLUMES' => 'True',
      'LINEAGE_NAME' => 'TeamCity Web',
      'RESTORE_TIMESTAMP' => '',
      'AWS_ACCESS_KEY_ID' => node[:core][:aws_access_key_id],
      'AWS_SECRET_ACCESS_KEY' => node[:core][:aws_secret_access_key],
      'NUMBER_STRIPES' => 1
    }
  )
  script = <<-EOF
# Stop and fail script when a command fails.
$errorActionPreference = "Stop"

# load library functions
$rsLibDstDirPath = "$env:rs_sandbox_home\\RightScript\\lib"
. "$rsLibDstDirPath\\tools\\ResolveError.ps1"
. "$rsLibDstDirPath\\tools\\Checks.ps1"
. "$rsLibDstDirPath\\tools\\RepartitionDisk.ps1"
. "$rsLibDstDirPath\\tools\\Text.ps1"
. "$rsLibDstDirPath\\tools\\ExtractReturn.ps1"
. "$rsLibDstDirPath\\ros\\Ros.ps1"
. "$rsLibDstDirPath\\ros\\RosBackups.ps1"
. "$rsLibDstDirPath\\ebs\\EbsRestoreVolumes.ps1"
. "$rsLibDstDirPath\\ebs\\EbsCreateAttachVolume.ps1"
. "$rsLibDstDirPath\\ebs\\EbsCreateAttachStripe.ps1"

# Helper function to create env variables
function SetDrivesEnvVars($dataLetter, $logsLetter, $dataDevices, $logsDevices)
{
    $dataDevices = $dataDevices -join ','
    $logsDevices = $logsDevices -join ','

    Write-Host "Setting environment variables:"
    [Environment]::SetEnvironmentVariable("RS_SQLS_DATA_VOLUME", $dataLetter, "Machine")
    [Environment]::SetEnvironmentVariable("RS_SQLS_DATA_VOLUME", $dataLetter, "Process")
    [Environment]::SetEnvironmentVariable("DATA_DEVICES", $dataDevices, "Machine")
    Write-Host "RS_SQLS_DATA_VOLUME=${dataLetter}"
    Write-Host "DATA_DEVICES=${dataDevices}"

    [Environment]::SetEnvironmentVariable("RS_SQLS_LOGS_VOLUME", $logsLetter, "Machine")
    [Environment]::SetEnvironmentVariable("RS_SQLS_LOGS_VOLUME", $logsLetter, "Process")
    [Environment]::SetEnvironmentVariable("LOGS_DEVICES", $logsDevices, "Machine")
    Write-Host "RS_SQLS_LOGS_VOLUME=${logsLetter}"
    Write-Host "LOGS_DEVICES=${logsDevices}"
}

try
{
    $dataVolExists = $env:RS_SQLS_DATA_VOLUME -and (Test-Path "${env:RS_SQLS_DATA_VOLUME}:\")
    $logsVolExists = $env:RS_SQLS_LOGS_VOLUME -and (Test-Path "${env:RS_SQLS_LOGS_VOLUME}:\")
    if ($dataVolExists -or $logsVolExists)
    {
        Write-Host "Skipping: data and/or log volumes exist already."
        exit 0
    }

    # Check and process input values

    # Force create volumes if mirror (databases to be imported from principal or specific input is set)
    if ($env:FORCE_CREATE_VOLUMES -eq 'True')
    {
        Write-Host "FORCE_CREATE_VOLUMES is set to True - skipping restore and creating new volumes from scratch."
        $forceCreateVolumes = $True
    }

    $dataDriveLetter = 'D'
    $logsDriveLetter = 'E'

    $newVolumes = $False

    # Create drive letter exceptions for striped volumes creation to make possible
    # further attachments of backup and temporary volumes
    $dataReservedLetters = @($logsDriveLetter)
    $logsReservedLetters = @()
    $bl = 'G'
    $dataReservedLetters += $bl.SubString(0,1).ToUpper()
    $logsReservedLetters += $bl.SubString(0,1).ToUpper()
    $tl = 'F'
    $dataReservedLetters += $tl.SubString(0,1).ToUpper()
    $logsReservedLetters += $tl.SubString(0,1).ToUpper()

    # Declare AWS credentials needed by EbsRestoreVolumes and EbsCreateAttachVolume
    # $env:AWS_ACCESS_KEY_ID
    # $env:AWS_SECRET_ACCESS_KEY

    $lineageName = $env:LINEAGE_NAME
    $timestamp = $env:RESTORE_TIMESTAMP

    if (!$forceCreateVolumes -and $lineageName)
    {
        Write-Host "Trying to restore volumes from EBS snapshots..."
        EbsRestoreVolumes $lineageName $timestamp
    }

    # Create volumes if not restored
    if (!$env:RS_SQLS_DATA_VOLUME -and !$env:RS_SQLS_LOGS_VOLUME)
    {
        Write-Host "Creating new data and log volumes..."
        CheckInputInt 'DATA_VOLUME_SIZE' $False 1 | Out-Null
        CheckInputInt 'LOGS_VOLUME_SIZE' $False 1 | Out-Null
        CheckInputInt 'NUMBER_STRIPES' $False 1 6 | Out-Null

        if ($env:NUMBER_STRIPES -eq 1)
        {
            write-host 'Creating volumes via EbsCreateAttachVolume'
            EbsCreateAttachVolume $dataDriveLetter $env:DATA_VOLUME_SIZE
            EbsCreateAttachVolume $logsDriveLetter $env:LOGS_VOLUME_SIZE
            $dataDevices = "xvd${dataDriveLetter}".ToLower()
            $logsDevices = "xvd${logsDriveLetter}".ToLower()
        }
        else
        {
            $dataDevices = EbsCreateAttachStripedVolume $env:NUMBER_STRIPES $env:DATA_VOLUME_SIZE $dataDriveLetter $dataReservedLetters $env:EC2_INSTANCE_ID $env:AWS_ACCESS_KEY_ID $env:AWS_SECRET_ACCESS_KEY | ExtractReturn
            $logsDevices = EbsCreateAttachStripedVolume $env:NUMBER_STRIPES $env:LOGS_VOLUME_SIZE $logsDriveLetter $logsReservedLetters $env:EC2_INSTANCE_ID $env:AWS_ACCESS_KEY_ID $env:AWS_SECRET_ACCESS_KEY | ExtractReturn
            Write-Host "Devices: `n${dataDevices}`n---`n${logsDevices}"
        }
        SetDrivesEnvVars $dataDriveLetter $logsDriveLetter $dataDevices $logsDevices
        $newVolumes = $True
    }

    $error.Clear()
}
catch
{
    ResolveError
    exit 1
}
  EOF
  source(script)
end