#Connect to SPO site
Connect-PnPOnline -Url "https://<TENANT-NAME>.sharepoint.com/sites/<YOUR-SITE>"

#Store pages into a variable
$sitePagesGallery = Get-PnPList -Identity "Site Pages"

#Export to a file
$logFile = "C:\users\$env:USERNAME\Desktop\LikesAndComments.csv"

#Get the pages details
$results = @()

foreach ($item in $sitePagesGallery) {
    $allPages = Get-PnPListItem -List $sitePagesGallery -Fields "FileLeafRef", "Title", "ID", "FileRef", "_CommentCount", "_LikeCount"
    
    #Choose the properties to export
    foreach ($page in $allPages) {
        $results += New-Object -TypeName psobject -Property @{
            Title         = $page["Title"]
            ID            = $page.ID
            FullPath      = $page["FileRef"]
            NumOfComments = $page["_CommentCount"]
            NumOfLikes    = $page["_LikeCount"]        
        }
    }
}
$results | Export-Csv -Path $logFile -NoTypeInformation
