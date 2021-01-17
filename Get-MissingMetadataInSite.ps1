#Connect to SPO
Connect-PnPOnline -Url "https://<TENANT-NAME>.sharepoint.com/sites/<YOUR-SITE>" -Credentials <YOUR-CREDS>

#variables
$allLibs = Get-PnPList 
$results = @()

foreach($lib in $allLibs){
    $allDocs = Get-PnPListItem -List $lib
    
    foreach($doc in $allDocs){
        $allRequiredFields = Get-PnPField -List $lib | Where-Object {$_.Required -eq $true}  #Giving an array
        
        foreach($field in $allRequiredFields){
            if ($null -eq $doc.FieldValues["$($field.InternalName)"]) {
                
                $results += [pscustomobject]@{
                    FileName = $doc.FieldValues.FileLeafRef
                    CreatedBy = $doc.FieldValues.Author.LookupValue
                    MissingMetadata = $field.Title
                    FileLocation = $lib.Title
                }
            }
        }
    }    
}
$results
