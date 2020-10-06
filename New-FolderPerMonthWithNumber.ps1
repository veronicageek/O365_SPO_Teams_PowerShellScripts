#This function will create a folder per month with the number in from of it, in the site & library of your choice
#MORE INFO ON MY BLOG: https://veronicageek.com/powershell/powershell-for-o365/create-folders-with-months-name-in-sharepoint-online-using-powershell-pnp/2020/10/
#####################################################################################################################

function New-FolderPerMonthWithNumber {
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
    foreach ($monthsNumber in @(1..12)) {
        $monthNumFormatted = "{0:d2}" -f $monthsNumber
        
        Add-PnPFolder -Name ($monthNumFormatted + "_" + (Get-Culture).DateTimeFormat.GetMonthName($monthNumFormatted)) -Folder $Library
    
    }
}

New-FolderPerMonthWithNumber -SiteUrl "https://<TENANT-NAME>.sharepoint.com/sites/<YOUR-SITE>" -Library "<YOUR-LIBRARY-NAME>"

