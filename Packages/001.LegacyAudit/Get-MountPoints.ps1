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

	$MountPoints	= Get-WmiObject -ComputerName $ServerHostname -Class Win32_Volume -Filter "driveletter=NULL AND Capacity != NULL" -Property "name, label, capacity, freespace" | `
					select name, label, capacity, freespace | where{$_.name -notlike "\\?\Volume*"}

	#Mount points information
	if($MountPoints){
		$Output = foreach ($mountpoint in $MountPoints){
            $MPInfo = New-Object Object
            $MPInfo | Add-Member -MemberType NoteProperty -Name Label -Value $mountpoint.label
            $MPInfo | Add-Member -MemberType NoteProperty -Name Folder -Value $mountpoint.name
            $MPInfo | Add-Member -MemberType NoteProperty -Name Capacity -Value $mountpoint.capacity
            $MPInfo | Add-Member -MemberType NoteProperty -Name FreeSpace -Value $mountpoint.freespace
            $MPInfo
		}
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
