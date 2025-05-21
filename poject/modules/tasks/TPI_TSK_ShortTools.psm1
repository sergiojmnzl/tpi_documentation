# Ce module contien des pitites fonctions à un but vraiment spécifique

#----------- Fonction pour exporter des logs -----------

function Use-LogsExporter {
    <#
        .NOTES
            Auteur : Sergio Jimenez
            Date : 13 Mai 2025
            version : 1.0
        .SYNOPSIS
            Resuire un texte à une taille spécifique.
        .DESCRIPTION
            Cette fonction permet de réduire un texte à une taille spécifique. Si le texte est plus long que la taille spécifiée, il sera tronqué et remplacé par "..." à la fin. c'est utile pout rendre les outputs plus lisibles. 
        .PARAMETER logMessage
            Le texte à réduire.
        .PARAMETER directory
            La largeur maximale du texte pour appliquer la réduction.
        .EXAMPLE
            Use-LogsExporter -logMessage "Test message" -directory "C:\Logs"
        .EXAMPLE
        .OUTPUTS
            Long text line       Desired alignment
            Short                Not aligned with Long text line
            And extra long lin...This is a very long line of text line

        .LINK
            https://github.com/sergiojmnzl
    #>
    param(
        [Parameter(Mandatory = $false)][pscustomobject]$LogMessage,
        [Parameter(Mandatory = $false)][string]$Directory
    )
    $logCurrentLocation = Get-Location
    $logDirectory = if ($Directory) { $Directory } else { "$logCurrentLocation" }
    $logPath = "$logDirectory\tipExportedLogs.log"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $timestamp | Out-File -FilePath $logPath -Append
    $logMessage | Out-File -FilePath $logPath -Append
    Write-Host "Plus d'infos sur l'erreur dans le fichier de log : $logPath" -ForegroundColor Yellow

}

#----------- Fonction de réduction de texte -----------

function Use-TextResizer {
    <#
        .NOTES
            Auteur : Sergio Jimenez
            Date : 13 Mai 2025
            version : 1.0
        .SYNOPSIS
            Resuire un texte à une taille spécifique.
        .DESCRIPTION
            Cette fonction permet de réduire un texte à une taille spécifique. Si le texte est plus long que la taille spécifiée, il sera tronqué et remplacé par "..." à la fin. c'est utile pout rendre les outputs plus lisibles. 
        .PARAMETER label
            Le texte à réduire.
        .PARAMETER width
            La largeur maximale du texte pour appliquer la réduction.
        .PARAMETER last
            Le suffixe à ajouter à la fin du texte réduit. Par défaut, il est défini sur "...". Si "Ignore" est spécifié, aucun suffixe ne sera ajouté.
        .EXAMPLE
            Use-TextResizer "This is a very long line of text line" 21
            $malimite = 21
            $extraLong = "This is a very long line of text line"
            Write-Host (Use-TextResizer -label "And extra long line would work?" -Width 20) -NoNewline
            Write-Host $extraLong -ForegroundColor Yellow
        .OUTPUTS
            Long text line       Desired alignment
            Short                Not aligned with Long text line
            And extra long lin...This is a very long line of text line

        .LINK
            https://github.com/sergiojmnzl
    #>
    param (
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][int]$width,
        [Parameter(Mandatory = $false)][string]$Last
    )
    $validLast = if ($last) { $last } elseif ($last -eq "Ignore") {""} else { "..." }
    if ($label.Length -gt $width) {
        # Reserve 3 characters for "..."
        $trimmed = $label.Substring(0, $width - 3) + "$validLast"
    } else {
        $trimmed = $label
    }
    return "{0,-$width}" -f $trimmed
}

#----------- Fonction pour générer un mot de passe -----------

function Use-RandomPassGenerator {
    <#
        .NOTES
            Auteur : Sergio Jimenez
            Date : 06 Mai 2025
            version : 1.0
        .SYNOPSIS
            Génère un mot de passe aléatoire complexe.
        .DESCRIPTION
            Cette fonction génère un mot de passe aléatoire complexe de la longueur spécifiée. Le mot de passe contient des lettres majuscules, minuscules, chiffres et caractères spéciaux.
            Elle utilise l'API System.Web.Security pour garantir la complexité du mot de passe. Elle doit être lancée avec powerShell 5.1. Car elle utilise la fonction GeneratePassword de l'API System.Web.Security. quie n'esplt pas disponible dans PowerShell Core.
        .PARAMETER -Length
            La longueur du mot de passe à générer. La valeur par défaut est 15 caractères.
        .EXAMPLE
            Use-RandomPassGenerator -Length 12
        .OUTPUTS
            Un mot de passe aléatoire complexe de la longueur spécifiée.
            Exemple : "A1b2C3d4E5f6G7h8"
        .LINK
            https://github.com/sergiojmnzl
    #>
    param (
        [Parameter(Mandatory = $false)][int]$Length
    )
    $validLength = if ($Length) { $Length } else { 15 }
    # Utilisation de l'api System.Web.Security
    Add-Type -AssemblyName System.Web
    $pwdIsPasswordComplex = $false
        do {
    $pwdNewPassword=[System.Web.Security.Membership]::GeneratePassword($validLength,1)
        If ( ($pwdNewPassword -cmatch "[A-Z\p{Lu}\s]") `
        -and ($pwdNewPassword -cmatch "[a-z\p{Ll}\s]") `
        -and ($pwdNewPassword -match "[\d]") `
        -and ($pwdNewPassword -match "[^\w]") `
        -and ($pwdNewPassword -notmatch "[Â£{}\[\]~iIloO0.]")
    )
        {
    $pwdIsPasswordComplex=$True
    }
        } While ($pwdIsPasswordComplex -eq $false)
        return $pwdNewPassword
}

