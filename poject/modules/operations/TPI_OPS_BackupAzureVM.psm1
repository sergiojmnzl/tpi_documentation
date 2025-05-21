function Get-VMsFromAzure {
    <#
        .NOTES
            Auteur : Sergio Jimenez
            Date : 12 Mai 2025
            version : 2.0
        .SYNOPSIS
            Exporte la liste des machines virtuelles (VMs) allumées d'une liste d'entités Azure.
        .DESCRIPTION
            Cette fonction permet de se connecter à une liste d'entités Azure et d'exporter la liste des machines virtuelles (VMs) allumées.
            Elle utilise les informations d'identification fournies pour établir la connexion et collecter les données des VMs.
            Les données collectées sont ensuite exportées au format CSV et transférées vers un emplacement distant.
            Etant donne que les environnement azure peuvent être très différents, il n'est pas possible d'adanter la fonction pour chaque environnement.
            En effet, du fait que Microsoft encourage l'utilisation de l'authentification à deux facteurs, cela peut causer de nombreux problèmes de connexion.
            La fonction a donc été conçue dans un perspective d'automatisation.
            Prerequis :
            - PowerShell 7 ou supérieur
            - Les module Az.XXXXX et Microsoft.Graph installés et importés.
            - Une application dans Entra ID avec autorisation Impersonation pour Microsoft Graph et Custon Azure rol 
            - Un certificat valide pour l'authentification.

        .PARAMETER Entities
            Liste des entités Azure à traiter. Chaque entité doit contenir les informations suivantes :
            - tenantId : ID du locataire Azure
            - clientId : ID du client Azure
            - certPath : chemin d'accès au certificat
            - certName : nom du certificat
            - type : type de l'entité (doit être "Azure")

            Le fichier de configuration doit être accessible en lecture. 
            Il se trouve dans le répertoire de configuration du module. Par defaut dans : ".\modules\config\Backup.conf"

        .PARAMETER Users
            Liste des utilisateurs à traiter. Chaque utilisateur doit être spécifié par son nom d'utilisateur au formst SAN.

            Dans une chine de caractères, le nom d'utilisateur doit être au format SAN (ex: Standar.User  ou Standar.User,Bee.Admin).

        .PARAMETER Workspace
            Chemin d'accès local où les fichiers CSV seront exportés.
        .EXAMPLE

            GetVMsFromAzureEntities -azEntitiesList ".\modules\config\BackupCreds.conf" -localWorkspace "C:\Temp\AzureVMs" -Users "Standar.User,Bee.Admin"
            Write-Host "Auzre function all good"

        .EXAMPLE

        .OUTPUTS
        
    #>

    Param(
        [Parameter(Mandatory = $true)][array]$Entities,
        [Parameter(Mandatory = $true)][array]$Users
    )
    BEGIN {
        #Decalaration des variables et verification de l'existence des utilisateurs
        $bazUsersList = if($Users -match ",") { $Users 
        } elseif (((Use-SimplePatternMatcher -Type "pathcsv" -String "$Users") -eq $true) -or ((Use-SimplePatternMatcher -Type "pathtxt" -String "$Users") -eq $true)) { 
            Get-Content -Path $Users | Where-Object { $_ -ne "" } 
        } else { $null }

        $bazAzEntityList = Get-Content -Path "$Entities" -Raw | Invoke-Expression | Where-Object { $_.Type -eq "Azure" }

        $lvrUserListForReset = @()
        $lvrReadyForReset = $true
        $lvrServerName = "fnzSMTP"
        $lvrTemplateName = "ResetPassword"



    }

    PROCESS {
        foreach ($azEntity in $bazAzEntitieReachList) {

            $bazAzTenant = $azEntity.tenantId
            $bazAzClient = $azEntity.clientId
            $bazAzCertPath = $azEntity.certPath
            $bazAzCertName = $azEntity.certName
            $bazOpsStatusTracker = $null
            $vmCollectedDataBlock = @()  # Reset per Azure entity
            
            #Write-Host "Retrieving the Certificate Thumbprint..."
            try {
                $bazCertThumbprint = (Get-ChildItem -Path $bazAzCertPath | Where-Object { $_.Subject -match $bazAzCertName }).Thumbprint
                if (-not $bazCertThumbprint) {
                    #Write-Host "Certificate not found"
                    $bazOpsStatusTracker = "Le certificate est introuvable dans $bazAzCertPath"
                }
            } catch {
                $exceptionCaught = $_
                Use-LogsExporter -LogMessage $exceptionCaught -Directory $bazLocalWorkspace
                #Write-Host "Failed to retrieve certificate for $bazAzTenant"
                $bazOpsStatusTracker = "Certificate Retrieval Failed"
            }

            if ($bazOpsStatusTracker -eq $null) {
                #Write-Host "Connecting to Microsoft Graph... with -CertificateThumbprint $currentCertThumbprint -ApplicationId $bazAzClient -Tenant $bazAzTenant "
                try {

                    $validConnection = Connect-AzAccount -CertificateThumbprint $currentCertThumbprint -ApplicationId $bazAzClient -Tenant $bazAzTenant -ServicePrincipal -Force -WarningAction SilentlyContinue -ErrorAction Stop 
                
                } catch {
                    $exceptionCaught = $_
                    Use-LogsExporter -LogMessage$exceptionCaught -Directory $bazLocalWorkspace 
                #Write-Host "Connection failed for $bazAzTenant"
                    $bazOpsStatusTracker = "Connection Failed"
                }
                $bazCurrentAzTenant = $validConnection."Subscription name"
                #Write-Host "Connected to $bazCurrentAzTenant"
            }

            if ($bazOpsStatusTracker -eq $null) {
                #Write-Host "Collecting data for expor name"
                $bazCurrentAzTenant = (Get-AzSubscription).Name 
                $exportFileName = entityNameGenerator -sourceName $bazCurrentAzTenant
                $destSourcePath = "$localWorkspace\$exportFileName"
                #Write-Host "export destination $destSourcePath"
                #Write-Host "Collecting VM data..."
                try {
                    $vmsList_WithBasicInfo = Get-AzVM | Select-Object Name, @{Name="Subscription";Expression={$_.Id.Split('/')[2]}}, ResourceGroupName
                    foreach ($vm in $vmsList_WithBasicInfo) {

                        $vmCollectedSubData = Get-AzSubscription | Where-Object { $_.Id -eq $vm.Subscription }

                        foreach ($bazUser in $bazAzUserList){
                            $vmCollectedData = Get-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name | Where-Object { $_.Tags.owner -eq $bazUser }
                        
                            if ($vmCollectedData) {
                                $vmCollectedDataBlock += [PSCustomObject]@{
                                    Owner             = $user
                                    vmName            = $vmCollectedData.Name
                                    Location          = $vmCollectedData.Location
                                    ResourceGroupName = $vmCollectedData.ResourceGroupName
                                    Subscription      = $vmCollectedSubData.Name
                                    SubscriptionId    = $vmCollectedSubData.Id
                                }
                            }
                        }
                    }
                } catch {
                    $exceptionCaught = $_
                    Use-LogsExporter -LogMessage$exceptionCaught -Directory $bazLocalWorkspace
                    #Write-Error "Failed to collect VM data for $bazAzTenant"
                    $bazOpsStatusTracker = "VM Collection Failed"
                }
            }


        # **Update global status**
        $global:isValidConnectionExport += [PSCustomObject]@{
            Name        = if ($bazOpsStatusTracker -ne $null){ $bazAzTenant } else { $bazCurrentAzTenant }
            Status      = if ($bazOpsStatusTracker -ne $null) { $bazOpsStatusTracker } else { "Successfully exported as $exportFileName" }
        }

            # Disconnect from Azure
            Disconnect-AzAccount -Confirm:$false > $null
            
    }
    }

    END {

        if ($bazOpsStatusTracker -eq $null -and $vmCollectedDataBlock.Count -gt 0) {

            return $vmCollectedDataBlock 
        }
    }
}

# Uncomment to tes the azEntity export function only
# GetVMsFromAzureEntities
