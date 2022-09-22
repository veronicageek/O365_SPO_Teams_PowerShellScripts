<#
.SYNOPSIS
    Create a report for Microsoft Teams.
.DESCRIPTION
    This script will create a report for Microsoft Teams.   
.NOTES
    Make sure you have the correct permissions from a AzureAD app perspective, as well as the correct permissions from an M365/Teams admin perspective.
    This script is also using the "ImportExcel" module, which can be found here: https://www.powershellgallery.com/packages/ImportExcel/7.8.1
.EXAMPLE
    Get-MSTeamsReport -TenantName contoso
    This will generate a report for the tenant "contoso" and save it to the path specified in the $reportLocation variable (currently set to the user's Desktop).
#>

function Get-MSTeamsReport {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, HelpMessage="Your tenant name (e.g. contoso)")]
        [string]$TenantName
    )

    #Report placed onto the user's desktop
    $reportLocation = "C:\Users\$env:USERNAME\Desktop\"
    $startTime = Get-Date -Format MM-dd-yyyy-HH-mm-ss
    $TeamsDataFile = $reportLocation + "MSTeamsReport_$TenantName_$startTime.xlsx"

    #Get the MS Teams information
    Write-Host "Retrieving the information. Be patient..." -ForegroundColor Yellow

    $TeamsData = @() 
    $allTeams = Get-PnPTeamsTeam
    
    foreach($team in $allTeams){    
        $TeamsData += [pscustomobject][ordered] @{
            DisplayName = $team.DisplayName
            GroupId = $team.GroupId
            Owners = (Get-PnPTeamsUser -Team $team.GroupId -Role Owner).UserPrincipalName -Join ";"
            Visibility = $team.Visibility
            NbOfChannels = (Get-PnPTeamsChannel -Team $team.DisplayName).Count #Includes Private Channels!
            IsArchived = $team.IsArchived
        }
    }

    #Creating the workbook in a variable called "$myWorkbook"
    $myWorkbook = $TeamsData | Export-Excel -Path $TeamsDataFile -WorksheetName "TeamsReportData" -AutoSize -AutoFilter -BoldTopRow -FreezeTopRow -PassThru
    
    #Formatting the "NbOfChannels" with RED bkgrd if >= 100
    $TeamsDataWS = $myWorkbook.Workbook.Worksheets["TeamsReportData"]
    Set-Format -WorkSheet $TeamsDataWS -Range "E2:E550000" -NumberFormat "0" -AutoFit
    Add-ConditionalFormatting -WorkSheet $TeamsDataWS -Range "E2:E550000" -RuleType GreaterThanOrEqual -ConditionValue '100' -ForeGroundColor White -BackgroundColor "Red"
    Set-CellStyle -WorkSheet $TeamsDataWS -LastColumn 1 -Pattern Solid -Color LightGray

    #Exporting the data
    Export-Excel -ExcelPackage $myWorkbook -Show 
    
    Write-Host "Report created : $TeamsDataFile" -ForegroundColor Cyan
}

#Run the function
Get-MSTeamsReport -TenantName contoso
