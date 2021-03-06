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
[cmdletbinding()]
Param($ServerHostname='.')

process{

	$Services	= Get-WmiObject -Class win32_service -computername $ServerHostname -Filter "NOT StartMode='Disabled'" -Property "DisplayName,Description,Name,State,StartMode,StartName" | `
					select DisplayName,Description,Name,State,StartMode,StartName

	$Output = foreach($Service in $Services){
        $ServiceInfo = New-Object Object
        $ServiceInfo | Add-Member -MemberType NoteProperty -Name DisplayName -Value $Service.DisplayName
        $ServiceInfo | Add-Member -MemberType NoteProperty -Name Description -Value $Service.Description
        $ServiceInfo | Add-Member -MemberType NoteProperty -Name Name -Value $Service.Name
        $ServiceInfo | Add-Member -MemberType NoteProperty -Name State -Value $Service.State
        $ServiceInfo | Add-Member -MemberType NoteProperty -Name StartMode -Value $Service.StartMode
        $ServiceInfo | Add-Member -MemberType NoteProperty -Name StartName -Value $Service.StartName
        $ServiceInfo
	}

	# Collect errors and return result
    $OperatingSystem = Get-WmiObject -ComputerName $ServerHostname -Class Win32_OperatingSystem
    $ComputerName    = $OperatingSystem.__Server.ToString().ToUpper()
	if($Output) {
		$Output = $Output | Select-Object @{n='Hostname';e={$ComputerName}},*
	}else{
		$Output = $null
	}
	$Result = @{
		Errors = $Error
		Result = $Output
	}

	# Return result as an object
	New-Object PSObject -Property $Result

}
