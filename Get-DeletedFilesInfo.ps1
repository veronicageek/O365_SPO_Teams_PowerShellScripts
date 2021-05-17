Connect-PnPOnline -Url "https://<TENANT-NAME>.sharepoint.com/sites/<YOUR-SITE>" -Credentials <YOUR-CREDS>

$allDeletedItems = Get-PnPRecycleBinItem
$results = @()

foreach($item in $allDeletedItems){
    $userID = (Get-PnPAzureADUser | Where-Object {$_.DisplayName -match $item.DeletedByName}).Id
    
    $results += [pscustomobject]@{
        fileName = $item.LeafName
        deletedBy = $item.DeletedByName
        deletedDate = $item.DeletedDate
        userID = $userID
    }
}
$results
