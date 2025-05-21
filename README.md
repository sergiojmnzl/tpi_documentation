## Active Directory livecycle managment
This suite of modular PowerShell scripts lays the foundation for automating user account management in an on-premises Active Directory. 
It handles the entire lifecycle: employee arrival, modification, suspension, or departure, while keeping a clear record of each action.

The idea is to make management simpler, faster, and, above all, more secure, with clear messages for the user.
To avoid having a huge, unmaintainable script, everything is devided into modules with functions, each with its own specific mission.

With this organizational approach, the code is more readable, easier to scale (for example, if you want to add Azure or VMware later), and allows for hassle-free reuse of functions.
Finally, only admins shoud run use the script, and everything is designed to prevent critical errors due to human inattention. 

In conclusion, this script is there to make life easier for administrators.


# Table of contents
- [Conception](/project/documentation.md#conception)
  - [Généralités](#généralités)
  - [Modélisation](#modélisation)
  - [Convention de nommage](#convention-de-nommage)
  - [Types des fonctions](#types-des-fonctions)
- [Debug](#debug)
- [Orchestrateur](#orchestrateur)
- [Aperçu du script](#aperçu-du-script)
- [Modules](#modules)
  - [Modules d’opération](#modules-dopération)
    - Get-VMsFromAzure
    - Get-VMsFromVcenters
    - Set-NewPassworForADUser
    - Add_JoinerFromUsersList
    - Suspend-ADUsersFromList
    - Start-ADDeactivatedUsersReview
    - Remove-LeaverUsersFromAD
  - [Modules de tâches](#modules-de-tâches)
    - Convert-AnyText2Normal
    - Confirm-AlwaysReadHost
    -
