function Suspend-ADUsersFromList {
    <#
        .NOTES
            Auteur : Sergio Jimenez
            Date : 14 Mai 2025
            version : 2.0
        .SYNOPSIS
            Suspendre les utilisateurs d'Active Directory à partir d'une liste
        .DESCRIPTION
            Cette fonction permet de suspendre les utilisateurs de l'AD à partir d'une liste fournie. 
            Elle désactive le compte utilisateur, change le mot de passe et empêche l'utilisateur de changer le mot de passe.
            La fonction utilise la fonction Get-ADUserBasicData pour valider les utilisateurs.
            Elle utilise également la fonction Use-RandomPassGenerator pour générer un mot de passe aléatoire.
            La fonction prend en entrée une liste d'utilisateurs sous forme de chaîne ou de chemin vers un fichier CSV.
            
            Variables Importantes:
            $supUsersList : Liste des utilisateurs à suspendre
            $supCurrentLocation : Emplacement actuel du script
            $supLegacyPassGen : Chemin vers le module TPI_TSK_ShortTools pour executer paralèlement la focntion Use-RandomPassGenerator
            $supValidSingleUser : Informations sur un utilisateur valide

            Fonctions Utilisés:
            - Get-ADUserBasicData
            - Use-RandomPassGenerator (dans le module TPI_TSK_ShortTools necessite une execution sous powershell 5 interieur)
            - Disable-ADAccount
            - Set-ADAccountPassword
            - Set-ADUser
        .PARAMETER Users
            Liste des utilisateurs à suspendre. Peut être une chaîne de noms d'utilisateur séparés par des virgules ou un chemin vers un fichier CSV contenant les noms d'utilisateur.
            Exemple : user1,user2,user3 ou "C:\Path\To\users.csv"
        .EXAMPLE
            Suspend-ADUsersFromList -Users user1,user2,user3

        .EXAMPLE
            Suspend-ADUsersFromList -Users "C:\Path\To\users.csv"
        .OUTPUTS
            La fonction ne renvoie pas de valeur, mais elle affiche des messages d'état pour chaque utilisateur traité. Elle affiche également un message d'erreur si l'utilisateur n'existe pas ou n'est pas valide.
        .LINK
    #>


    param (
        [Parameter(Mandatory = $true)][array]$Users
    )
    # Declaration des variables
    
    $supUsersList = if($Users -match ",") { $Users 
        } elseif (((Use-SimplePatternMatcher -Type "pathcsv" -String "$Users") -eq $true) -or ((Use-SimplePatternMatcher -Type "pathcsv" -String "$Users") -eq $true)) { 
            Get-Content -Path $Users | Where-Object { $_ -ne "" } 
        } else { $null }
    $supCurrentLocation = Get-Location
    $supLegacyPassGen = ".\modules\tasks\TPI_TSK_ShortTools.psm1" 

    if ($supUsersList) {
        foreach ($supSingleUser in $supUsersList) {
            Write-Host "Revue de l'utilisateur :" -NoNewline
            Write-Host -ForegroundColor Yellow "$supSingleUser"

            $supValidSingleUser = Get-ADUserBasicData -User $supSingleUser
            if ($supValidSingleUser.Exists -eq $true) {

                $jnrValidPassword = powershell -ExecutionPolicy Bypass -Command "& { Set-Location '$supCurrentLocation'; Import-Module '$supLegacyPassGen' ; Use-RandomPassGenerator}"
                $supValidSingleUserName = $supValidSingleUser.Name
                # Désactivation du compte utilisateur
                Write-Host "Désactivation: `t`t`t" -NoNewline
                Disable-ADAccount -Identity $supValidSingleUserName -ErrorAction continue
                Start-Sleep -Seconds 0.3
                Write-Host -ForegroundColor Green "Success"
                
                # Changement du mot de passe
                Write-Host "Nouveau pass $jnrValidPassword"
                Write-Host "Changer mot de passe': `t" -NoNewline
                Set-ADAccountPassword -Identity $supValidSingleUserName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$jnrValidPassword" -Force)
                Start-Sleep -Seconds 0.3
                Write-Host -ForegroundColor Green "Success"

                # Définir le mot de passe pour que l'utilisateur ne puisse pas le changer
                Write-Host "Activer 'User cannot change password': `t" -NoNewline
                Set-ADUser -Identity $supValidSingleUserName -CannotChangePassword $True -ErrorAction continue
                Start-Sleep -Seconds 0.3
                Write-Host -ForegroundColor Green "Success"
            } else {
                Write-Host -ForegroundColor Red "Utilisateur inexiste ou non valide."
                continue # On passe à l'utilisateur suivant
            }
        }
    }         
}
#$supUsList = "Anne.Paper@beemusic.ch,Fukke.Oaisu,James.Smith@beemusic.ch,Miksovky@beemusic.ch,Laurent.Vossen@beemusic.ch,Luis.RodierRemirez@beemusic.ch,MengPhua,Sandra.MartinezLopez@beemusic.ch,Stefan.Knorr@beemusic.ch,Sunil.Koduri@beemusic.ch"
#$supUsList = "C:\Users\Sergio.Jimenez\OneDrive - FNZ\FNZ\schoolProject\lab\modules\tasks\users.csv"
#Suspend-ADUsersFromList -Users $supUsList