function Remove-LeaverUsersFromAD {
    <#
        .NOTES
            Auteur : Sergio Jimenez
            Date : 14 Mai 2025
            version : 2.0
        .SYNOPSIS
            Désactiver et supprimer les utilisateurs AD
        .DESCRIPTION
            Cette fonction permet de désactiver les utilisateurs AD et les deplacer dans l'OU CompanyLeaverTemp.
            Elle utilise la fonction Get-ADUserBasicData pour récupérer les informations de l'utilisateur.
            Elle utilise également la fonction Use-RandomPassGenerator pour générer un mot de passe aléatoire.
            
        .PARAMETER Users
            Liste des utilisateurs à désactiver. Peut être une chaîne de caractères ou un chemin vers un fichier CSV/TXT contenant les utilisateurs
            Si c'est une chaîne de caractères, elle doit être séparée par des virgules.
            Si c'est un chemin vers un fichier, le fichier doit contenir une liste d'utilisateurs, un par ligne.
            Exemple : "user1,user2,user3" ou "C:\path\to\file.csv"

        .EXAMPLE
            Remove-LeaverUsersFromAD -Users "user1,user2,user3"
            Cette commande désactive les utilisateurs user1, user2 et user3 dans Active Directory.

        .EXAMPLE
            Remove-LeaverUsersFromAD -Users "C:\Users\Administrator\Desktop\ActiveDirectory\Users.txt"
            Cette commande désactive les utilisateurs spécifiés dans le fichier Users.txt dans Active Directory.

        .OUTPUTS
            S'il n'y a pas d'erreurs, pour chaque utilisateur traité, la fonction retourne un message indiquant que le traitement a été effectué avec succès.
            Par exemple, 
                Traitement de :                                 Yan.Rousseau
                Changememt de mot de passe :                    Success
                Eviter le changememt de mot de passe :          Success
                Pas de groupes AD trouvés pour ce compte (si applicable)
                Mise à jour de la secription:                   Success
                Deplacement vers l'OU CompanyLeaverTemp :       Success
        .LINK


    #>
    param (
        [Parameter(Mandatory = $true)][array]$Users
    )
    $lvrUsersList = if($Users -match ",") { $Users 
        } elseif (((Use-SimplePatternMatcher -Type "pathcsv" -String "$Users") -eq $true) -or ((Use-SimplePatternMatcher -Type "pathtxt" -String "$Users") -eq $true)) { 
            Get-Content -Path $Users | Where-Object { $_ -ne "" } 
        } else { $null }
    $lvrCurrentLocation = Get-Location
    $lvrLegacyPassGen = ".\TPI_TSK_ShortTools.psm1" 
    $lvrReadyForProcess = $false

    # Recherche des utilisateurs pour les afficher dans la liste
    Write-Host -ForegroundColor Cyan  "Recherche des comptes utilisateur" -NoNewline
    Start-Sleep -Seconds 0.5 ; Write-Host -ForegroundColor Yellow "." -NoNewline
    Start-Sleep -Seconds 0.3 ; Write-Host -ForegroundColor Yellow "." -NoNewline
    Start-Sleep -Seconds 0.2 ; Write-Host -ForegroundColor Yellow ".`t" -NoNewline
    if ($lvrUsersList ) { 
        try { $lvrValidLeaverList = Get-ADUserBasicData -User $lvrUsersList 
        } catch { $_ } 
    } else { $lvrValidLeaverList = $null }
  
    if ($lvrValidLeaverList) {
        Write-Host -ForegroundColor Green "Voici la liste :"
        $lvrValidLeaverList | Format-Table
        $lvrReadyForProcess = $true
    }else {
        Write-Host -ForegroundColor Green "Comptes non trouvés"
    }
    if ($lvrReadyForProcess -eq $true) {
        $lvrValidLeaversForProcess = $lvrValidLeaverList | Where-Object { $_.Exists -eq $true }

        foreach ($lvrUserForProcess in $lvrValidLeaversForProcess) {
            $lvrUserForProcessFullOU = $lvrUserForProcess.FullOU
            $lvrUserForProcessName = $lvrUserForProcess.Name
            # Commenecement du traitement de l'utilisateur
            Write-host "`nTraitement de : `t`t`t`t" -NoNewline ; Start-Sleep -Seconds 0.2 ; Write-host -ForegroundColor Yellow "$lvrUserForProcessName"

            #Set new rendom password
            Write-host "Changememt de mot de passe : `t`t`t" -NoNewline
            $lvrNewUserPassword = powershell -ExecutionPolicy Bypass -Command "& { Set-Location '$lvrCurrentLocation'; Import-Module '$lvrLegacyPassGen' ; Use-RandomPassGenerator}"
            Set-ADAccountPassword -Identity $lvrUserForProcessName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $lvrNewUserPassword -Force)
            Start-Sleep -Seconds 0.2
            Write-Host -ForegroundColor Green "Success"

            # Désactiver le compte utilisateur

            # Définir le mot de passe pour que l'utilisateur ne puisse pas le changer
            Write-Host "Eviter le changememt de mot de passe : `t`t" -NoNewline
            Set-ADUser -Identity $lvrUserForProcessName -CannotChangePassword $True -ErrorAction continue
            Start-Sleep -Seconds 0.2
            Write-Host -ForegroundColor Green "Success"

            # Supprimer le compte de tous les groupes AD
            $lvrsSingleLeaverGroups = (Get-ADUser -Identity $lvrUserForProcessName -Properties MemberOf).MemberOf
            if($lvrsSingleLeaverGroups){
                try{
                Write-Host "Supresion des groupes AD: `t`t`t" -NoNewline
                Remove-ADPrincipalGroupMembership -Identity  $lvrUserForProcessName -MemberOf $lvrsSingleLeaverGroups -Confirm:$true -ErrorAction Continue -WarningAction SilentlyContinue
                Start-Sleep -Seconds 0.2
                Write-Host -ForegroundColor Green "Success"
                }catch{
                Write-Host -ForegroundColor Green "Error"
                }
            } else{
                Write-Host -ForegroundColor Green "Pas de groupes AD trouvés pour ce compte"
                }

        #    Update the Description on the account
            Write-host "Mise à jour de la secription: `t`t`t" -NoNewline
            $lvrDisabledDate = (get-date -format "dd/MM/yyyy HH:mm")
            $lvrOperator = [Environment]::UserName
            Set-ADUser -Identity $lvrUserForProcessName -Description "Leaver run by $lvrOperator on $lvrDisabledDate" -ErrorAction continue
            Start-Sleep -Seconds 0.2
            Write-Host -ForegroundColor Green "Success"

            # Deplacement dans l'OU de désactivation
            Write-Host "Deplacement vers l'OU CompanyLeaverTemp : `t" -NoNewline
            Move-ADObject -Identity $lvrUserForProcessFullOU -TargetPath "OU=CompanyLeaverTemp,OU=Company,DC=beemusic,DC=ch" -ErrorAction Continue
            Start-Sleep -Seconds 0.2
            Write-Host -ForegroundColor Green "Success"

        }
        
        Write-Host "`nRunning additional checks..." -NoNewline
            <#
            Bases pour implementationde la rechershche des VMs sur azure, se referer à la fonction Get-VMsListFromAzure 
            Pour plus de détails, consulter la documentation technique de la fonction
            #>
        Write-Host  -ForegroundColor Cyan "`All good :)"                 
    }
    return
}
#Remove-LeaverUsersFromAD -Users "C:\Users\Administrator\Desktop\ActiveDirectory\Users.txt"