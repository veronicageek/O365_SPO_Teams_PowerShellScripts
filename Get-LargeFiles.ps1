<#
.SYNOPSIS
    Get large files.
.DESCRIPTION
    Get large files in SharePoint Online.
.EXAMPLE
    PS C:\> .\Get-Largefiles.ps1
    This script will retrieve large files in SharePoint Online (i.e.: >50Mb)
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    More info on my blog post: https://veronicageek.com/office-365/sharepoint-online/retrieve-files-bigger-than-50mb-in-a-sharepoint-online-site-using-powershell-pnp/2019/04/
#>
#Connect to SPO --->> CHANGE TO YOUR TENANT NAME & SITE
Connect-PnPOnline -Url "https://<YOUR_TENANT_NAME>.sharepoint.com/sites/<YOUR_SITE>"

#Store in variable all the document libraries in the site
$DocLibrary = Get-PnPList | Where-Object { $_.BaseTemplate -eq 101 } 
$LogFile = "C:\users\$env:USERNAME\Desktop\SPOLargeFiles.csv"

$results = @()
foreach ($DocLib in $DocLibrary) {
    #Get list of all folders in the document library
    $AllItems = Get-PnPListItem -List $DocLib -Fields "SMTotalFileStreamSize"
    
    #Loop through each files/folders in the document library for >50Mb
    foreach ($Item in $AllItems) {
        if ((([int]$Item["SMTotalFileStreamSize"]) -ge 50000000) -and ($Item["FileLeafRef"] -like "*.*")) {
            Write-Host "File found:" $Item["FileLeafRef"] -ForegroundColor Yellow
        
            #Creating new object to export in .csv file
            $results += [pscustomobject] @{
                FileName         = $Item["FileLeafRef"] 
                FilePath         = $Item["FileRef"]
                SizeInMB         = ($Item["SMTotalFileStreamSize"] / 1MB).ToString("N")
                LastModifiedBy   = $Item.FieldValues.Editor.LookupValue
                EditorEmail      = $Item.FieldValues.Editor.Email
                LastModifiedDate = [DateTime]$Item["Modified"]
            }
        }#end of IF statement
    }
}
$results | Export-Csv -Path $LogFile -NoTypeInformation