<#PSScriptInfo

.VERSION 0.0

.GUID e7172940-4e12-425e-9e65-c7ab1b2ffc1f

.AUTHOR David Walker, Sitecore Dave, Radical Dave

.COMPANYNAME David Walker, Sitecore Dave, Radical Dave

.COPYRIGHT David Walker, Sitecore Dave, Radical Dave

.TAGS powershell script

.LICENSEURI https://github.com/Radical-Dave/Set-InstallScriptDirectories/blob/main/LICENSE

.PROJECTURI https://github.com/Radical-Dave/Set-InstallScriptDirectories

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


#>

<#
.SYNOPSIS
@@synoposis@@

.DESCRIPTION
@@description@@

.EXAMPLE
PS> .\Set-InstallScriptDirectories

.Link
https://github.com/Radical-Dave/Set-InstallScriptDirectories

.OUTPUTS
    System.String
#>
#####################################################
# Set-InstallScriptDirectories
#####################################################
[CmdletBinding(SupportsShouldProcess,PositionalBinding=$false)]
Param(
	# future usage
	[Parameter(Mandatory=$false)] [string]$Scope = '',
    # Force - overwrite if index already exists
    [Parameter(Mandatory=$false)] [switch]$Force = $false
)
begin {
	$ErrorActionPreference = 'Stop'
	$PSScriptName = $MyInvocation.MyCommand.Name.Replace(".ps1","")
}
process {	
	Write-Verbose "$PSScriptName $name $template start"
    if($PSCmdlet.ShouldProcess($name)) {
    Write-Verbose -vb "Adding Install-Script install directories to `$env:PATH..."

    $isWin = $env:OS -eq 'Windows_NT'
    $isAdmin = if ($isWin) { [bool] (net session 2>$null) } else { 0 -eq (id -u) }

    $ErrorActionPreference = 'Stop'

    # Determine the locations: current-user, all-user.
    $scriptDirs = (Join-Path (Split-Path ($PROFILE, "$HOME/.local/share/powershell/Modules")[$env:OS -ne 'Windows_NT']) Scripts),
            (Join-Path (Split-Path ("$env:ProgramFiles\$(if ($PSVersionTable.PSEdition -ne 'Core') { 'Windows' })PowerShell\Modules", '/usr/local/share/powershell/Modules')[$env:OS -ne 'Windows_NT']) Scripts)

    if (-not $isWin) {
    # Note: There's no unified mechanism across macOS and Linux.
    Write-Warning "On Unix, this script only supports modifying the *current session*'s `$env:PATH variable."
    } elseif (-not $isAdmin) {
    Write-Warning "Since this session isn't elevated, only the *current-user* location will be added *persistently*."
    }

    $pathVarSep = [IO.Path]::PathSeparator

    $i = 0
    foreach ($dir in $scriptDirs) {
    # Always update the in-session variable.
    Write-Verbose -vb "-- Adding $dir..."
    if ($env:PATH -split $pathVarSep -notcontains $dir) { 
    $env:PATH = ($env:PATH -replace "$pathVarSep`$") + $pathVarSep + $dir 
    } 
    else { 
    Write-Verbose -vb "Already present in-session: $dir" 
    }
    # On Windows, also try to update the *persistent* definitions
    if ($isWin) {
    $scope = ('User', 'Machine')[$i++ -eq 1]
    if ($scope -eq 'Machine' -and -not $isAdmin) { break } # skip due to lack of permissions
    # Note: We query the registry directly, so as to preserve unexpanded REG_EXPAND_SZ values.
    $currVal = Get-ItemPropertyValue ('registry::HKEY_CURRENT_USER\Environment', 'registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment')[$scope -eq 'Machine'] Path
    if ($currVal -split $pathVarSep -notcontains $dir) { 
    [Environment]::SetEnvironmentVariable('Path', (($currVal -replace "$pathVarSep`$") + $pathVarSep + $dir), $scope)
    } else {
    Write-Verbose -vb "Already present persistently in the $scope scope: $dir"
    }
    }
    }

    Write-Verbose -vb 'Done.'

    }
    Write-Verbose "$PSScriptName $name end"
    #if ($PersistForCurrentUser) { Set-Location $path }
    return $path
}