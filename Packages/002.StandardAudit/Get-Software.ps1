<#
    This file is part of PAudit available from https://github.com/OneLogicalMyth/PAudit
    Created by Liam Glanfield @OneLogicalMyth

    PAudit is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    PAudit is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with PAudit.  If not, see <http://www.gnu.org/licenses/>.
#>
# NAME:         Get-Software.ps1
# AUTHOR:       Liam Glanfield
# CREATED DATE: 18/11/2015
# CHANGED DATE: 18/11/2015
# VERSION:      1.0.0
# DESCRIPTION:  Collects software information from registry

# Error handling
$ErrorActionPreference = 'SilentlyContinue'
$Errors = @()
$Error.Clear()

#region Start collecting data

function Sort-InstallDate {
param([string]$StringDate)

    $Y = $StringDate.Substring(0,4)
    $M = $StringDate.Substring(4,2)
    $D = $StringDate.Substring(6,2)
    [datetime]"$Y-$M-$D"

}

if((Test-Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall')){
    [string[]]$RootKeys      = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
}else{
    [string[]]$RootKeys      = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
}
$Output = Get-ItemProperty -Path $RootKeys | Where-Object {
	($_.DisplayName -notlike 'Security Update for Windows*' -AND
	$_.DisplayName -notlike 'Hotfix for Windows*' -AND
	$_.DisplayName -notlike 'Update for Windows*' -AND
	$_.DisplayName -notlike 'Update for Microsoft*' -AND
	$_.DisplayName -notlike 'Security Update for Microsoft*' -AND
	$_.DisplayName -notlike 'Hotfix for Microsoft*' -AND
    $_.PSChildName -notlike '*}.KB') } | Where-Object { $_.DisplayName -ne $null -AND $_.DisplayName -ne '' } |
Select-Object Publisher, DisplayName, DisplayVersion, @{n='InstallDate';e={Sort-InstallDate $_.InstallDate}}, InstallLocation, @{n='EstimatedSizeMB';e={[math]::Round($_.EstimatedSize / 1024,2)}}

#endregion

# Collect errors and return result
$System        = Get-WmiObject Win32_ComputerSystem
$LocalComputer = $System.DNSHostName + '.' + $System.Domain
if($Output) {
	$Output = $Output | Select-Object @{n='ComputerName';e={$LocalComputer}},*
}else{
	$Output = $null
}
$Result = @{
	Errors = $Error
	Result = $Output
}

# Return result as an object
New-Object PSObject -Property $Result
