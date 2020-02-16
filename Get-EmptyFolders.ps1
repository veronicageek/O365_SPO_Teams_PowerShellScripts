<#
.SYNOPSIS
    Get empty folders.
.DESCRIPTION
    Get the empty folders from a specific SharePoint Online site.
.EXAMPLE
    PS C:\> .\Get-EmptyFolders.ps1
    This script will retrieve all the empty folders from a specific site collection in SharePoint Online
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    More info on my blog post: https://veronicageek.com/office-365/sharepoint-online/find-empty-folders-in-a-sharepoint-site-using-powershell-pnp/2020/02/
#>
#Connect to SPO
Connect-PnPOnline -Url "https://<YOUR_TENANT_NAME>.sharepoint.com/sites/<YOUR_SITE>"

#Store in variable all the document libraries in the site
$DocLibrary = Get-PnPList | Where-Object { $_.BaseTemplate -eq 101 } 
$LogFile = "C:\users\$env:USERNAME\Desktop\SPOEmptyFolders.csv"

$results = @()
foreach ($DocLib in $DocLibrary) {
    #Get list of all folders in the document library
    $AllItems = Get-PnPListItem -PageSize 1000 -List $DocLib -Fields "SMTotalFileStreamSize", "Author"
    
    #Loop through each files/folders in the document library for >50Mb
    foreach ($Item in $AllItems) {
        if ((([uint64]$Item["SMTotalFileStreamSize"]) -eq 0)) {
            Write-Host "Empty folder:" $Item["FileLeafRef"] -ForegroundColor Yellow
    
            #Creating new object to export in .csv file
            $results += [pscustomobject][ordered] @{
                CreatedDate      = [DateTime]$Item["Created_x0020_Date"]
                FileName         = $Item["FileLeafRef"] 
                CreatedBy        = $Item.FieldValues.Author.LookupValue
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