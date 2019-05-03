<#
.SYNOPSIS
    This script will retrieve site collections and subsites.
.DESCRIPTION
    This script will retrieve all Site Collections and subsites (top level) and export to a .csv file on the user's desktop.
.INPUTS
    Inputs (if any)
.OUTPUTS
    System.Object[]
.NOTES
    This script uses the SharePoint PnP module: https://github.com/SharePoint/PnP-PowerShell
#>
#Connect to SPO admin center -- CHANGE TO YOUR TENANT NAME
$creds = Get-Credential
Connect-PnPOnline -Url https://<TENANT_NAME>.sharepoint.com -Credentials $creds

#Get all Site Collections in tenant + subsites 
$results = @()
$allMySites = Get-PnPTenantSite

foreach ($SC in $allMySites) {
    Write-Host "Connecting to $($SC.Url)" -ForegroundColor Green
    try {
        Connect-PnPOnline -Url $SC.Url -Credentials $creds
    
        $SiteColTitle = $SC.Title
        $SiteColUrl = $SC.Url
        $Subsites = Get-PnPSubWebs
    
        $Properties = @{
            SiteColName = $SiteColTitle
            SiteColUrl  = $SiteColUrl
            SubsiteName = ($Subsites.Title | Out-String).Trim()
            SubsiteUrl  = ($Subsites.ServerRelativeUrl | Out-String).Trim()
        }
        $results += New-Object psobject -Property $Properties
    }
    catch {
        Write-Host "You don't have access to this Site Collection." -ForegroundColor Red
    }
}
$results | Select-Object SiteColName, SiteColUrl, SubsiteName, SubsiteUrl | Export-Csv -Path "C:\Users\$env:USERNAME\Desktop\SitesAndSubsites.csv" -NoTypeInformation
