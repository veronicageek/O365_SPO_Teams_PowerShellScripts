<#
.SYNOPSIS
    Create custom permission level
.DESCRIPTION
    Create a custom permission level in SharePoint Online
.EXAMPLE
    PS C:\> .\Create-CustomPermissionLevel.ps1
    This will start the script and create a copy of the READ perm. level in the sites defined in your CSV file.
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    PLEASE REFER TO MY BLOG POST FOR MORE INFO ABOUT THE SCRIPT + ITS PURPOSE FOR YOUR BUSINESS NEEDS.
    https://veronicageek.com/office-365/sharepoint-online/create-custom-permissions-for-multiple-site-collections-in-spo-using-powershell-pnp/2019/05/
#>
#Connect to SPO admin center --> Change to your TENANT NAME
$creds = Get-Credential
Connect-PnPOnline -Url https://<TENANT_NAME>-admin.sharepoint.com -Credentials $creds

#Import sites from .csv --> Change to your filepath
$mySites = Import-Csv -Path 'YOUR_FILE_PATH_LOCATION'

#Create all for each site
foreach ($site in $mySites) {
    
    #Connect to each site
    Write-Host "Connecting to $($site.SiteUrl)" -ForegroundColor Green
    Connect-PnPOnline -Url $site.SiteUrl
    
    #Create the NEW permission level (clone the 'READ' default permissions)
    $PermToClone = Get-PnPRoleDefinition -Identity "Read"
    $addPnPRoleDefinitionSplat = @{
        Include     = 'ManagePersonalViews', 'UpdatePersonalWebParts', 'AddDelPrivateWebParts'
        Description = "Copy of Read + Personal Permissions"
        RoleName    = "myCustomPermLevel"
        Clone       = $PermToClone
    }
    Add-PnPRoleDefinition @addPnPRoleDefinitionSplat
}