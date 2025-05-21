function Send-CustomEmailReport {
    <#
    .NOTES
        Auteur : Sergio Jimenez
        Date : 19 Mai 2025
        Version : 2.0
    .SYNOPSIS
        Envoie un email personnalisé en utilisant un modèle et un serveur SMTP personnalisés.
    .DESCRIPTION
        Cette fonction envoie un email en utilisant un modèle et un serveur SMTP spécifiés dans un fichier de configuration.
        Elle assemble les informations du serveur SMTP, du modèle d'email et du contenu de l'email avant de l'envoyer.
        Le fichier de configuration doit être au format HashTable 
        
        Variables Importantes:
        $esrSMTPServerName : Nom du template pour le serveur SMTP
        $esrMailTemplateName : Nom du template pour le mail
        $esrValidMailBodyData : Contenu du mail 
        $esrPathMailConfig : Chemin vers le fichier de configuration
        $esrValidMail : Contenu du mail assemblé
        
        Fonctions Utilisés:
        - Get-Content
        - Invoke-Expression
        - Send-MailMessage
    .PARAMETER Template
        Nom du template pour le mail. Il es reporté dans la variable $esrMailTemplateName
    .PARAMETER Server
        Nom du template pour le serveur SMTP. Il es reporté dans la variable $esrSMTPServerName (Le template par defaut ne contient pas d'identifiant pour le serveur SMTP)
    .PARAMETER Content
        Contenu du mail. Il es reporté dans la variable $esrValidMailBodyData
    .PARAMETER Config
        Chemin vers le fichier de configuration. Par défaut, il est défini sur ".\modules\config\SMTP.conf"
    .PARAMETER AdditionalConfig
        Configuration supplémentaire pour le mail à envoyer. Il est reporté dans la variable $esrAdditionalConfig
        Il est utile par pour customiser le destinataire ou le sujet ou les cc 
    .EXAMPLE
        Send-CustomEmailReport -Template "ResetPassword" -Server "fnzSMTP" -Content "Ceci est un test de l'envoi d'un email"
        Cette commande envoie un email en utilisant le modèle "ResetPassword" et le serveur SMTP "fnzSMTP" avec le contenu spécifié.
    .EXAMPLE
        $esrMailContent = "Ceci est un test de l'envoi d'un email"
        $ServerName = "fnzSMTP"
        $TemplateName = "ResetPassword"
        Send-CustomEmailReport -Template $TemplateName -Server $ServerName -Content $myMailContent [-Config ".\modules\config\SMTP.conf" -AdditionalConfig $myAdditionalConfig]
    .OUTPUTS
        aucun
    #>
    param (
        [Parameter(Mandatory = $true)][string]$Template,
        [Parameter(Mandatory = $true)][string]$Server,
        [Parameter(Mandatory = $true)][string]$Content,
        [Parameter(Mandatory = $false)][string]$Config,
        [Parameter(Mandatory = $false)][string]$AdditionalConfig
    )
    # Déclaration des variables
    $esrSMTPServerName = $Server
    $esrMailTemplateName = $Template
    $esrValidMailBodyData = $Content #Elle est utilisée pour le corps du mail
    $esrPathMailConfig = if ($Config){$Config}{ ".\modules\config\SMTP.conf"}
    $esrAdditionalConfig = if ($AdditionalConfig){$AdditionalConfig}else{$null}
    $esrValidMail = @{} 
    $excludeKeys = @("Type", "Name")

    # Importation de la configuration
    $esrSMTPServer = Get-Content -Path "$esrPathMailConfig" -Raw | Invoke-Expression | Where-Object { $_.Type -eq "Server" -and $_.Name -eq "$esrSMTPServerName" }
    $esrMailTemplate = Get-Content -Path "$esrPathMailConfig" -Raw | Invoke-Expression | Where-Object { $_.Type -eq "HTML" -and $_.Name -eq "$esrMailTemplateName" }

    # Assembage du serveur SMTP et le Template
    foreach ($key in $esrSMTPServer.Keys) {
        if ($excludeKeys -notcontains $key) {
            $esrValidMail[$key] = $esrSMTPServer[$key]
        }
    }
    if ($null -ne $esrAdditionalConfig) {
        foreach ($key in $esrAdditionalConfig.Keys) {
            $esrValidMail[$key] = $esrAdditionalConfig[$key]
        }
    }
    foreach ($key in $esrMailTemplate.Keys) {
        if ($excludeKeys -notcontains $key) {
            $esrValidMail[$key] = $esrMailTemplate[$key]
        }
    }

    Send-MailMessage @esrValidMail -BodyAsHtml -WarningAction SilentlyContinue
}
