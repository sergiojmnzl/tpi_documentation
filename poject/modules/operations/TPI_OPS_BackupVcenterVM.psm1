function Get-VMsFromVcenters {
    <#
        .NOTES
            Auteur : Sergio Jimenez
            Date : 14 Mai 2025
            version : 2.1
        .SYNOPSIS
            Retrouve les VM appartenant à une liste d'utilisateurs.
        .DESCRIPTION
            Cette fonction se connecte à chaque vCenter défini dans le fichier de configuration et récupère les machines virtuelles (VMs) dont l'annotation "Owner" correspond à l'un des utilisateurs fournis.
            Elle retourne un tableau d'objets contenant les informations de base des VMs.
            Le fichier deconfiguration par defaut est -->.\modules\config\Backups.conf
            Les modules requis sont :  VMware.PowerCLI
        .PARAMETER Users
            Liste des utilisateurs dont les VMs doivent être récupérées. 
        .EXAMPLE
            Get-VMsFromVcenters -Users user1,user2
        .OUTPUTS
            Un tableau d'objets contenant les informations de base des VMs ou $null si aucune donnée n'est collectée.
    #>
    param (
        [Parameter(Mandatory = $true)][array]$Users
    )
    BEGIN {
        $bvcCurrentLocation = Get-Location
        # Lecture du fichier de configuration pour récupérer la liste des vCenters
        $bvcVcenterList = Get-Content -Path "$bvcCurrentLocation\modules\config\Backups.conf" -Raw | Invoke-Expression | Where-Object { $_.Type -eq "VMware" }
        $bvcLisOfUsers = $Users
    }
    PROCESS {
        foreach ($bvcVCenter in $bvcVcenterList) {
            #$bvcVCName = $bvcVCenter.Name
            $bvcVCCreds = $bvcVCenter.Creds
            $bvcVCServer = $bvcVCenter.Server
            #$bvcOperationStatusTrack = $null
            $bvcVMDataBlock = @()  # Reinitialiser pour chaque vCenter
            try {
                # Importation des identifiants depuis le fichier XML
                Write-Host "Importation des identifiants $bvcVCServer"
                $singleVCenterCred = Import-Clixml -Path $bvcVCCreds -ErrorAction -Skip
                $bvcValidConnection = Connect-VIServer $bvcVCServer -Credential $singleVCenterCred -Force -WarningAction SilentlyContinue -ErrorAction Stop 
            } catch {
                $exceptionCaught = $_
                Use-LogsExporter -logMessage $exceptionCaught
                Write-host "Echeque de la connexion au vCenter $bvcVCServer"
            }
            # Si la connexion a reussi on procède à la collecte des données
            if ($bvcValidConnection.Name -eq $bvcVCServer) {
                $bvcVMBasicInfo = Get-VM 
                foreach ($bvcVM in $bvcVMBasicInfo) {
                    foreach ($bvcSingleUser in $bvcLisOfUsers) {
                            $bvcUserVM = (Get-Annotation -Entity  "$bvcVM" | Where-Object { ($_.Name -eq "Owner") -and ($_.Value -eq "$bvcSingleUser")}) #.AnnotatedEntity
                            $bvcUserVM
                            $bvcVMDataBlock += [PSCustomObject]@{
                                Id        = $bvcUserVM.AnnotatedEntityId
                                Name      = $bvcUserVM.AnnotatedEntity
                                Owner     = $bvcUserVM.Value
                            }
                    }
                }
                #$bvcVMDataBlock #Decommenter pour afficher les données collectées
                # Se deconnecter du vCenter
                Disconnect-VIServer -Server $bvcVCServer -Force -Confirm:$false
            }
            # Si Il y a des données collectées
            if ($bvcVMDataBlock.Count -gt 0) { 
                Write-Host "Données collectées pour le vCenter $bvcVCServer"
                return $bvcVMDataBlock 
            } else { 
                Write-Host "Aucune donnée collectée pour le vCenter $bvcVCServer"
                return $null
            }
        }
    }
    END { Write-Host "Traitement terminé pour tous les vCenters."}
}
# Uncomment to test the vcenter export function only
# Get-VMsFromVcenters -Users "user1","user2"