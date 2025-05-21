function Confirm-AlwaysReadHost {
    <#
        .SYNOPSIS
            Assure que l'utilisateur entre une valeur quelconque.

        .DESCRIPTION
            Cette fonction est une version améliorée de Read-Host qui demande à l'utilisateur de saisir une valeur et continue de le faire jusqu'à ce qu'une valeur fournie. 
            Elle affiche un message d'aide si l'utilisateur ne fournit pas de valeur après X tentatives. Le nombre de tentatives, le message d'aide et le message de remerciement peuvent être personnalisés.
        .PARAMETER Counts
            Le nombre de tentatives autorisées avant d'afficher un message d'aide. Par défaut, il est défini sur 3. 
            Il est posssible de cacher le nombre de tentatives an commenttant le ligne à partir de "(attempt $arhAptem of $arhCount)"
        .PARAMETER Thank
            Le message de remerciement à afficher après une saisie réussie. Par défaut, il est défini sur "Tank you!".
        .PARAMETER Message
            Le message à afficher lors de la demande de saisie. Par défaut, il est défini sur "Entrez une valeur ".
        .PARAMETER MessageAide
            Le message d'aide à afficher si l'utilisateur ne fournit pas de valeur après X tentatives. Par défaut, il est défini sur "Veuillez fournir queleque chose au moins ".

        .EXAMPLE
            Confirm-AlwaysReadHost -Counts 5 -Message "Entrez une adresse email" -MessageAide "Please provide something at least!"
            # Demande à l'utilisateur de saisir une adresse e-mail et continue de le faire jusqu'à ce qu'une valeur soit fournie. 
            # Affiche un message d'aide après 5 tentatives infructueuses.

        .EXAMPLE
            Confirm-AlwaysReadHost -Counts 3 -Message "Entrez une valeur" -Thank "Merci!"
            # Demande à l'utilisateur de saisir une valeur et continue de le faire

        .OUTPUTS
            Renvoie la valeur saisie par l'utilisateur.

        .LINK

        .NOTES
            Auteur : Sergio Jimenez
            Date : 15 Mai 2025
            version : 2.0
    #>
    param(
        [Parameter(Mandatory = $false)][int]$Counts,
        [Parameter(Mandatory = $false)][string]$Thank,
        [Parameter(Mandatory = $false)][string]$Message,
        [Parameter(Mandatory = $false)][string]$MessageAide
    )
    $arhMassage = if ($Message -ne "") {$Message} else {"Entrez une valeur "}
    $arhShowMessageAide = if ($MessageAide -ne "") {$MessageAide} else {"Veuillez fournir queleque chose au moins ಠ_ರೃ "}
    $arhTankYou = if ($Thank -ne "") {$Thank} else {"Tank you!"}
    $arhCount = if ($Counts -ne "") {$Counts} else {3}
    do {
        $emptyCount = 0
        $arhConfirmedInput = $null
        for ($arhAptem= 1; $arhAptem -le $arhCount; $arhAptem++) {
            $arhConfirmedInput = Read-Host "$arhMassage (attempt $arhAptem of $arhCount)"
            if ([string]::IsNullOrWhiteSpace($arhConfirmedInput)) {
                $emptyCount++
            } else { 
                Write-Host "$arhTankYou"
                break
            }
        }
        if ($emptyCount -eq $arhCount) {
            Write-Host -ForegroundColor Yellow "$arhShowMessageAide"
        }
    } while ([string]::IsNullOrWhiteSpace($arhConfirmedInput))
    return $arhConfirmedInput
}
#$myTest = Confirm-AlwaysReadHost -Counts 5 -Message "Entrez une adresse email" #-MessageAide "Please provide something at least!"
#Write-Host "Thank you for your input: $myTest"