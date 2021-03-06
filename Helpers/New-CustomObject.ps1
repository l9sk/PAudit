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
# NAME:         New-CustomObject.ps1
# AUTHOR:       Liam Glanfield
# CREATED DATE: 26/11/2015
# CHANGED DATE: 26/11/2015
# VERSION:      1.0.0
# DESCRIPTION:  Creates a new custom object from hash table and optionally trims white space from values if asked

Function Global:New-CustomObject {
	Param([System.Collections.Hashtable]$HashTable,[switch]$TrimStringValues)

	# Create a new hash table
	$CleanHash = New-Object -TypeName System.Collections.Hashtable

	# Check if given hash table has results
	if($HashTable.Count -gt 0) {

		# Loop through each hash table key/name
		Foreach($Key IN $HashTable.Keys){

			# if the value is a string and trim is enabled trim leading and trailing space
			if($TrimStringValues -eq $true -and $HashTable[$Key] -is [string]){
				$CleanHash.Add($Key,$HashTable[$Key].Trim())
			}else{
				$CleanHash.Add($Key,$HashTable[$Key])
			}

		}

		# Take cleaned hash table and pass to object for output
		New-Object -TypeName psobject -Property $CleanHash

	}else{
		# No values in the hash table return null
		return $null
	}

}
