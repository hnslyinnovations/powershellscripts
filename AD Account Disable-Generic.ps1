## Sets window size of Powershell
function Set-WindowSize {
Param([int]$x=$host.ui.rawui.windowsize.width,
      [int]$y=$host.ui.rawui.windowsize.heigth)

    $size=New-Object System.Management.Automation.Host.Size($x,$y)
    $host.ui.rawui.windowsize=$size   
}

function StartProgram
{
    Write-Host "`n/*************************************************\"
    Write-Host "       Active Directory User Disable Script"
    Write-Host "    Created by Trevor Hensley :: Used for *Company*"
    Write-Host "\*************************************************/`n"
    GetUserInfo
}

## Reads information from user input -> Checks accounts is found within AD
function GetUserInfo
{
    $GLOBAL:AccountName = Read-Host -Prompt 'Input the user account name or type exit'
	Write-Host "Checking to see if username exists"
	
    ##Comparing username verse what is found in AD
    $UserCheck = [bool] (Get-ADUser -Filter {samAccountName -like $AccountName})
    Invoke-Expression "Write-Host Usercheck returns: $UserCheck"
    IF ($UserCheck -eq $True){
		Write-Host "Username does exist in AD"
        DisableStatus
	}
    ELSEIF ($AccountName -eq "Exit" -eq "exit"){
        Write-Host "Exiting program"
        Start-Sleep -s 3
        Exit
    }
    ELSEIF ($UserCheck -eq $False -or $UserAccount -ne "Exit" -ne "exit"){
        Write-Host "Username does not exist" -ForegroundColor RED
        Write-Host "Please try another username"
        Invoke-Expression "Write-Host Attempted with the username: $AccountName"
        GetUserInfo
    }
}

## Function checks status of Lockout on account
function DisableStatus
{   
    Write-Host "Checking disabled status of account"
    $GLOBAL:DisabledCheck = (Get-ADUser $AccountName -Properties Enabled | Select-Object -ExpandProperty Enabled)
    Invoke-Expression "Write-Host Disabled check returns: $DisabledCheck"
    IF ($DisabledCheck -eq $True){
        Write-Host "User is not disabled - Proceeding with request" -ForegroundColor RED
        DisableADAccount
    }
        ELSEIF ($DisabledCheck -eq $False){
        Write-Host "User is currently disabled" -ForegroundColor RED
        Start-Sleep -s 3
        ReAttemptDisable
    }

}

## Function Unlocks AD Account 
function DisableADAccount
{
    Disable-ADAccount -Identity $AccountName -Confirm
    Write-Host "Disabled account successfully" -ForegroundColor RED
    Write-Host "Writing disabled description date on AD account" -ForegroundColor RED
    $ADUserDescription = Get-ADUser $AccountName -Properties Description
    Set-ADUser $ADUserDescription -Description "$($ADUserDescription.Description) (Disabled $(Get-Date))"
    Write-Host "Moving user account to disabled OU" -ForegroundColor RED
    $AccountDN = Get-ADUser $AccountName -Properties DistinguishedName
    Invoke-Expression "Write-Host DistinguishedName returns: $AccountDN"
##   Move-ADObject -Identity $($AccountDN.DistinguishedName) -TargetPath "SET PATH HERE"
    Write-Host "Exiting program"
    Start-Sleep -s 2
    ReAttemptDisable
}

function ReAttemptDisable
{
    $GLOBAL:ReattemptCheck = Read-Host -Prompt "Is there another account to be disabled (Yes/Exit)? "
    IF ($ReattemptCheck -eq "Yes" -eq "yes"){
		Write-Host "Reloading account disable program"
        GetUserInfo
	}
    ELSEIF ($ReattemptCheck -eq "Exit" -eq "exit"){
        Write-Host "Exiting program" -ForegroundColor RED
        Start-Sleep -s 3
        Exit
    }
    ELSE
    {
        Write-Host "Please enter correct entry"
        ReAttemptDisable
    }
}

Set-WindowSize 70 25
StartProgram

