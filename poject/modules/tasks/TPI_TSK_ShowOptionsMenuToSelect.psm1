<# 
Auteur : Sergio Jimenez
Date : 06 Mai 2025
version : 1.0
Description : 
Notes: Le sufix "dsp"NomVariable est utilisé pour les rendre la variable unique et éviter les conflits de nommage. 

#>

function Show-OptionsMenuToSelect {
    <#
        .NOTES
            Auteur : Sergio Jimenez
            Date : 06 Mai 2025
            version : 1.0
        .SYNOPSIS
            Affiche des option retourne l'option selectionnée par l'utilisateur.
        .DESCRIPTION
            Ce script permet d'afficher un menu d'options en boucle et retourne l'option selectionnée par l'utilisateur.
            Il utilise la fonction Read-Host pour demander à l'utilisateur de selectionner une option parmi une liste d'options.
            La fonction utilise également la fonction Write-Host pour afficher les options et les messages d'erreur.
            Elle utilise des numéros pour identifier les options et une boucle do-while pour valider la selection de l'utilisateur.
            Ce que l'utilisateur doit faire c'est de selectionner une option (un numéro) parmi la liste d'options affichée.

        .PARAMETER Options
            L'adresse e-mail ou le nom d'utilisateur de l'utilisateur à vérifier.
        .EXAMPLE
            Il est possible de créer une liste d'options dynamiques, par exemple, en ajoutant des options supplémentaires.
            #$testlist = @("Joiner", "Suspension", "Leaver", "Review", "Resetpassword", "BackupAzureVM", "BackupVcenterVM")

            # Show-OptionsMenuToSelect -Options ($testlist + "Exit")
        .EXAMPLE
            Les puissances de la fonction reside dans le fait qu'elle peut être utilisée dans n'importe quel script, par exemple, avec case ou bien switch dont le nom de l'option est peut être dans une variable.

            $rewOption1 = "Supprimer"
            $rewOption2 = "Saisir manuellement"
            $rewOption3 = "Annuler"
            $rewOptionsList = @("$rewOption1", "$rewOption2", "$rewOption3")
            $rewValidOption = Show-OptionsMenuToSelect -Options $rewOptionsList
            switch ($rewValidOption) { "$rewOption1" {<mon script 1>} "$rewOption2"{<mon script 2>} "$rewOption3"{<mon script 3>} }

            
        .OUTPUTS
            La fonction retourne l'option selectionnée par l'utilisateur.
            Par exemple, si l'utilisateur selectionne "Joiner", la fonction retourne "Joiner".
 
        .LINK
            https://github.com/sergiojmnzl
    #>

    param (
        [Parameter (mandatory = $false)][array] $Options 
    )
    $dspOptionsList = $Options
    if($dspOptionsList){
        # Generation de l'interface utilisateur  "Nom de l'Option" : "numé"
        $dspIndexOptions = 1
        foreach ($dspOption in $dspOptionsList) {
            Write-Host "$dspIndexOptions : $($dspOption) "
            $dspIndexOptions++
        }
        # Boucle de validation de l'Option selectionnée, si l'utilisateur ne selectionne pas une option valide, il lui sera demandé de selectionner une option valide.
        do {
            Write-Host " `t"
            $dspChoiceOfOption = Read-Host "Selectionner une Option"
            if ($dspChoiceOfOption -match '^[0-9]+$') {

                $dspValidateChoice = [int]$dspChoiceOfOption

                if ($dspValidateChoice -ge 1 -and $dspValidateChoice -le $dspOptionsList.Count) {
                    $dspSelectedOption = $dspOptionsList[$dspValidateChoice - 1]
                    Write-Host "Option selectionnée" `t`t -NoNewline
                    Write-Host -ForegroundColor Green "$($dspSelectedOption)"
                    $dspIsChoiceOfOption = $true
                } else {
                    Write-Host "Veuilez selectionner une option valide (1 to $($dspOptionsList.Count))" -ForegroundColor Red
                    $dspIsChoiceOfOption = $false
                }

            } else {
                Write-Host "Veuilez selectionner une option valide" -ForegroundColor Red
            }
        } while (-not $dspIsChoiceOfOption)
        # Si l'utilisateur a selectionné une option valide, on execute l'Option selectionnée.
        if ($dspIsChoiceOfOption -eq $true){
            # La fonction retourne l'option selectionnée par l'utilisateur.
            return $dspSelectedOption
        }
    }
    
}
