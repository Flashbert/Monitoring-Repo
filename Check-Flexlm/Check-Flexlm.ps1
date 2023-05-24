<#
.Synopsis
   Check Flexlm License performance
.DESCRIPTION
   Check the license usage of a Flexlm / Flexnet Server i.e. solidworks
   This script is mainly written as customcheck for OpenITcockpit and
   can run on any server with a agent. You can pass the server and port
   of the flexnet license manager.
   Helps to track how many licenses you actually use

   Pre-requisites:
    * lmutil.exe Download: https://www.plexim.com/dstlm

   Usage with OpenITCockpit
   ------------------------
   Add an command to your customchecks.ini:
   [check_solidworks_lic]
     command = "C:\Batch\Check-Flexlm.ps1 -feature solidworks"
    shell = powershell
    interval = 300
    timeout = 15
    enabled = true

   Add the custom check with Agent Discovery


.NOTES
   Created by: Andreas Kestler
   Modified: 24.05.2023 07:18  

   Version 1.0

   Changelog:
    1.0
    * Initial script

.PARAMETER flexhost
    Specify the Flexlm Server host and port PORT@HOSTORIP
.PARAMETER feature
    Specify the product you want to check the license data.
    Use "lmutil.exe lmstat -c 25734@host" -a to get your featurenames
.PARAMETER lmutilPath
    Specify path to lmutil (must be hardcoded for OITC, $PSScriptRoot not working)
.PARAMETER CertificatePath
    Specify the path to the certificate store.
.EXAMPLE
   .\Check-Flexlm.ps1 -feature solidworks
   Checks usage of Solidworks Standard (showing percentage, used and total number)
#>
#Requires -Version 2.0
[CmdletBinding()]
Param
(
    # Name of the server, defaults to local
    [Parameter(Mandatory=$false,
                ValueFromPipelineByPropertyName=$true,
                Position=0)]
    [string]$flexhost='25734@localhost',
    [string]$feature="solidworks",
    [int]$returnStateOK = 0,
    [int]$returnStateWarning = 1,
    [int]$returnStateCritical = 2,
    [int]$returnStateUnknown = 3,
    [int]$WarningPercentage = 90,
    [int]$CriticalPercentage = 100,
    [string]$lmutilPath = "$PSScriptRoot" #For OITC you need hardcoded path like C:\Batch
)

#Get usage log with lmutil (dot sourcing to also receive output)
try {
    $lmutil_log = . "$lmutilPath\lmutil.exe" lmstat -c $flexhost -a
} catch {
    Write-Host "lmutil.exe not found |" ; exit $returnStateUnknown
}

Foreach ($line in $lmutil_log) {

    if($line.StartsWith("Users of $feature")) {
        if($line -match 'Users of (?<product>.*):[^0-9]+(?<licmax>\d+)[^0-9]+(?<licused>\d+)') {
            #Calculate percentage of license usage
            [int]$licused = $Matches.licused
            [int]$licmax = $Matches.licmax
            #Round to decimals and multiply by 100 (for percentage)
            $percentageused = [math]::Round($licused / $licmax * 100,2)

            #Output and performancedata
            $perfdata = "Lic_Used=$percentageused% used=$licused total=$licmax"
            If($percentageused -ge $WarningPercentage) {
                Write-Host "License usage for $feature $licused/$licmax | $perfdata" ; exit $returnStateWarning
            } elseif($percentageused -ge $criticalPercentage) {
                Write-Host "License usage for $feature $licused/$licmax | $perfdata" ; exit $returnStateCritical
            } else {
                Write-Host "License usage for $feature $licused/$licmax | $perfdata" ; exit $returnStateOK
            }
        }
        
    }
    #if log contains error, status unknown
    if($line.Contains("Error")) {
        Write-Host "$line |" ; exit $returnStateUnknown
    }
}