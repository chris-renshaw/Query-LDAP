<#
## LDAP Query Function ########################################
jointly written by Chris Renshaw and Justin Brazil
Created 05/25/15

Note - before you can run this script you will need to update 
certain settings in it to meet your infrastructure

## Outline of script ##########################################

* Select between User Objects or Computer Objects
* Choose between specified choices, lists, or eneter a specific OU to search
* Results returned to the $LDAP variable to be used outside of script

#> #############################################################
#TAGS LDAP,Query,Computers,Users,AD,OU,Domain,Active,Directory
#UNIVERSAL

function Query-LDAP {
    $global:Domain = Get-ADDomain
    [str]$global:DomainDistName = $Domain.DistinguishedName
    function LDAP-Menu{
        clear
        Write-Host "Select your target objects" -Foregroundcolor Green
        Write-Host "=========================="
        Write-Host
        Write-Host "1) Query Computer Objects"
        Write-Host "2) Query User Objects"
        Write-Host "3) Exit"
        Write-Host
        switch ($TYPESWITCH = Read-Host "Please make your selection [1-3]") {
            1{
                LDAP-Computers
            }
            2{
                LDAP-Users
            }
            3{
                Write-Host
                Write-Host "Goodbye" -Foregroundcolor Red
                Return
            }
            default{
                Write-Host
                Write-Host "Selection could not be determined" -Foregroundcolor Red
            }
        }
    }

    function LDAP-Computers {
        <#
        ## MODIFICATIONS ###########################################
        Note that if you'd like to add other custom Query choices 
        in the following function, make sure to add the menu option, 
        correct the numbering as applicable in the menu itself, 
        then add the appropriate switch selection. Ensure that you 
        keep the switch number consistent with the menu number.
        #> #########################################################

        $global:LDAP = ""
        
        clear
        Write-Host "Select your LDAP query" -Foregroundcolor Green
        Write-Host "======================" -Foregroundcolor Green
        Write-Host 'Results of this command are returned via the $LDAP variable' -Foregroundcolor Yellow
        Write-Host
        Write-Host "1) 'My Computers' OU"
        Write-Host "2) Domain Controllers OU"
        Write-Host "3) All Computers"
        Write-Host "======================" -Foregroundcolor Green
        Write-Host "4) Manual LDAP Query"
        Write-Host "5) Developer Mode"
        Write-Host "======================" -Foregroundcolor Green
        Write-Host "6) Exit"

        switch ($SELECTION = Read-Host "Select on option (1-6)") {
 
            1{
                $Searchbase = "OU=My Computers"+","+"$DomainDistName"
                $global:LDAP = Get-ADComputer -Searchbase $Searchbase -Filter *
            }
            2{
                $Searchbase = "OU=Domain Controllers"+","+"$DomainDistName"
                $global:LDAP = Get-ADComputer -Searchbase $Searchbase -Filter *
            }
            3{
                $global:LDAP = Get-ADComputer -Filter * -Searchbase "$DomainDistName"
            }
            4{
                Get-ADOrganizationalUnit -Filter 'Name -like "*"' | Format-List Name,DistinguishedName,ObjectClass 
                Write-Host "Copy the desired LDAP query like so:" -ForegroundColor Yellow
                Write-Host "OU=TestOU,DC=My,DC=Domain" -ForegroundColor Yellow
                $ManualLDAP = Read-Host "Paste your desired LDAP query here"
                $global:LDAP = Get-ADComputer -Filter * -SearchBase $ManualLDAP
                $global:LDAP.NAME
            }
            5{
                $global:LDAP = Get-ADComputer -Filter * -SearchBase "OU=TestOU,DC=My,DC=Domain"
            }
            6{
                Return
            }
                default{
                Write-Host "Invalid Selection" -ForegroundColor Red
            }
        }

        if ($Global:LDAP.count -gt 0){
            Write-Host
            Write-Host "===================" -ForegroundColor Green
            Write-Host "== QUERY RESULTS ==" -ForegroundColor Green
            Write-Host "===================" -ForegroundColor Green
            $global:LDAP.NAME
            Write-Host
            Write-Host 'Your results have been returned to the $LDAP variable' -ForegroundColor Green
        }
        else {
            Write-Host "No objects were returned from that OU.  Perhaps the objects have not been moved into this OU yet.  Please check Active Directory to confirm." -ForegroundColor Red
        }

    }

    function LDAP-Users {
        <#
        ## MODIFICATIONS ###########################################
        Note that if you'd like to add other custom Query choices 
        in the following function, make sure to add the menu option, 
        correct the numbering as applicable in the menu itself, 
        then add the appropriate switch selection. Ensure that you 
        keep the switch number consistent with the menu number.
        #> #########################################################

        clear
        Write-Host "Select your LDAP query" -Foregroundcolor Green
        Write-Host "======================"
        Write-Host 'Results of this command are returned via the $LDAP variable' -Foregroundcolor Yellow
        Write-Host
        Write-Host "1) All Users"
        Write-Host "2) All Administrators"
        Write-Host "3) Users by Group Membership"
        Write-Host "======================"
        Write-Host "4) Manual LDAP Query"
        Write-Host "======================"
        Write-Host "5) Exit"

        switch ($SELECTION = Read-Host "Select on option") {
            1{
                $global:LDAP = Get-ADUser -Filter * -SearchBase $global:DomainDistName
                $LDAP.Name
            }
            2{
                $global:LDAP = Get-ADGroup "Administrators" | Get-ADGroupMember
                $LDAP.Name
            }
            3{
                $OK = 0
                (Get-ADGroup -Filter *).Name
                while ($OK -eq 0) {
                    Write-Host
                    $GROUPQUERY = Read-Host "Please copy and paste the desired group into this prompt"
                    try {$global:LDAP = Get-ADGroupMember $GROUPQUERY 
                        $OK = 1
                    }
                    catch {Write-Host "Input Error - try again" -ForegroundColor Red}
                }
                $LDAP.Name
            }
            4{
                Get-ADOrganizationalUnit -Filter 'Name -like "*"' | Format-List Name,DistinguishedName,ObjectClass 
                Write-Host "Copy the desired LDAP query like so:" -ForegroundColor Yellow
                Write-Host "OU=TestOU,DC=My,DC=Domain" -ForegroundColor Yellow
                $ManualLDAP = Read-Host "Paste your desired LDAP query here"
                $global:LDAP = Get-ADUser -Filter * -SearchBase $ManualLDAP
            }
            5{
                Return
            }
            default{
                Write-Host "Invalid Selection" -ForegroundColor Red
            }
        }

        if ($Global:LDAP.count -gt 0){
            Write-Host
            Write-Host "===================" -ForegroundColor Green
            Write-Host "== QUERY RESULTS ==" -ForegroundColor Green
            Write-Host "===================" -ForegroundColor Green
            $global:LDAP.NAME
            Write-Host
            Write-Host 'Your results have been returned to the $LDAP variable' -ForegroundColor Green
        }
        else {
            Write-Host "No objects were returned from that OU.  Perhaps the objects have not been moved into this OU yet.  Please check Active Directory to confirm." -ForegroundColor Red
        }

    }

    ### Begin Script
    $global:LDAP = ""
    $SELECTION = ""
    Ldap-Menu
}
