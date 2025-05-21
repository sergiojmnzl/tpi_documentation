function Start-ADDeactivatedUsersReview {
    <#
        .NOTES
            Auteur : Sergio Jimenez
            Date : 14 Mai 2025
            version : 2.0
        .SYNOPSIS
            Review des comptes inactifs avec une option de suppression
        .DESCRIPTION
            Cette fonction permet de passer en revue les comptes inactifs dans Active Directory. 
            Elle recherche les comptes inactifs, affiche une liste et propose des options pour supprimer ou saisir manuellement des comptes à supprimer.
            Elle utilise la fonction Show-OptionsMenuToSelect pour afficher un menu d'options à l'utilisateur.
            La fonction utilise également la fonction Use-TextResizer pour formater les noms d'utilisateur et les afficher de manière lisible.
            La fonction utilise la fonction Confirm-AlwaysReadHost pour demander à l'utilisateur de saisir une liste de comptes à supprimer manuellement.
            Elle ne contient pas de paramètres d'entrée, mais elle utilise des variables internes pour stocker les informations sur les comptes inactifs.
        
            Variables Importantes:
            $rewListUsersToReview : Liste des comptes inactifs trouvés dans AD
            $rewReviewdUserList : Liste des comptes inactifs avec des informations sur le nom complet, le nom de compte, la date du dernier changement de mot de passe et l'état de verrouillage.
            $rewValidSingleUser : Informations sur un compte inactif spécifique

            Fonctions Utilisés:
            - Use-TextResizer
            - Search-ADAccount
            - Get-ADUser
            - Show-OptionsMenuToSelect
            - Confirm-AlwaysReadHost
            - Remove-ADUser
        .EXAMPLE
            Start-ADDeactivatedUsersReview
            Cette commande exécute la fonction Start-ADDeactivatedUsersReview
        .OUTPUTS
            La fonction renvoie le liste des comptes inactifs trouvés dans AD. Avec des in formations sur le nom complet, le nom de compte, la date du dernier changement de mot de passe et l'état de verrouillage.
            Cette liste est stoké dan la variable $rewReviewdUserList et au moment de l'affichage, elle est triée par nom complet dans un ordre croissant (A-Z).
        .LINK
    #>

    # Declaration des variables
    $rewReviewdUserList = @()

    Write-Host -ForegroundColor Cyan  "Recherche des comptes inactifs" -NoNewline
    Start-Sleep -Seconds 1 ; Write-Host -ForegroundColor Yellow "." -NoNewline
    Start-Sleep -Seconds 0.8 ; Write-Host -ForegroundColor Yellow "." -NoNewline
    Start-Sleep -Seconds 0.6 ; Write-Host -ForegroundColor Yellow ".`t" -NoNewline
    try {
        $rewListUsersToReview = (Search-ADAccount -UsersOnly -AccountDisabled | Where-Object {$_.WhenChanged -lt ((Get-Date).AddMonths(-3))}).SamAccountName
    } catch {
        $rewListUsersToReview = $null
    }
    if ($null -ne $rewListUsersToReview) {
        Write-Host -ForegroundColor Green "Comptes inactifs trouvés"
            foreach ($rewSingleUser in $rewListUsersToReview) {
                $rewValidSingleUser = Get-ADUser -Identity $rewSingleUser -Properties PasswordLastSet,LockedOut | Select-Object Name, SamAccountName, PasswordLastSet, LockedOut
                $rewReviewdUserList += [PSCustomObject]@{
                    "Nom Complet"                   = Use-TextResizer -label $rewValidSingleUser.Name -Width 30
                    "Compte"                        = $rewValidSingleUser.SamAccountName 
                    "Dernier changemenet de pass"   = $rewValidSingleUser.PasswordLastSet
                    "Compte bloqué?"                = $rewValidSingleUser.LockedOut
                }
            }
            Write-Host -ForegroundColor Yellow "Voici la liste des comptes inactifs:"
            $rewReviewdUserList  | Sort-Object -Property "Nom Complet" | Format-Table #On affiche la liste des comptes inactifs
            $rewReadyForReview = $true
        #Demander à l'utilisateur de confirmer la suppression des comptes
        if ($rewReadyForReview -eq $true) {
            #Liste des options
            $rewOption1 = "Supprimer"
            $rewOption2 = "Saisir manuellement"
            $rewOption3 = "Annuler"
            Write-Host -ForegroundColor Yellow "Attention: Si vous choisissez de supprimer, cela supprimera tous les comptes inactifs trouvés dans la liste ci-dessus."
            $rewOptionsList = @("$rewOption1", "$rewOption2", "$rewOption3")
            $rewValidOption = Show-OptionsMenuToSelect -Options $rewOptionsList
            # Execution de l'option choisie
            switch ($rewValidOption) {
                "$rewOption1" {
                    foreach ($rewSingleUser in $rewListUsersToReview){
                        Write-Host "Suppression de : " -NoNewline 
                        Write-Host -ForegroundColor Yellow (Use-TextResizer -label "$rewSingleUser" -Width 20) -NoNewline
                        try {
                            Remove-ADUser -Identity $rewSingleUser -Confirm:$false
                            Start-Sleep -Seconds 0.3
                            Write-Host -ForegroundColor Green "Success"
                        }
                        catch {
                            Write-Host -ForegroundColor Green "Success"
                        }
                    }
                }
                "$rewOption2" {
                    $rewNewListToReview = Confirm-AlwaysReadHost -Counts 3 -Message "Saisir le list separé par des virgules" -Thank "Merci!"
                    foreach ($rewSingleUser in $rewNewListToReview){
                        Write-Host "Suppression de : " -NoNewline 
                        Write-Host -ForegroundColor Yellow (Use-TextResizer -label "$rewSingleUser" -Width 20) -NoNewline
                        
                        try {
                            Remove-ADUser -Identity $rewSingleUser -Confirm:$false
                            Start-Sleep -Seconds 0.3
                            Write-Host -ForegroundColor Green "Success"
                        }
                        catch {
                            Write-Host -ForegroundColor Green "Error"
                        }
                    }
                }
                "$rewOption3" { return
                }
            }
        }
    } else {
        Write-Host -ForegroundColor Green "Aucun compte inactif trouvé"
        return
    }

}
#Start-ADDeactivatedUsersReview