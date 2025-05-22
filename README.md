# Active Directory livecycle managment
This suite of modular PowerShell scripts lays the foundation for automating user account management in an on-premises Active Directory. 
It handles the entire lifecycle: employee arrival, modification, suspension, or departure, while keeping a clear record of each action.

The idea is to make management simpler, faster, and, above all, more secure, with clear messages for the user.
To avoid having a huge, unmaintainable script, everything is devided into modules with functions, each with its own specific mission.

With this organizational approach, the code is more readable, easier to scale (for example, if you want to add Azure or VMware later) , and allows for hassle-free reuse of functions.
Finally, only admins shoud run use the script, and everything is designed to prevent critical errors due to human inattention. 

In conclusion, this script is there to make life easier for administrators.


# Table of Contents 

[Abstract](/documentation/conception.md#Abstract)  
[Session](/documentation/conception.md#Session)  
[Naming convention](/documentation/conception.md#Naming-convention)  
- [Variable prefixes](/documentation/conception.md#Variable-prefixes)  
- [Modules naming](/documentation/conception.md#Modules-naming)  
- [Functions naming](/documentation/conception.md#Functions-naming)  
[Types of functions](/documentation/conception.md#Types-of-functions)  
  - [Operations Functions](/documentation/conception.md#Operations-Functions)  
  - [Task Functions](/documentation/conception.md#Task-Functions)  
[Configurations](/documentation/conception.md#Configurations)  
[Orchestrateur](/documentation/conception.md#Orchestrateur)  
  - [Script overview](/poject/Orchetrator.ps1)  
[Debug](/documentation/conception.md#Debug)  
[Functions](/poject/modules) 
- [Operation modules](/poject/modules/operations/readme.md)  (list of fuctions) 
  - [Get-VMsFromAzure](/poject/modules/operations/TPI_OPS_BackupAzureVM.psm1) 
  - [Get-VMsFromVcenters](/poject/modules/operations/TPI_OPS_BackupVcenterVM.psm1) 
  - [Set-NewPassworForADUser](/poject/modules/operations/TPI_OPS_ResetPassword.psm1) 
  - [Add_JoinerFromUsersList](/poject/modules/operations/TPI_OPS_Joiners.psm1) 
  - [Suspend-ADUsersFromList](/poject/modules/operations/TPI_OPS_Suspension.psm1) 
  - [Start-ADDeactivatedUsersReview](/poject/modules/operations/TPI_OPS_Review.psm1) 
  - [Remove-LeaverUsersFromAD](/poject/modules/operations/TPI_OPS_Leaver.psm1) 
- [Task modules](/poject/modules/tasks/readme.md)  (list of fuctions) 
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


# How to start

Before you begin, it is highly recommended that you consult the technical documentation to better understand how this suite of scripts works. Indeed, you have to do some configuration so as not to have errors at the time of its execution.

1. Décompresser le fichier zip

Here is the initial view

![howtoPicture1](/poject/pics/howtoPicture1.png) 

  **archive** : Contains the test file and any other lines of code used to create scripts
  **Orchestrator.ps1** :  It's the script that handles the user interface.
  **modules** :  Contains all functional modules

2. In « modules » 

![howtoPicture2](/poject/pics/howtoPicture2.png) 

3. Launch the script

![howtoPicture3](/poject/pics/howtoPicture3.png)  

Run .\Orchetrator.ps1 Et voilà, just follow the instrctions.