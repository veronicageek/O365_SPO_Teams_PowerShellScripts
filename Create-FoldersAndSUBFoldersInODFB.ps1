<#
.Synopsis
   This script will create 2 folders + 2 sub-folders into each users' ODFB provided in a CSV file.
.DESCRIPTION
   This script will create 2 folders + 2 sub-folders into each users' ODFB provided in a CSV file and will be called FOLDER1 and FOLDER2, but you can add more if wanted.

   +++ PRE-REQUISITES +++   
        >> The .CSV file needs to contain a column with header titled "UserPrincipalName" 
        >> SharePoint Online SDK Components and SPO Management Shell installed on the machine running the script
        >> The account provided in the variable $AdminAccount needs to be added as Site Collection Admin to each ODFB PRIOR to running this script (in order to have permission to create the folders)

.EXAMPLE
   .\Create-FoldersAndSUBFoldersInODFB.ps1 -AdminAccount <admin@domain.com> -SPOAcct <SCA_on_ODFB> -TenantName <Name_of_the_O365_Tenant> -CsvFileLocation <CsvFile_Location> 
.EXAMPLE
   .\Create-FoldersAndSUBFoldersInODFB.ps1 (if no parameters are entered, you will be prompted for them)

==========================================
Author: Veronique Lengelle (@VeronicaGeek)
Date: 03 Jan 2017 
Version: 1.0
==========================================
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true,HelpMessage="This is the Admin account to connect to SPO to run the script",Position=1)] 
    [string]$AdminAcct,   
	[Parameter(Mandatory=$true,HelpMessage="This is the Admin account added as a SCA on each ODFB",Position=2)] 
    [string]$SPOAcct,    
    [Parameter(Mandatory=$true,HelpMessage="This is the O365 tenant name",Position=3)] 
    [string]$TenantName,
    [Parameter(Mandatory=$true,HelpMessage="This is the location of the CSV file containing all the users",Position=4)] 
    [string]$CsvFileLocation
)
#Script started at
$startTime = "{0:G}" -f (Get-date)
Write-Host "*** Script started on $startTime ***" -f White -b DarkYellow

#Loading assemblies
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime")
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.UserProfiles")

#Declare Variables
$Password = Read-Host -Prompt "Please enter your O365 Admin password" -AsSecureString
$Users = Import-Csv -Path $CsvFileLocation


ForEach ($User in $Users) {
	$creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($AdminAcct,$Password)
			
	#Split UPN in 2 parts
	$SplitUPN = ($User.UserPrincipalName).IndexOf("@")
	$Left = ($User.UserPrincipalName).Substring(0, $SplitUPN)
	$Right = ($User.UserPrincipalName).Substring($SplitUPN+1)

	#Get the username without the @domain.com part
	$shortUserName = ($User.UserPrincipalName) -replace "@"+$Right
			
	#Modify the UPN to replace dot by underscore to match perso URL
	$ShortUPNUnderscore = $shortUserName.Replace(".","_")

    Write-Host "** Creating folders for"$user.UserPrincipalName -f Yellow

	#Transform domain with underscore to match perso URL
	$DomainUnderscore = $Right.Replace(".", "_")

	#Use the $shortUsername to build the full path
	$spoOD4BUrl = ("https://$TenantName-my.sharepoint.com/personal/"+ $ShortUPNUnderscore +  "_"+ $DomainUnderscore)
	Write-Host ("URL is: " + $spoOD4BUrl) -f Gray

	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($spoOD4BUrl)
	$ctx.RequestTimeout = 16384000
	$ctx.Credentials = $creds
	$ctx.ExecuteQuery()
	
	$web = $ctx.Web
	$ctx.Load($web)
	
	#Target the Document library in user's ODFB
	$spoDocLibName = "Documents"
	$spoList = $web.Lists.GetByTitle($spoDocLibName)
	$ctx.Load($spoList.RootFolder)
	
	#Create FOLDER1
	$spoFolder = $spoList.RootFolder
    $Folder1 = "FOLDER1"
	$newFolder = $spoFolder.Folders.Add($Folder1)
	$web.Context.Load($newFolder)
	$web.Context.ExecuteQuery()

        #Create 2x SUB-Folders in FOLDER1
        $SubFolder1 = "SubFolder1"
        $newSubFolder1 = $newFolder.Folders.Add($SubFolder1)
        $web.Context.Load($newSubFolder1)
	    $web.Context.ExecuteQuery()

        $SubFolder2 = "SubFolder2"
        $newSubFolder2 = $newFolder.Folders.Add($SubFolder2)
        $web.Context.Load($newSubFolder2)
	    $web.Context.ExecuteQuery()


    #Create FOLDER2 
	$Folder2 = "FOLDER2"
	$newFolder2 = $spoFolder.Folders.Add($Folder2)
	$web.Context.Load($newFolder2)
	$web.Context.ExecuteQuery()
   

        #Create 2x SUB-Folders in FOLDER2
        $SubFolder3 = "SubFolder3"
        $newSubFolder3 = $newFolder2.Folders.Add($SubFolder3)
        $web.Context.Load($newSubFolder3)
	    $web.Context.ExecuteQuery()

        $SubFolder4 = "SubFolder4"
        $newSubFolder4 = $newFolder2.Folders.Add($SubFolder4)
        $web.Context.Load($newSubFolder4)
	    $web.Context.ExecuteQuery()
}

Write-Host "Folders created " -f Green

#Script finished at
$endTime = "{0:G}" -f (Get-date)
Write-Host "*** Script finished on $endTime ***" -f White -b DarkYellow
Write-Host "Time elapsed: $(New-Timespan $startTime $endTime)" -f White -b DarkRed

