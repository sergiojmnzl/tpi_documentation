function Get-ADUserBasicData {
<#
    .NOTES
        Auteur : Sergio Jimenez
        Date : 07 Mai 2025
        version : 1.0
        
    .SYNOPSIS
        Retrouve les informations de base d'un User AD.
    .DESCRIPTION
        Cette fonction permet de vérifier si un utilisateur existe dans Active Directory en fonction de son adresse e-mail ou de son nom d'utilisateur.
        Elle retourne un objet contenant des informations sur l'utilisateur, y compris son existence, son chemin d'OU et son nom d'utilisateur.
    .PARAMETER User
        L'adresse e-mail ou le nom d'utilisateur de l'utilisateur à vérifier.
    .EXAMPLE
        Get-ADUserBasicData -User "monUser"
    .EXAMPLE
        Get-ADUserBasicData -User "monUser@example.ch"
    .OUTPUTS
        Trois resultats son attendus:
        1. .Exists $true/$false si l'utilisateur existe ou pas
        2. .OU  le chemin de l'utilisateur dans l'AD
        3. .Name le nom de l'utilisateur dans l'AD
        4. .Email l'adresse email de l'utilisateur dans l'AD
        5. .Manager, s'il esxise le manager de l'utilisateur dans l'AD
    .LINK
        https://github.com/sergiojmnzl
#>

    param (
        [Parameter(Mandatory=$true)][array]$Users # requier une adresse email

    )
    # Declaration des et des valeurs par defaut
    $uxtUsers = $Users
    $uxtDoesUserExist = $false 
    $uxtUserData = $null
    $uxtUserOU = $null
    $uxtUserDataProcessed = @()
    $uxtRequirement = "^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$"

    foreach ($uxtUser in $uxtUsers){
        # Validation du format UPN (adresse email)
        try { 
            if ($uxtUser -match $uxtRequirement) {
                Write-Host -ForegroundColor Yellow "Identifiant au format UPN"
                $uxtUserData = Get-ADUser -Filter {EmailAddress -eq $uxtUser} -Properties DistinguishedName, Manager, MemberOf -ErrorAction SilentlyContinue
                if (-not $uxtUserData) {
                    $uxtUserData = Get-ADUser -Filter {UserPrincipalName -eq $uxtUser} -Properties DistinguishedName, Manager, MemberOf -ErrorAction SilentlyContinue
                }
            # Validation du format SAN (nom d'utilisateur)
            }elseif ($uxtUser -notmatch $uxtRequirement) {
                Write-Host -ForegroundColor Yellow "Identifiant au format SAN"
                $uxtUserData = Get-ADUser -Identity $uxtUser -Properties DistinguishedName, Manager, MemberOf -ErrorAction SilentlyContinue
            } else {
                Write-Host -ForegroundColor Red "L'adresse email fournie n'est pas valide."
            }
        }
        catch {
            Write-Host "Error: $_" -ForegroundColor Red
            $uxtUserData = $null
            $uxtDoesUserExist = $false
        }
        # Si l'utilisateur existe, on traite les données
        if ($uxtUserData) {
            $uxtDoesUserExist = $true
            Write-Host -ForegroundColor Green "L'utilisateur existe dans l'AD."
            # traimeent de l'OU de l'utilisateur
            $uxtUserOU = $uxtUserData.DistinguishedName -Replace '^.*?,(?=[A-Z]{2}=)'
        } else {
            Write-Host -ForegroundColor Red "L'utilisateur n'existe pas dans l'AD."
        }
        # Retour des valeur traitées
        $uxtUserDataProcessed += [PSCustomObject]@{
            User    = $uxtUser
            Exists  = $uxtDoesUserExist
            OU      = if ($uxtDoesUserExist) { $uxtUserOU } else {$null}
            Name    = if ($uxtDoesUserExist) { $uxtUserData.SamAccountName } else {$null}
            Email   = if ($uxtDoesUserExist) { $uxtUserData.UserPrincipalName } else {$null}
            Manager = if ($uxtDoesUserExist) { $uxtUserData.Manager } else {$null}
            GUID    = if ($uxtDoesUserExist) { $uxtUserData.GUID } else {$null}
            FullOU  = if ($uxtDoesUserExist) { $uxtUserData.DistinguishedName } else {$null}
        }
    }
    return $uxtUserDataProcessed  
}
# Decommenter la ligne suivante pour tester le script
#Get-ADUserBasicData -User Standar.User,Bee.Admin,Morethan.Twentychrctr@beemusic.ch,Test