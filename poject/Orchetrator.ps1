<#
    .NOTES
        Auteur : Sergio Jimenez
        Date : 06 Mai 2025
        version : 1.0
    .SYNOPSIS
        Menu d'operations de l'AD
    .DESCRIPTION
        Ce script permet de lancer les operations. 
        Pour evite de modififer le script, il est possible de rajouter des operations les rajoutant de puis le fichier de configuration (.\config\Menu.conf) 
        Il est possible de rajouter des operations en rajoutant le nom de l'operation dans la liste $intOprerationList et en créant le module d'operation correspondant.
    .OUTPUTS

    .LINK
        https://github.com/sergiojmnzl
#>
#------- Declaration de parametres -------
param (
    [Parameter(Mandatory=$false)] [string]$usersList,
    [Parameter(Mandatory=$false)] [bool]$extendAzure,
    [Parameter(Mandatory=$false)] [bool]$extendVMware
)

#------- Declaretion de variables globales -------

# Cette variable sert a tracker l'état de l'opérations, elle est incluse dans tous les scripts des opérations et des modules
$intOptionsConfigPath = ".\modules\config\Menu.conf"
$intOprerationList = (Get-Content -Path "$intOptionsConfigPath" -Raw | Invoke-Expression | Where-Object { $_.Type -eq "Menu" -and $_.Name -eq "UI" }).Options
$global:opsExceptionState = $null
$intCurrentOpsDirectory = Get-Location
$intTSKModuleList = Get-ChildItem -Path "$intCurrentOpsDirectory\modules\tasks" -Recurse -File | Select-Object -ExpandProperty FullName
$intOPSModuleList = Get-ChildItem -Path "$intCurrentOpsDirectory\modules\operations" -Recurse -File | Select-Object -ExpandProperty FullName


#------- Logique de l'nterface dynamique -------

#La creation de liste dynamique se fait ici, en ajoutant les options supplemantaires s'elles ont été demandées
if ($extendAzure -eq $true){
    $intOprerationList += "Backup Azure VM"
}
if ($extendVMware -eq $true){
    $intOprerationList += "Backup VCenter VM"
}




