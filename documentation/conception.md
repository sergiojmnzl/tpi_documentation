# Abstract 

In order to follow the Technical Requirements in the specifications, for Maintenance and Scalability:
> « Le code doit être modulaire pour permettre des extensions ou des mises à jour futures (par ex., ajout de nouvelles opérations ou intégration avec des outils tiers). Les fonctions principales doivent être réutilisables et indépendantes. (Par ex., même fonction de génération de mod de passe pour "Joiner" ou "Leaver" 

It was necessary to reimage the script initially requested. Indeed, the creation of a single script of 2000 lines is not a viable solution. Such an approach would make the code difficult to read, maintain, and debug. Moreover, it would go against the principles of modular programming. The script was therefore divided into several modules, each with a specific responsibility. This helps to better organize the code, facilitate maintenance, and improve readability. This allows functions to be reused in different contexts without having to duplicate the code. 

In this section, we'll walk through the generalities of modules and functions. Although modules can be functions, the principle of in module is that they can contain a set of functions as is the case with *TPI_TSK_ShortTools.psm1* The main reason why there are modules containing a single function is the number of lines of code for that function.

## Session 

The orchestrator must be launched with the user's session that has the necessary admin rights to operate the Active Directory 

## Naming convention

### The *xxx* prefix *VariableName* 

All functions have their own combination of characters that is used to make them the variable unique and avoid naming conflicts between different functions
###  Modules naming

Modules are prefixed with *TPI_TSK_* for task modules or *TPI_OPS_* for operation modules, followed by the desired name depending on the actions to be performed.

Exemple : 

*TPI_OPS_ResetPassword.psm1* et de la même manière pour *TPI_TSK_SimpleLogExporter.psm1*

### Functions naming

Functions are named following the recommendations of the [Approved Verbs for PowerShell commands](https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-7.5). So, an *Action Verb* plus *-* plus the *action to be carried out*

Exemple : 
*Reset-ADUserPassword* ou *Get-ADUserBasicInfo* ou *New-RandomPassGeneration*

## Types of functions

In the section for the naming convention we discussed the point for the different types of modules. It makes sense here. Although operation modules also contain functions, these are dependent on functions that belong to the task modules. Therefore, if the task modules are not imported correctly or are faulty, the operations functions will not be able to function correctly. 

### Operations Functions

They perform a set of task functions.

Example: The "Reset-ADUserPassword" function belongs to the *TPI_OPS_ResetPassword.psm1* module, as its name suggests, it will change the password of the X account. Its proper execution in turn depends on task functions such as "Get-ADUserBasicInfo" which will confirm whether the user exists. Then the "New-RandomPassGeneration" function to generate a secure password and so on.

### Task Functions 
They are able to perform tasks with the aim of achieving a specific result.

Example: *Use-RandomPassGenerator* belongs to a module *TPI_TSK_XXX.psm1*. And depends solely on the system to return a password.

### Configurations 

To reduce direct changes in lines of code. A standard has been established on the basis of configuration files containing data in a [HahsTable](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_hash_tables?view=powershell-7.5) format with two pairs of values required 

`
    Type = "value0"	et 	Name = "value1" 
`

Ce système devient très utile au moment de réaliser des opérations de masse ou lors des automatisations. Puisque les paramètres restent dans le même format, il est possible de créer autant de fichier de configuration que l’on souhaite. Cela permet une meilleure organisation 

Exemple 

**Backups.conf** 

Contient les informations nécessaires pour sen connecter dans Azure et un vCenter 

```
@{
    Type = "VMware2";
    Name = "vcenter.domian.local";
    Creds = "C:\scripts\inventory\vcenter.dimain.local.xml" 
}
@{ 
    Type = "Azure";
    Name = "myTenant3";
    tenantId = "myTenantId3";
    clientId = "myClientId3";
    certPath = "Cert:\LocalMachine\My";
    certName = "CertName"
}
```
**Menu.conf** 

Contient les informations nécessaires pour afficher le menu des opérations

```
@{  
    Type = "Menu";
    Name = "UI";
    Options = "Joiner","Suspension","Leaver","Review","Reset Password"
}
```

**SMTP.conf** 

Contains the information needed to send an email (server + body)

```
@{  
    Type = "Server";
    Name = "ResetPassword";
    SmtpServer = "smpt.beemusic.ch";
    Port = "25";
    From = "TestRoport@beemusic.ch";
} 
```
Or 
```
@{  
    Type = "Server";
    Name = "swissSMTP";
    SmtpServer = "SMTP.beemusic.ch";
    Port = "25";
    From = "TestRoport@beemusic.ch";
    To = "sergio.jimenez@beemusic.ch","admin@beemusic.ch";
}
```
Or, an HTML code
```
@{
    Type = "HTML";
    Name = "ResetPassword";
    Subject = "Reset Password";
    Body = "
<html>
    <head>
        <style>
        </style>
    </head>
    <body>
        <p>Nouveau mot de passe temporaire</p>
        <p> $esrValidMailBodyData </p>
        <p>Veuillez le transmettre uniquement à son destinataire</p>
    </body>
</html>
"
}
```

To fully understand this format, we can think of them as blocks. The advantage of using this format is that we can put them together in the way that suits us best. Refer to the *Send-CustomEmailReport* function for more information 


# Orchestrateur 

The Orchestrator acts as an intermediary between the user and the modules.

 Here's an overview of the interactions


![diagram](/documentation/pics/diagram.png)

**Aperçu du script**

Orchetrator.ps1 is at the top of the modules and adds the UI layer for a User Friendly experience To avoid modifying the script, it is possible to add operations adding them from the configuration file `(.\poject/modules/config/Menu.conf)`. It is possible to add operations by adding the name of the operation to the $intOprerationList list and creating the corresponding operation module.



# Debug 

As long as the session remains open after the orchestrator is closed, you can use the Get-Help command to get help with the functions. Indeed, all functions contain at least the following points.

.NOTES
.SYNOPSIS
.DESCRIPTION
.PARAMETER
.EXAMPLE
.OUTPUT
.LINK 

In addition, almost all script lines contain commented Write-Hosts that can help in tracking execution in important steps

Example: The function for the *Review* operation