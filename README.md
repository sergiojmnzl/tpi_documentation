# Active Directory livecycle managment
This suite of modular PowerShell scripts lays the foundation for automating user account management in an on-premises Active Directory. 
It handles the entire lifecycle: employee arrival, modification, suspension, or departure, while keeping a clear record of each action.

The idea is to make management simpler, faster, and, above all, more secure, with clear messages for the user.
To avoid having a huge, unmaintainable script, everything is devided into modules with functions, each with its own specific mission.

With this organizational approach, the code is more readable, easier to scale (for example, if you want to add Azure or VMware later), and allows for hassle-free reuse of functions.
Finally, only admins shoud run use the script, and everything is designed to prevent critical errors due to human inattention. 

In conclusion, this script is there to make life easier for administrators.


# Table of Contents
**[Modélisation](documentation/conception.md)**
  - [Généralités](documentation/conception.md#Généralités)
    - [Convention de nommage](documentation/conception.md#Convention-de-nommage)
    - [Types des fonctions](documentation/conception.md#Types-des-fonctions)
    - [Configurations](documentation/conception.md#Configurations)
    - [Debug](documentation/conception.md#Debug)
  - [Orchestrateur](documentation/conception.md#Orchestrateur)
    - [Aperçu du script](/poject/Orchetrator.ps1)

**[Modules](/poject/modules)**
  - [Modules d’opération](/poject/modules/operations/readme.md)
    - [Get-VMsFromAzure](/poject/modules/operations/TPI_OPS_BackupAzureVM.psm1)
    - [Get-VMsFromVcenters](/poject/modules/operations/TPI_OPS_BackupVcenterVM.psm1)
    - [Set-NewPassworForADUser](/poject/modules/operations/TPI_OPS_ResetPassword.psm1)
    - [Add_JoinerFromUsersList](/poject/modules/operations/TPI_OPS_Joiners.psm1)
    - [Suspend-ADUsersFromList](/poject/modules/operations/TPI_OPS_Suspension.psm1)
    - [Start-ADDeactivatedUsersReview](/poject/modules/operations/TPI_OPS_Review.psm1)
    - [Remove-LeaverUsersFromAD](/poject/modules/operations/TPI_OPS_Leaver.psm1)
  - [Modules de tâches](/poject/modules/tasks/readme.md)
    - [Convert-AnyText2Normal](/poject/modules/tasks/TPI_TSK_ConvertAnyText2Normal.psm1)
    - [Confirm-AlwaysReadHost](/poject/modules/tasks/TPI_TSK_AlwaysReadHost.psm1)
    - [Copy-ADUserMemberships](/poject/modules/tasks/TPI_TSK_CopyADUserMemberships.psm1)
    - [Get-ADUserBasicData](/poject/modules/tasks/TPI_TSK_GetADUserBasicData.psm1)
    - [Send-CustomEmailReport](/poject/modules/tasks/TPI_TSK_SendCustomEmailReport.psm1)
    - [Use-SimplePatternMatcher](/poject/modules/tasks/TPI_TSK_ShortTools.psm1)
    - [Use-CustomWorkingDirectory](/poject/modules/tasks/TPI_TSK_ShortTools.psm1)
    - [Use-RandomPassGenerator](/poject/modules/tasks/TPI_TSK_ShortTools.psm1)
    - [Use-TextResizer](/poject/modules/tasks/TPI_TSK_ShortTools.psm1)
    - [Use-LogsExporter](/poject/modules/tasks/TPI_TSK_ShortTools.psm1)
    - [Show-OptionsMenuToSelect](/poject/modules/tasks/TPI_TSK_ShowOptionsMenuToSelect.psm1)



