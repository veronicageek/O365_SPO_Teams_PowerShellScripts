<#
.Synopsis
   Retrieve user's OneDrive for Business URL if provisioned.
.DESCRIPTION
   This script will retrieve the user's OneDrive for Business URL in Office 365 (if they have been provisioned) looping through the names on your Csv file.
   If the OneDrive for Business has not been provisioned (URL not available), then it won't appear on the output file.
.EXAMPLE
   .\Get-ODFBUrlFromCsvFile.ps1 -AdminAccount <O365_Admin_Account> -CsvFileLocation <Your_CsvFile_Location>
.EXAMPLE
   .\Get-ODFBUrlFromCsvFile.ps1 (if no parameters are entered, you will be prompted for them)
.INPUTS
   Csv File
.OUTPUTS
   A Csv file will be created and placed on the desktop for easy access (called Provisioned_ODFBUrl.csv).
.NOTES
   - The input file (your Csv file with users) MUST contain a header column named "UserPrincipalName".
   - This script uses CSOM so the SharePoint Online SDK components need to be installed prior to running this script.
    ** Download available from the official Microsoft website: https://www.microsoft.com/en-gb/download/details.aspx?id=42038
#>
[CmdletBinding()]
param(    
    [Parameter(Mandatory=$true,HelpMessage="Office 365 Admin account with correct permissions",Position=1)] 
    [string]$AdminAccount,  
    [Parameter(Mandatory=$true,HelpMessage="Office 365 tenant name",Position=2)] 
    [string]$TenantName,
    [Parameter(Mandatory=$true,HelpMessage="Location of the CSV file containing all the users to check",Position=3)] 
    [string]$CsvFileLocation
)
#Configure Site URL and User
$SiteURL = "https://$TenantName-my.sharepoint.com"

#Add references to SharePoint client assemblies and authenticate to O365 site required for CSOM
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.UserProfiles.dll"

$Password = Read-Host -Prompt "Please enter your Password" -AsSecureString
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($AdminAccount,$Password)

#Bind to Site Collection
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$Context.Credentials = $Creds

#Identify users in the Site Collection
$Users = $Context.Web.SiteUsers
$Context.Load($Users)
$Context.ExecuteQuery()

#Create People Manager object to retrieve profile data
$PeopleManager = New-Object Microsoft.SharePoint.Client.UserProfiles.PeopleManager($Context)

#Import Csv file and match with users from tenant
$csv = Import-Csv $CsvFileLocation
$csvlist = $csv.UserPrincipalName -join "|"
$users = $Users.LoginName | Where-Object {$_ -match $csvlist}

Foreach ($User in $Users)
    {
    $UserProfile = $PeopleManager.GetPropertiesFor($User)
    $Context.Load($UserProfile)
    $Context.ExecuteQuery()
    If ($UserProfile.Email -ne $null)
        {
        #Write-Host "User:" $User.UserPrincipalName -ForegroundColor Green
        $UserProfile.UserProfileProperties
        #Write-Host ""
        }  
    }

#Create People Manager object to retrieve profile data
$Output = "C:\users\$env:USERNAME\Desktop\Provisioned_ODFBUrl.csv"

#Format the Csv output file
$Headings = "UserPrincipalName","OneDriveURL"
$Headings -join "," | Out-File -Encoding default -FilePath $Output

$PeopleManager = New-Object Microsoft.SharePoint.Client.UserProfiles.PeopleManager($Context)
Foreach ($User in $Users)
    {
    $UserProfile = $PeopleManager.GetPropertiesFor($User)
    $Context.Load($UserProfile)
    $Context.ExecuteQuery()
    If ($UserProfile.Email -ne $null)
        {
        $UPP = $UserProfile.UserProfileProperties
        $Properties = $UPP.'SPS-UserPrincipalName',$UserProfile.PersonalUrl
        $Properties -join "," | Out-File -Encoding default -Append -FilePath $Output
        }  
    }
