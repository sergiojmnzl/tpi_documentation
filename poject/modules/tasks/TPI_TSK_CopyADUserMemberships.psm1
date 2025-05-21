function Copy-ADUserMemberships {
    <#
        .NOTES
            Auteur : Sergio Jimenez
            Date : 12 Mai 2025
            version : 2.0
        .SYNOPSIS
            Ajouter des utilisateurs à différents groupes en fonction d'un utilisateur miroir
        .DESCRIPTION
            Cette fonction permet de repliquer les groupes d'un utilisateur dans un autre utilisateur.
        .PARAMETER Mirror
            L'utilisateur (au format SAN ) dont les groupes seront copiés.
        .PARAMETER Targets
            Les utilisateurs cibles (au format SAN ) qui recevront les groupes de l'utilisateur miroir.
        .EXAMPLE
            Operation simple 1 to 1
            Copy-ADUserMemberships -Mirror "source.user" -Target "target.user"
        .EXAMPLE
            Operation simple 1 to n (Bulk mode) ou les destinataires sont séparés par une virgule.

            Copy-ADUserMemberships -Mirror "source.user" -Target target.user, target.user1, target.user2 
        .OUTPUTS

    #>


    param (
        [Parameter(Mandatory=$true)][string]$Mirror,
        [Parameter(Mandatory=$true)][array]$Targets
    )
    $cmbUser2Mirror = $Mirror
    $cmbTargetUsers = $Targets
    $cmbMrrMemberships = $null
    $cmbMrrMembershipList = @()

    # Check if the username is provided
    if (-not $cmbUser2Mirror) {
        Write-Error "Missing user in -user2Mirror parameter."
    }
    Write-Host "Mirror $cmbUser2Mirror"

    # Check if the target usernames are provided
    if (-not $cmbTargetUsers) {
        Write-Error "Missing users in -targetusernames parameter."
    }
    Write-Host "Target $cmbTargetUsers"
    # Initialize the variable to store the result


    # Get the AD user and their group memberships
    $cmbMrrMemberships = (Get-ADUser -Identity $cmbUser2Mirror -Properties MemberOf).MemberOf

    if ($cmbMrrMemberships){
        Write-Host "Liste des groupes de $cmbUser2Mirror :"
        Start-Sleep -Seconds 0.5
        foreach ($cmbGroup in $cmbMrrMemberships){
            $cmbMrrMembershipNames = (Get-ADGroup -Identity $cmbGroup).Name
            $cmbMrrMembershipList += $cmbMrrMembershipNames
        }
        Write-Host $cmbMrrMembershipList
    } else {
        Write-Host "Aucune appartenance trouvé pour $cmbUser2Mirror"
    }

    Write-Host "Ajout des utilisateurs dans les groups suivants"
    foreach ($cmbSingleGourp in $cmbMrrMembershipList) {
        $cmbLabelLenth = 35
        Write-Host (Use-TextResizer "$cmbSingleGourp" $cmbLabelLenth) -NoNewline
        Add-ADGroupMember -Identity $cmbSingleGourp -Members $cmbTargetUsers
        Start-Sleep -Seconds 0.6
        Write-Host "Success" -ForegroundColor Green
    }

    # Add each group to each target user
    foreach  ($cmbsingleTargetUser in $cmbTargetUsers) {
        foreach  ($cmbgroup in $cmbgroupNames) {
            if  ($cmbgroup -ne "$user2Mirror is not a member of any groups.") {
                try {
                    Add-ADGroupMember -Identity $cmbgroup -Members $cmbsingleTargetUser
                    Write-Output "Successfully added $cmbsingleTargetUser to $cmbgroup."
                } catch {
                    Write-Error "Failed to add $cmbsingleTargetUser to $cmbgroup. Error: $_"
                }
            }
        }
    } 
}