function Convert-AnyText2Normal {
<#
    .NOTES
        Auteur : Sergio Jimenez
        Date : 07 Mai 2025
        version : 1.0
    .SYNOPSIS
        Normalisation de texte
    .DESCRIPTION
        Cette fonction permet de supprimer les accents des mots. Remplacer les caractères spéciaux par leur manuellement et mettre en majuscules ou minuscules si nécessaire.
        Elle utilise la méthode Normalize de la classe System.String pour normaliser le texte et la méthode GetUnicodeCategory de la classe System.Globalization.CharUnicodeInfo pour identifier les caractères non accentués.
        
        Lors des tests de la fonction, il a été observé que la méthode Normalize ne supprimait pas les accents des caractères spéciaux.
        Par exemple, le caractère "ß" est remplacé par "ss" et le caractère "ö" est remplacé par "oe". De même, la fonction necessite d'être exécutée dans un environnement PowerShell 7 ou supérieur.
    .PARAMETER text
        Le texte à normaliser. Comme "L'été de Sußie avec Jösè, ça l'a fatiguée l'œuf"
    .PARAMETER Replace
        Un dictionnaire manuel. Par exemple, @{ "ß" = "ss"; "ö" = "oe" }

        Un autre cas observé c'est lors de la création d'un nom d'OU dans Active Directory.
        En effet, si le nom d'OU est composé d'un seul mot, il faut vraiement faire attention aux spaces avant et après le nom de l'OU. Car celas peut créer des erreurs.
        Par exemple, si le nom de l'OU est "OU= Test" au lieu de  "OU=Test"
        Solution, la fonction Convert-AnyText2Normal peut être utilisée no seulement pour normaliser le nom de l'OU mais aussi pour remplacer ses espaces ou supprimer.
        Par exemple,  "= " vers "=" la composition serait  @{ "= " = "=" }
    .PARAMETER Lower
        Si vrai, le texte sera converti en minuscules.
    .PARAMETER Upper    
        Si vrai, le texte sera converti en majuscules.
    .EXAMPLE
        Convert-AnyText2Normal -Text "L'été de Sußie avec Jösè, ça l'a fatiguée l'œuf" 
    .EXAMPLE
        Convert-AnyText2Normal -Text "L'été de Sußie avec Jösè, ça l'a fatiguée l'œuf" -Replace @{ "ß" = "ss"; "ö" = "oe" } -Lower $true
    .OUTPUTS
        Un texte normalisé sans accents et sans caractères spéciaux et sans spaces si demandé dans le paramètre -Replace.
    .LINK
        https://github.com/sergiojmnzl
#>
    param (
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $false)][PSCustomObject]$Replace,
        [Parameter(Mandatory = $false)][bool]$Lower,
        [Parameter(Mandatory = $false)][bool]$Upper
    )

     BEGIN {
        # Declaration des  Variables 
        $accReplace = $Replace
        # Nouvel object StringBuilder pour stocker le texte normalisé
        $accNewNormalizedTextBase = New-Object System.Text.StringBuilder
        # Preprocessing du text 
        $accPreProcessedText = $text.Normalize([Text.NormalizationForm]::FormD)

        # Ici on remplaces les caractères que l'on veut traiter manuellement
        if ($Replace){
            foreach ($accSingleChar in $accReplace.Keys) {
                $accPreProcessedText = $accPreProcessedText -Replace($accSingleChar,$accReplace.$accSingleChar)
            }
        } 
     }

    PROCESS {
        # Boucle pour parcourir chaque caractère de la chaîne et le replacer par son correspondant normalisé
        foreach ($accCharacter in $accPreProcessedText.ToCharArray()) {
            $accGetUnicodeCategory = [Globalization.CharUnicodeInfo]::GetUnicodeCategory($accCharacter)
            $accNonSpacingMark = [Globalization.UnicodeCategory]::NonSpacingMark
            if ($accGetUnicodeCategory -ne $accNonSpacingMark ) {
                # Void est la pour empêcher le retour de la valeur de la méthode Append
                [void]$accNewNormalizedTextBase.Append($accCharacter)
            }
        }
    }
   
    END {
        $accNewText = $accNewNormalizedTextBase.ToString().Normalize([Text.NormalizationForm]::FormC)
        # Si Lower est vrai, on retourne le texte en minuscules
        if ($Lower -eq $true -and $Upper -eq $true) {
            return $accNewText
        } elseif ($Lower -eq $true) {
            return $accNewText.ToLower()
        } elseif ($Upper -eq $true) {
            return $accNewText.ToUpper()
        } else {
            return $accNewText
        }
    }
}
# Decommenter la ligne suivante pour tester le script
# $MyNormalizer = Convert-AnyText2Normal -Text "L'été de Sußie avec Jösè, ça l'a fatiguée l'œuf"
# Write-Host $MyNormalizer  # Outputs "Lete"
