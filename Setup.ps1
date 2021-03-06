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


$PAuditPath = Join-Path $PSScriptRoot PAudit.ps1
$Action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-File $PAuditPath"
$Trigger = New-ScheduledTaskTrigger -Daily -At (Get-Date -Hour 6 -Minute 0 -Second 0 -Millisecond 0)
$User = Join-Path $ENV:USERDOMAIN 'PAudit-Service'
$Creds = Get-Credential -Message 'Please enter the PAudit service account credentials' -UserName $User
$Setting = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew
$CreatedTask = Register-ScheduledTask -TaskPath PAudit -TaskName 'PAudit Daily Run' -RunLevel Highest -Password $Creds.GetNetworkCredential().Password -User $Creds.GetNetworkCredential().UserName -Trigger $Trigger -Settings $Setting -Description 'PAudit Daily Run' -Action $Action
$CreatedTask | Start-ScheduledTask

Write-Host 'PAudit has been setup and is now doing a first run!' -ForegroundColor Green


