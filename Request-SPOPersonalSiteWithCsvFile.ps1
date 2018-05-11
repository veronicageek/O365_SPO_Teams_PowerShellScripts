<#
.Synopsis
   This script will pre-provision users' ODFB in O365 contained in a CSV file.
.DESCRIPTION
   This script will pre-provision users' ODFB in O365 from a CSV file where there's a MSFT hard limit of 200 users.
   ** MORE INFO: https://technet.microsoft.com/en-us/library/dn792367.aspx **

   +++ IMPORTANT +++   The .CSV file needs to contain a column with header titled "UserPrincipalName"

.EXAMPLE
   .\Request-SPOPersonalSiteWithCsvFile.ps1 -TenantName <Name_of_the_O365_Tenant> -CsvFileLocation <CsvFile_Location>
.EXAMPLE
   .\Request-SPOPersonalSiteWithCsvFile.ps1 (if no parameters are entered, you will be prompted for them)
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true,HelpMessage="This is the name of the O365 tenant",Position=1)] 
    [string]$TenantName,    
    [Parameter(Mandatory=$true,HelpMessage="This is the location of the CSV file containing all the users to check",Position=2)] 
    [string]$CsvFileLocation    
)
#Script started at
$startTime = "{0:G}" -f (Get-date)
Write-Host "*** Script started on $startTime ***" -f White -b DarkYellow

#Connect to SPO
$O365Cred = Get-Credential
Connect-SPOService -Url https://$TenantName-admin.sharepoint.com -Credential $O365Cred
Write-host "Connected to SPO. Starting the provisioning process..." -f Yellow

#Pre-provision ODFB
$emails = Import-Csv $CsvFileLocation

foreach ($UserPrincipalName in $emails){
    Request-SPOPersonalSite -UserEmails $emails.UserPrincipalName -NoWait
}

Write-Host "All done." -f Green

#Script finished at
$endTime = "{0:G}" -f (Get-date)
Write-Host "*** Script finished on $endTime ***" -f White -b DarkYellow
Write-Host "Time elapsed: $(New-Timespan $startTime $endTime)" -f White -b DarkRed
