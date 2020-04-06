#Connect to SPO --> CHANGE TO YOUR TENANT NAME & SITE
Connect-PnPOnline -Url https://<TENANT-NAME>.sharepoint.com/sites/<YOUR-SITE>

#Variables
$results = @()
$allLists = Get-PnPList | Where-Object { $_.BaseTemplate -eq 100 }

#Loop thru each lists
foreach ($list in $allLists) {
    $allItems = Get-PnPListItem -List $list.Title
    
    #Loop thru thru each item in the list(s)
    foreach ($item in $allItems) {
        $allProps = Get-PnPProperty -ClientObject $item -Property "AttachmentFiles"
        
        #Loop thru each property and grab the ones we want!
        foreach ($prop in $allProps) {
            $results += [pscustomobject][ordered]@{
                ListName           = $list.Title
                ItemName           = $item["Title"]
                ItemCreatedBy      = $item.FieldValues.Author.LookupValue
                ItemLastModifiedBy = $item.FieldValues.Editor.LookupValue
                AttachmentNames    = $prop.FileName
                ServerRelativeUrl  = $prop.ServerRelativeUrl
            }
        }
    }
}
$results | Export-Csv -Path "<YOUR_PATH>" -NoTypeInformation