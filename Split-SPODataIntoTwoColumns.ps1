<#
.SYNOPSIS
    Split data into 2 columns.
.DESCRIPTION
    Split data from one (1) column into two (2) columns.
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    This script works well combined with a Power Automate flow for new items created in the list.
    In this example, we take the column FullName, and split it into 2 columns (FirstName + LastName)
    
    More details on my blog post: https://veronicageek.com/office-365/sharepoint-online/split-data-into-2-columns-in-spo-using-powershell-pnp-and-use-power-automate-for-new-items/2019/11/
#>

#Connect to SPO
Connect-PnPOnline -Url "https://<TENANT-NAME>.sharepoint.com/sites/<SITE>"

#Store your list into a variable
$myList = Get-PnPList -Identity "<YOUR_LIST>"


#Get all items from the list + Store the results
$results = @()
$allItems = Get-PnPListItem -List $myList -Fields "FullName", "FirstName", "LastName"
foreach ($item in $allItems) {
    $splitFullName = $item["FullName"].Split(" ")
    $FirstNameSplit = $splitFullName[0]
    $LastNameSplit = $splitFullName[1]
    
    $results += [pscustomobject][ordered]@{
        FullName  = $item["FullName"]
        FirstName = $item["FirstName"]
        LastName  = $item["LastName"]
    }
    #Modify each current item in the list
    Set-PnPListItem -List "Clients" -Identity $item -Values @{"FirstName" = $FirstNameSplit; "LastName" = $LastNameSplit }
}
$results

