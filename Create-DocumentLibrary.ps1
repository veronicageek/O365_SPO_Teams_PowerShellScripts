<#
.Synopsis
   Create a document library using SharePoint PnP.
.DESCRIPTION
   This script will create a document library under the site collection you decide to connect to, and will display on the Quick Launch.
.EXAMPLE
   .\Create-DocumentLibrary.ps1 -SiteCollection <site_collection_URL> -LibraryName <Name_for_the_Library>
.EXAMPLE
   .\Create-DocumentLibrary.ps1 -SiteCollection https://<tenantName>.sharepoint.com/sites/test -LibraryName "My New Library"
.NOTES
   This script is using SharePoint Practices & Patterns (PnP). For more information please refer to the official documentation
   located here: https://msdn.microsoft.com/en-us/pnp_powershell/pnp-powershell-overview

   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +++ PRE-REQS +++ Download and install the SharePoint PnP modules: https://github.com/SharePoint/PnP-PowerShell
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#>
[CmdletBinding()]
Param
(
    [Parameter(Mandatory=$true,Position=1)]
    [string]$SiteCollection,
    [Parameter(Mandatory=$true,Position=2)]
    [string]$LibraryName
)
try{
    #Connect to SPO Site Collection
    Connect-PnPOnline -Url $SiteCollection -Credentials (Get-Credential) -ErrorAction Stop
}
catch{
    Write-Error "Site Collection or Credentials not valid. Please check again."
    break
}

New-PnPList -Title $LibraryName -Template DocumentLibrary -OnQuickLaunch

#Show lists/libraries in the Site Collection
Get-PnPList
