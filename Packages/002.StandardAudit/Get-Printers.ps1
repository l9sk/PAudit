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
# NAME:         Get-Printers.ps1
# AUTHOR:       Liam Glanfield
# CREATED DATE: 18/11/2015
# CHANGED DATE: 18/11/2015
# VERSION:      1.0.0
# DESCRIPTION:  Collects local printer information from WMI

# Error handling
$ErrorActionPreference = 'SilentlyContinue'
$Errors = @()
$Error.Clear()

#region Start collecting data

$Output = Get-WMIObject Win32_Printer | ForEach-Object {
	$Printer = $_
	$Result = New-Object PSObject
	$Result | Add-Member NoteProperty Name $Printer.Name
	$Result | Add-Member NoteProperty Location $Printer.Location
	$Result | Add-Member NoteProperty Comment $Printer.Comment
	$Result | Add-Member NoteProperty PortName $Printer.PortName
				
	$Ports = Get-WmiObject Win32_TcpIpPrinterPort
	$PResults = @()
	foreach ($Port in $Ports)
	{
		if ($Port.Name -eq $Printer.PortName)
		{
			$PResults += $Port.HostAddress
		}
	}
	$Result | Add-Member NoteProperty HostAddress ($PResults -join ';')
	$Result | Add-Member NoteProperty DriverName $Printer.DriverName
	$Result | Add-Member NoteProperty Shared $Printer.Shared
	$Result | Add-Member NoteProperty ShareName $Printer.ShareName
	$Result
}

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
