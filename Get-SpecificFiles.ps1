<#
.SYNOPSIS
    Export specific files from a site.
.DESCRIPTION
    This script will export specific files from a site, looping through each document libraries.
.EXAMPLE
    PS C:\> Get-SpecificFiles.ps1
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    This script uses SharePoint PowerShell PnP available on Github:
    https://github.com/SharePoint/PnP-PowerShell
    
    Using this script is detailed in my blog post located here:
    https://veronicageek.com/office-365/sharepoint-online/retrieve-files-with-a-specific-name-in-a-sharepoint-online-site-using-powershell-pnp/2019/06/
#>

#Connect to SPO
$creds = Get-Credential
Connect-PnPOnline -Url https://<TENANT_NAME>.sharepoint.com/sites/<YOUR_SITE> -Credentials $creds ### Change to your specific site ###

#Output path
$outputPath = "C:\users\$env:USERNAME\Desktop\specificFiles.csv"

#Store in variable all the document libraries in the site
$DocLibs = Get-PnPList | Where-Object { $_.BaseTemplate -eq 101 } 

#Loop thru each document library & folders
$results = @()
foreach ($DocLib in $DocLibs) {
    $AllItems = Get-PnPListItem -List $DocLib -Fields "FileRef", "File_x0020_Type", "FileLeafRef"
    
    #Loop through each item
    foreach ($Item in $AllItems) {
        ## Change *ABC* and *BCD* to your own requirements
        if (($Item["FileLeafRef"] -like "*ABC*") -or ($Item["FileLeafRef"] -like "*BCD*")) {
            Write-Host "File found. Path:" $Item["FileRef"] -ForegroundColor Green
            
            #Creating new object to export in .csv file
            $results += New-Object PSObject -Property @{
                Path          = $Item["FileRef"]
                FileName      = $Item["FileLeafRef"]
                FileExtension = $Item["File_x0020_Type"]
            }
        }
    }
}
$results | Export-Csv -Path $outputPath -NoTypeInformation