#------- Import des modules necessaires au bon fonctionnement du script -------

    Write-Host -ForegroundColor Yellow "Importation des modules de tâche `t`t`t" -NoNewline 
    try {
        if ($intTSKModuleList){
            foreach ($intTaskModule in $intTSKModuleList) { Import-Module "$intTaskModule" -Force}
            Write-Host  -ForegroundColor Green "Done"
        }else { Write-Host -ForegroundColor Red "Aucun module trouvé" }
    } catch { 
        Write-Host -ForegroundColor Red "Erreur dans l'importation" 
        exit
    }
    Start-Sleep -Seconds 2
    
    #------- Import des operation necessaires au bon fonctionnement du script -------
    Write-Host -ForegroundColor Yellow "Importation des mudules d'operation`t`t`t" -NoNewline 
     try {
        if ($intOPSModuleList){
            foreach ($intOpsModule in $intOPSModuleList) { Import-Module "$intOpsModule" -Force}
            Write-Host  -ForegroundColor Green "Done"
        }else { Write-Host -ForegroundColor Red "Aucun module trouvé" }
    } catch { 
        Write-Host -ForegroundColor Red "Erreur dans l'importation" 
        exit
    }   
    
  
    #-------- Ici les opperations commencent -------

    # Affichage du menu d'operations en boucle tant que l'utilisateur n'a pas selectionné "Exit"
    try {
        do {
            Write-Host "`n"; Start-Sleep -Seconds 2
            $opsSelectedOption = Show-OptionsMenuToSelect -Options ($intOprerationList + "Exit")
            if ($opsSelectedOption){
                <# Il est possible de rajouter des options d'Options en rajoutant des cases dans le switch ci-dessous.(et dans $intOprerationList)
                #>
                switch ($opsSelectedOption) {

                    "Exit"  {$global:opsExceptionState = "Exit"}
                "Joiner"    { 
                                $opsOption1 = "Utiliser un miroir"
                                $opsOption2 = "Utiliser un fichier CSV"
                                $opsOption3 = "Annuler"
                                Write-Host -ForegroundColor Yellow "`nLe module joiner requiert un fichier CSV ou les utilisateurs à ajouter.`n"
                                $opsOptionsList = @("$opsOption1", "$opsOption2", "$opsOption3")
                                $rewValidOption = Show-OptionsMenuToSelect -Options $opsOptionsList

                                if ($rewValidOption -eq $opsOption1) {
                                    $opsJoinerUser = Confirm-AlwaysReadHost -Counts 3 -Message "Saisir un ou plusieur de l'utilisateur" -Thank "Merci!" 
                                    $opsJoinerMirror = Confirm-AlwaysReadHost -Counts 3 -Message "Saisir le nom de l'utilisateur miroir" -Thank "Merci!"
                                    Add-JoinerFromUsersList -Users $opsJoinerUser -Mirror "$opsJoinerMirror"
                                } elseif ($rewValidOption -eq $opsOption2) {
                                    $opsJoinerCSV = Confirm-AlwaysReadHost -Counts 3 -Message "Saisir le nom du fichier CSV" -Thank "Merci!"
                                    Add-JoinerFromUsersList -Users $opsJoinerCSV
                                } elseif ($rewValidOption -eq $opsOption3) {
                                    Write-Host "Annulation de l'opération" -ForegroundColor Yellow
                                    continue
                                }
                            }
                            #
             "Suspension"  {
                                $opsOption1 = "Cuntinuer"
                                $opsOption2 = "Annuler"
                                Write-Host -ForegroundColor Yellow "`nLa suspension requiert un fichier CSV ou les utilisateurs à ajouter.`n"
                                $opsOptionsList = @("$opsOption1", "$opsOption2")
                                $rewValidOption = Show-OptionsMenuToSelect -Options $opsOptionsList

                                if ($rewValidOption -eq $opsOption1) {
                                    $opsSuspensionUser = Confirm-AlwaysReadHost -Counts 3 -Message "Saisir un ou plusieur de l'utilisateur" -Thank "Merci!" -MessageAide "`nExemple : user1,user2,user3 ou C:\path\to\file.csv"
                                    Suspend-ADUsersFromList -Users $opsSuspensionUser
                                } elseif ($rewValidOption -eq $opsOption2) {
                                    Write-Host "Annulation de l'opération" -ForegroundColor Yellow
                                    continue
                                }                        
                            }
                            #
                "Leaver"    { 
                                $opsOption1 = "Cuntinuer"
                                $opsOption2 = "Annuler"
                                Write-Host -ForegroundColor Yellow "`nLa suspension requiert un fichier CSV ou les utilisateurs à ajouter.`n"
                                $opsOptionsList = @("$opsOption1", "$opsOption2")
                                $rewValidOption = Show-OptionsMenuToSelect -Options $opsOptionsList

                                if ($rewValidOption -eq $opsOption1) {
                                $opsLeaverUser = Confirm-AlwaysReadHost -Counts 3 -Message "Saisir les l'utilisateurs ou un fichier csv" -Thank "Merci!" -MessageAide "`nExemple : user1,user2,user3 ou C:\path\to\file.csv"
                                Remove-LeaverUsersFromAD -Users $opsLeaverUser
                                } elseif ($rewValidOption -eq $opsOption2) {
                                    Write-Host "Annulation de l'opération" -ForegroundColor Yellow
                                    continue
                                }  
                            }
                            #
              "Review"     { Start-ADDeactivatedUsersReview }
                            #
         "Reset Password"   {
                                $opsOption1 = "Cuntinuer"
                                $opsOption2 = "Annuler"
                                Write-Host -ForegroundColor Yellow "`nLa suspension requiert un fichier CSV ou les utilisateurs à ajouter.`n"
                                $opsOptionsList = @("$opsOption1", "$opsOption2")
                                $rewValidOption = Show-OptionsMenuToSelect -Options $opsOptionsList

                                if ($rewValidOption -eq $opsOption1) {
                                $opsResetPasswordUser = Confirm-AlwaysReadHost -Counts 3 -Message "Saisir les l'utilisateurs ou un fichier csv" -Thank "Merci!" -MessageAide "`nExemple : user1,user2,user3 ou C:\path\to\file.csv"
                                Set-NewPasswordForADUser -Users $opsResetPasswordUser
                                } elseif ($rewValidOption -eq $opsOption2) {
                                    Write-Host "Annulation de l'opération" -ForegroundColor Yellow
                                    continue
                                }
                            }
        "Backup Azure VM"   {
                                $opsOption1 = "Cuntinuer"
                                $opsOption2 = "Annuler"
                                Write-Host -ForegroundColor Yellow "`nLa suspension requiert un fichier CSV ou les utilisateurs à ajouter.`n"
                                $opsOptionsList = @("$opsOption1", "$opsOption2")
                                $rewValidOption = Show-OptionsMenuToSelect -Options $opsOptionsList

                                if ($rewValidOption -eq $opsOption1) {
                                $opsBackupAzureVMUser = Confirm-AlwaysReadHost -Counts 3 -Message "Saisir les l'utilisateurs ou un fichier csv" -Thank "Merci!" -MessageAide "`nExemple : user1,user2,user3 ou C:\path\to\file.csv"
                                Set-NewPasswordForADUser -Users $opsBackupAzureVMUser
                                } elseif ($rewValidOption -eq $opsOption2) {
                                    Write-Host "Annulation de l'opération" -ForegroundColor Yellow
                                    continue
                                }
                            }
                            #
        "Backup VCenter VM" {
                                $opsOption1 = "Cuntinuer"
                                $opsOption2 = "Annuler"
                                Write-Host -ForegroundColor Yellow "`nLa suspension requiert un fichier CSV ou les utilisateurs à ajouter.`n"
                                $opsOptionsList = @("$opsOption1", "$opsOption2")
                                $rewValidOption = Show-OptionsMenuToSelect -Options $opsOptionsList

                                if ($rewValidOption -eq $opsOption1) {
                                $opsBackupVCenterVMUser = Confirm-AlwaysReadHost -Counts 3 -Message "Saisir les l'utilisateurs ou un fichier csv" -Thank "Merci!" -MessageAide "`nExemple : user1,user2,user3 ou C:\path\to\file.csv"
                                Set-NewPasswordForADUser -Users $opsBackupVCenterVMUser
                                } elseif ($rewValidOption -eq $opsOption2) {
                                    Write-Host "Annulation de l'opération" -ForegroundColor Yellow
                                    continue
                                }
                    }
                    #Cette partie n'est forcément pas nécessaire, car on ne peut pas selectionner une option qui n'est pas dans la liste, mais elle est là pour la sécurité.
                    default { 
                        Write-Host "Operation non reconnue" -ForegroundColor Red
                        $global:opsExceptionState = "Operation non reconnue" 
                    }
                }
            }
        } while ($global:opsExceptionState -ne "Exit")
        if ($global:opsExceptionState -eq "Exit"){
            Write-Host "Fermeture initié, à la prochaine bye" -ForegroundColor Green
        }
        #Write-Host "Operation terminé" -ForegroundColor Green
    } catch {
        # On capture le status au moment de l'erreur avec notre valiable glogal
        Write-Host "Une erreur s'est produite : $global:opsExceptionState" -ForegroundColor Red
        # L'erreur est capturée avec la variable et exportée dans le fichier de log
        $opsexceptionCaught = $_
        Use-LogsExporter -logMessage $opsexceptionCaught -directory $global:intOpsDirectory
    }