#----------- Fonction pour générer un de travail -----------

function Use-CustomWorkingDirectory {
    <#
        .NOTES
            Auteur : Sergio Jimenez
            Date : 14 Mai 2025
            version : 2.0
        .SYNOPSIS
            Crée un répertoire de travail basé sur la date actuelle.
        .DESCRIPTION
            Cette fonction crée un répertoire de travail basé sur la date actuelle. Le repértoire est créé dans un répertoire parent spécifié ou le répertoire par défaut si aucun n'est spécifié.  
        .PARAMETER ParentDir
            Le répertoire parent dans lequel le répertoire de travail sera créé. Si aucun répertoire parent n'est spécifié, un répertoire par défaut sera utilisé.
        .EXAMPLE
            La fonction est appelée sans paramètre, elle utilisera le répertoire par défaut.
            Use-CustomWorkingDirectory 
        .EXAMPLE
            La fonction peur être appelée avec paramètre, elle utilisera le répertoire par défaut.
            Use-CustomWorkingDirectory -ParentDir "C:\Mon\Propre\Chemin\"
        .OUTPUTS
            Chemin du répertoire de travail par défaut : "C:\TPI-ScriptLogs\dd-MM-yy_hh-mm-ss"

            Chemin du répertoire de travail spécifié : "C:\Mon\Propre\Chemin\dd-MM-yy_hh-mm-ss"
        .LINK
            https://github.com/sergiojmnzl

    #>
    param (
        [Parameter(Mandatory = $false)][string]$ParentDir
    )
    $cdrDate = Get-Date -Format 'dd-MM-yy_hh-mm-ss'
    $cdrDefaultParent = "C:\TPI-ScriptLogs"
   # Test le directory existe et reation de directory par defaut
    if ($ParentDir) {
      if (Test-Path $ParentDir){
        $cwdNewDirectory = New-Item -Path "$ParentDir\$cdrDate" -ItemType Directory -Force
      } 
    } else {
        if (-not (Test-Path $cdrDefaultParent)) {
            $cwdNewDirectory = New-Item -Path "$cdrDefaultParent" -ItemType Directory -Force | New-Item -Path "$cdrDefaultParent\$cdrDate" -ItemType Directory -Force
        }
    }
    return $cwdNewDirectory
}



#----------- Fonction pour matcher un pattern -----------
function Use-SimplePatternMatcher {
    <#
        .NOTES
            Auteur : Sergio Jimenez
            Date : 14 Mai 2025
            version : 2.0
        .SYNOPSIS
            Vérifie si une chaîne de caractères correspond à un motif spécifique.
        .DESCRIPTION
            Cette fonction vérifie si une chaîne de caractères correspond à un motif spécifique déjà defini. Elle retourne un booléen indiquant si la correspondance a été trouvée ou non.
        .PARAMETER Type
            Le type de motif à vérifier. Les types disponibles sont : "ou", "mail", "domain", "pathtxt", "pathcsv".
        .PARAMETER String
            La chaîne de caractères à vérifier.
        .EXAMPLE
            Use-SimplePatternMatcher -Type "ou" -String "OU=Informatique,OU=Company"
        .EXAMPLE
            Use-SimplePatternMatcher -Type "mail" -String "username@example.com"
        .EXAMPLE
            Use-SimplePatternMatcher -Type "domain" -String "example.com"
        .EXAMPLE
            Use-SimplePatternMatcher -Type "pathtxt" -String ["C:\Path\To\File.txt" ou ".\Path\To\File.txt"]
        .EXAMPLE
            Use-SimplePatternMatcher -Type "pathcsv" -String ["C:\Path\To\File.csv" ou ".\Path\To\File.csv"]
        .OUTPUTS
            Un booléen indiquant si la correspondance a été trouvée ou non.
        .LINK
    #>
    param (
        [Parameter(Mandatory = $true)][ValidateSet("ou", "mail", "domain", "path", "pathtxt","pathcsv")][string]$Type,
        [Parameter(Mandatory = $true)][string]$String
    )
    $upmType = $Type
    $upmString = $String

    switch ($upmType) {

        "ou"    { 
            $upmRequirement = "^(OU=[^,]+|OU=[^,]+,OU=.*)$"
            if ($upmString -match $upmRequirement) { $upmIsValidPatern = $true } else { $upmIsValidPatern = $false }
        }
        "mail"  { 
            if ($upmString -match $upmSimplePattern -or $upmString -match $upmMultiplePattern) { $upmIsValidPatern = $true } else { $upmIsValidPatern = $false }
        }
        "domain"    { 
            $upmRequirement = "^([\w-]+\.)+[\w-]{2,4}$" 
            if ($upmString -match $upmRequirement ) { $upmIsValidPatern = $true } else { $upmIsValidPatern = $false }
        }
        "pathtxt"   {
            $upmRequirement = "^([a-zA-Z]:\\.*\\.*\.txt|\.\\.*\\.*\.txt)$"
            if ($upmString -match $upmRequirement ) { $upmIsValidPatern = $true } else { $upmIsValidPatern = $false }
        }
        "pathcsv"   { 
            $upmRequirement = "^([a-zA-Z]:\\.*\\.*\.csv|\.\\.*\\.*\.csv)$"
            if ($upmString -match $upmRequirement) { $upmIsValidPatern = $true } else { $upmIsValidPatern = $false }
        }
    }
    return $upmIsValidPatern
}