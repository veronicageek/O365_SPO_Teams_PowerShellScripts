#This function will create a folder per month in the site & library of your choice
###################################################################################

function New-FolderPerMonth {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Site Url to connect to", Position = 0)] 
        [string]$SiteUrl,  
        [Parameter(Mandatory = $true, HelpMessage = "List to create the folders in", Position = 1)] 
        [string]$Library 
    )
    #Connect to the designated site
    Connect-PnPOnline -Url $SiteUrl
    
    #Create the folders
    for ($i = 1; $i -le 12; $i++) {
        Add-PnPFolder -Name (Get-Culture).DateTimeFormat.GetMonthName($i) -Folder $Library
    }
}

New-FolderPerMonth -SiteUrl "https://<TENANT-NAME>.sharepoint.com/sites/<YOUR-SITE>" -Library "<YOUR-LIBRARY-NAME>"
