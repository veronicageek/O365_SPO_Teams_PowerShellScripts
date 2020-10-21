## This script will change the user's ODFB storage quota and quota warning using the CSV file YOU provide, and export the users having issues.
## MORE INFO ON MY BLOG POST: https://veronicageek.com/microsoft-365/onedrive-for-business/change-specific-users-onedrive-for-business-default-storage-quota-using-powershell-pnp-with-error-handling-for-different-outcomes/2020/10/
########################################################################################################################

#Connect to SPO
Connect-PnPOnline -Url "https://<TENANT-NAME>-admin.sharepoint.com"

#Import CSV file with usernames
$usernames = Import-Csv -Path "<YOUR-CSV-FILEPATH>"

#Results for storing the users not found (or not provisioned)
$results = @()
$logFile = "C:\users\$env:USERNAME\Desktop\usersNotFound.csv"

#Script
foreach($user in $usernames){
    try{
        Set-PnPUserOneDriveQuota -Account $user.username -Quota $user.newQuota -QuotaWarning $user.newWarning -ErrorAction Stop | Out-Null
    }
    
    catch [Microsoft.SharePoint.Client.ServerException] {
        Write-Host "User not found: $($user.username)" -ForegroundColor Cyan
        Write-Warning $error[0]
        
        if ($error[0].Exception -like "*Unknown Error*"){
            $results += [pscustomobject]@{
                userNotFound        = $user.username
                ODFBProvisioned  = "No"
                userInTenant     = "Yes"
            }
        }
        else {
            $results += [pscustomobject]@{
                userNotFound    = $user.username
                ODFBProvisioned = "N/A"
                userInTenant    = "No"
            }
        }
    }
}
$results | Export-Csv -Path $logFile -NoTypeInformation
