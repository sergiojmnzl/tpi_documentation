function Add-JoinerFromUsersList {
    <#
        .SYNOPSIS
            Crée des utilisateurs dans Active Directory à partir d'une liste ou d'un fichier CSV, avec option de clonage depuis un utilisateur miroir.
        .PARAMETER Users
            Liste d'utilisateurs (ex: "user1,user2") ou chemin vers un fichier CSV.
        .PARAMETER Mirror
            (Optionnel) Utilisateur miroir à cloner.
        .EXAMPLE
            Add-JoinerFromUsersList -Users "user1,user2" -Mirror "userMirror"
            Add-JoinerFromUsersList -Users ".\file\path.csv"
    #>
    param (
        [Parameter(Mandatory = $true)][array]$Users,
        [Parameter(Mandatory = $false)][string]$Mirror
    )

    BEGIN {
        $currentDomain = (Get-ADDomain).Forest
        $currentLocation = Get-Location
        $passGenModule = ".\modules\tasks\TPI_TSK_ShortTools.psm1"
        $isMirror = [bool]$Mirror
    }

    PROCESS {
        if ($isMirror) {
            # --- Mode miroir : création à partir d'un utilisateur modèle ---
            $mirrorData = Get-ADUserBasicData -User $Mirror
            if (-not $mirrorData.Exists) {
                Write-Host -ForegroundColor Red "L'utilisateur miroir n'existe pas dans l'AD."
                return
            }
            $userList = if ($Users -is [string] -and $Users -match ",") { $Users -split "," } else { Get-Content -Path $Users | Where-Object { $_ -ne "" } }
            foreach ($user in $userList) {
                $parts = $user -split ' '
                if ($parts.Count -lt 2) { Write-Host -ForegroundColor Yellow "Format invalide pour '$user' (prénom nom attendu)"; continue }
                $firstName = $parts[0]
                $lastName  = $parts[1]
                $samAccount = Use-TextResizer -Label (Convert-AnyText2Normal -Text "$firstName.$lastName") -Width 20 -Last "Ignore"
                $upn = Convert-AnyText2Normal -Text "$firstName.$lastName@$currentDomain"
                $password = powershell -ExecutionPolicy Bypass -Command "& { Set-Location '$currentLocation'; Import-Module '$passGenModule' ; Use-RandomPassGenerator}"
                $userData = @{
                    Name               = "$firstName $lastName"
                    GivenName          = $firstName
                    Surname            = $lastName
                    SamAccountName     = $samAccount
                    UserPrincipalName  = $upn
                    Path               = $mirrorData.UserOU
                    AccountPassword    = $password
                    Enabled            = $true
                    EmailAddress       = $upn
                    Manager            = $mirrorData.Manager
                    DisplayName        = "$firstName $lastName"
                }
                if ((Get-ADUserBasicData -User $samAccount).Exists) {
                    Write-Host -ForegroundColor Red "Utilisateur '$samAccount' déjà existant, ignoré."
                    continue
                }
                New-ADUser @userData
                Write-Host -ForegroundColor Green "Utilisateur '$samAccount' créé avec succès."
            }
        } else {
            # --- Mode CSV : création à partir d'un fichier ---
            if (-not (Test-Path $Users)) {
                Write-Host -ForegroundColor Red "Le fichier '$Users' n'existe pas."
                return
            }
            try {
                $csvUsers = Import-Csv -Path $Users -Delimiter ";" | Where-Object { $_.Prenom -or $_.Nom }
            } catch {
                Write-Host -ForegroundColor Red "Erreur lors de l'importation du fichier CSV."
                return
            }
            foreach ($row in $csvUsers) {
                $firstName = $row.Prenom
                $lastName  = $row.Nom
                if (-not ($firstName -or $lastName)) { continue }
                $fullName  = "$firstName $lastName".Trim()
                $samAccount = Use-TextResizer -Label (Convert-AnyText2Normal -Text "$firstName.$lastName") -Width 20 -Last "Ignore"
                $upn = Convert-AnyText2Normal -Text "$firstName.$lastName@$currentDomain"
                $email = if ($row.Messagerie) { $row.Messagerie } else { $upn }
                $manager = if ($row.Manager) { (Get-ADUserBasicData -User $row.Manager).Name } else { $null }
                $userData = @{
                    Name               = $fullName
                    GivenName          = $firstName
                    Surname            = $lastName
                    SamAccountName     = $samAccount
                    UserPrincipalName  = $upn
                    Path               = $row.OU
                    AccountPassword    = powershell -ExecutionPolicy Bypass -Command "& { Set-Location '$currentLocation'; Import-Module '$passGenModule' ; Use-RandomPassGenerator}"
                    Enabled            = if ($row.Active -eq "no") { $false } else { $true }
                    EmailAddress       = $email
                    Description        = $row.Description
                    Title              = $row.Poste
                    Department         = $row.Departement
                    City               = $row.Ville
                    OfficePhone        = $row.Teléphone
                    Manager            = $manager
                    DisplayName        = $fullName
                }
                if ((Get-ADUserBasicData -User $samAccount).Exists) {
                    Write-Host -ForegroundColor Red "Utilisateur '$samAccount' déjà existant, ignoré."
                    continue
                }
                New-ADUser @userData
                Write-Host -ForegroundColor Green "Utilisateur '$samAccount' créé avec succès."
            }
        }
    }
    END {
        Write-Host -ForegroundColor Cyan "Traitement terminé."
    }
}
#Add-JoinerFromUsersList