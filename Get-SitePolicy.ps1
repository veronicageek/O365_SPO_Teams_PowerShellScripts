<#
.SYNOPSIS
    Get site policies in SharePoint Online.
.DESCRIPTION
    Get all the site policies for each site collections in SharePoint Online.
.EXAMPLE
    PS C:\> .\Get-SitePolicy.ps1
    This command will retrieve all the site policies for each site collections on the tenant (access to the site collection required)
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    More detail on my blog post: https://veronicageek.com/sharepoint/sharepoint-2013/retrieve-site-policies-in-sharepoint-online-using-powershell-pnp/2018/08/
#>
#Connect to SPO (creds in the Credential Manager)
Connect-PnPOnline -Url "https://<TENANT-NAME>-admin.sharepoint.com"

#Get all the site policies
$Results = @()
$AllSC = Get-PnPTenantSite

foreach ($sc in $AllSC) {
    Write-Host "Connecting to" $sc.Url -ForegroundColor Green
    Try {    
        Connect-PnPOnline -Url ($sc).Url -Credentials $creds -ErrorAction Stop
        $Policy = Get-PnPSitePolicy
        $SCProps = @{
            Url         = $sc.Url
            Name        = $Policy.Name
            Description = $Policy.Description
        }
        $Results += New-Object PSObject -Property $SCProps
    } 
    catch {
        Write-Host "You don't have access to this Site Collection" -ForegroundColor Red
    }
    
} #end foreach
$Results | Select-Object Url, Name, Description
