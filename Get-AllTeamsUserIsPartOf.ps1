# This script will retrieve all Teams a user is part of (including the role)
# MORE INFO on my Blog Post: https://veronicageek.com/powershell/powershell-for-o365/get-all-teams-a-user-is-part-of-using-powershell-pnp/2020/10/
####################################################################################################################################################

#Connect to Teams & Azure AD
Connect-PnPOnline -Scopes "Group.Read.All" -Credentials "<YOUR-CREDS-NAME>"
Connect-AzureAD -Credential (Get-PnPStoredCredential -Name "<YOUR-CREDS-NAME>" -Type PSCredential) | Out-Null

#Log file to export results
$logFile = "C:\users\$env:USERNAME\desktop\AllTeamsUserIn.csv"

#Store all the Teams 
$allTeams = Get-PnPTeamsTeam
$results = @()

$userToFind = "user123@domain.com"
$userToFindInAD = Get-AzureADUser | Where-Object ({ $_.UserPrincipalName -match $userToFind })
$userToFindID = $userToFindInAD.ObjectId


#Loop through the TEAMS
foreach ($team in $allTeams) {
    $allTeamsUsers = (Get-PnPTeamsUser -Team $team.DisplayName)
    
    #Loop through users TARGETING THE USER ID TO MATCH
    foreach ($teamUser in $allTeamsUsers) {
        if ($teamUser.Id -match $userToFindID) {
            
            $results += [pscustomobject]@{
                userName        = $userToFindInAD.UserPrincipalName
                userDisplayName = $userToFindInAD.DisplayName
                userRole        = $teamUser.UserType
                Team            = $team.DisplayName
                teamVisibility  = $team.Visibility
            }
        }    
    }
}
$results | Export-Csv -Path $logFile -NoTypeInformation

