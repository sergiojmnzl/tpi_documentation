function Set-NewPassworForADUser {
    <#
        .NOTES
            Auteur : Sergio Jimenez
            Date : 14 Mai 2025
            version : 2.0
        .SYNOPSIS
            Reinitialisation de mot de passe pour un utilisateur AD
        .DESCRIPTION
            Cette fonction permet de réinitialiser le mot de passe d'un utilisateur Active Directory.
            Elle reinitialise le mot de passe d'un utilisateur AD et envoie un e-mail avec le nouveau mot de passe à son manager ou une adresse e-mail spécifiée.
            Si le manager n'est pas spécifié, la fonction demande à l'utilisateur de le saisir.
            La fonction utilise la fonction Use-RandomPassGenerator pour générer un mot de passe aléatoire.
            Elle utilise également la fonction Send-CustomEmailReport pour envoyer un e-mail avec le nouveau mot de passe.
        .PARAMETER Users
            Liste des utilisateurs à réinitialiser. Peut être une chaîne de caractères ou un chemin vers un fichier CSV/TXT contenant les utilisateurs
            Si c'est une chaîne de caractères, elle doit être séparée par des virgules.
            Si c'est un chemin vers un fichier, le fichier doit contenir une liste d'utilisateurs, un par ligne.
            Exemple : user1,user2,user3 ou "C:\path\to\file.csv"
        .EXAMPLE
            Set-NewPasswordForADUser -Users "user1,user2,user3"

        .OUTPUTS
            La fonction retourne un objet contenant les informations de l'utilisateur AD.
            Par exemple, si l'utilisateur est trouvé, la fonction retourne un objet contenant le nom, le mot de passe et d'autres informations.
        .LINK
    #>


    param (
        [Parameter(Mandatory = $true)][array]$Users
    )
    # Declaration des variables
    
    $rupUsersList = if($Users -match ",") { $Users 
        } elseif (((Use-SimplePatternMatcher -Type "pathcsv" -String "$Users") -eq $true) -or ((Use-SimplePatternMatcher -Type "pathtxt" -String "$Users") -eq $true)) { 
            Get-Content -Path $Users | Where-Object { $_ -ne "" } 
        } else { $null }
    $rupCurrentLocation = Get-Location
    $rupLegacyPassGen = ".\modules\tasks\TPI_TSK_ShortTools.psm1" 
    $rupReadyForReset = $false
    $rupServerName = "fnzSMTP"
    $rupTemplateName = "ResetPassword"

    Write-Host -ForegroundColor Cyan  "Recherche des comptes utilisateur" -NoNewline
    Start-Sleep -Seconds 1 ; Write-Host -ForegroundColor Yellow "." -NoNewline
    Start-Sleep -Seconds 0.8 ; Write-Host -ForegroundColor Yellow "." -NoNewline
    Start-Sleep -Seconds 0.6 ; Write-Host -ForegroundColor Yellow ".`t" -NoNewline
    # Recherche des utilisateurs pour les afficher dans la liste
   if ($rupUsersList ) { 
        try { $rupValidForResetList = Get-ADUserBasicData -User $rupUsersList 
        } catch { $_ } 
    } else { $rupValidForResetList = $null }
    if ($rupValidForResetList) {
        Write-Host -ForegroundColor Green "Voici la liste :"
        $rupValidForResetList | Format-Table
        $rupReadyForReset = $true
    } else {
        Write-Host -ForegroundColor Green "Comptes non trouvés"
    }
    
    if ($rupReadyForReset -eq $true) {
        #Liste des options

        $rupOption1 = "Annuler"
        $rupOption2 = "Continuer"
        Write-Host -ForegroundColor Yellow "Attention: Si vous choisissez de Continuer, vous allez reinitialiser le mot de passe de $($rupValidForResetList.Count) compte trouvés dans la liste ci-dessus."
        $rupOptionsList = @("$rupOption1", "$rupOption2")
        $rupValidOption = Show-OptionsMenuToSelect -Options $rupOptionsList
        # Execution de l'option choisie
        if ($rupValidOption) {
            switch ($rupValidOption) {
                "$rupOption2"     {
                    foreach ($rupSingleUser in $rupValidForResetList){
                        $rupSingleUserEmail = $rupSingleUser.Mail
                        $rupValidSingleUserName = $rupSingleUser.Name
                        Write-Host "Reinitialisation pour : " -NoNewline; Write-Host -ForegroundColor Yellow (Use-TextResizer -Label $rupValidSingleUserName -Width 40) -NoNewline
                        try {
                            $rupSingleUserManager = if ($null -eq $rupSingleUser.Manager) { Confirm-AlwaysReadHost  -Message "`nIndiquer un manager pour $rupValidSingleUserName" -Thank "Merci!" } else { $rupSingleUser.Manager }
                            $rupValidPassword = powershell -ExecutionPolicy Bypass -Command "& { Set-Location '$rupCurrentLocation'; Import-Module '$rupLegacyPassGen' ; Use-RandomPassGenerator}"
                            $rupAdditionalConfig = @{ "To" = "$rupSingleUserManager" }
                            $rupMailContent = "Nouveau mot de passe pour : $rupSingleUserEmail <br> Password : $rupValidPassword "
                            #Write-Host "Nouveau pass $rupValidPassword"
                            # Débloquer le compte
                            Unlock-ADAccount -Identity $rupValidSingleUserName
                            # Changement du mot de passe
                            Set-ADAccountPassword -Identity $rupValidSingleUserName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$rupValidPassword" -Force)
                            # Changement du mot de passe à la prochaine connexion
                            Set-ADUser -Identity $rupValidSingleUserName -ChangePasswordAtLogon $true 
                            # Envoi du mail
                            Send-CustomEmailReport -Template $rupTemplateName -Server $rupServerName -Content $rupMailContent -AdditionalConfig $rupAdditionalConfig
                            Start-Sleep -Seconds 0.3
                            Write-Host -ForegroundColor Green "Success"
                        }
                        catch {
                            Write-Host -ForegroundColor Green "Error"
                            $opsexceptionCaught = $_
                            Use-LogsExporter -logMessage $opsexceptionCaught -directory $global:intOpsDirectory
                        }
                    }
                }
                "$rupOption1" { return
                }
            }
        }

    }

}
#$rupUsList = "Anne.Paper@beemusic.ch,Fukke.Oaisu,James.Smith@beemusic.ch,Miksovky@beemusic.ch,Laurent.Vossen@beemusic.ch,Luis.RodierRemirez@beemusic.ch,MengPhua,Sandra.MartinezLopez@beemusic.ch,Stefan.Knorr@beemusic.ch,Sunil.Koduri@beemusic.ch"
#$rupUsList = "C:\Users\Administrator\Desktop\ActiveDirectory\Users.txt"
#Set-NewPassworForADUser -Users $rupUsList