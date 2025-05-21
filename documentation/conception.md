# Modélisation {#Modelisation} 

Afin de suive les Exigences techniques dans le cahier de charge, pour Maintenance et évolutivité :
> « Le code doit être modulaire pour permettre des extensions ou des mises à jour futures (par ex., ajout de nouvelles opérations ou intégration avec des outils tiers). Les fonctions principales doivent être réutilisables et indépendantes. (Par ex., même fonction de génération de mod de passe pour « Joiner » ou « Leaver » 

Il a été nécessaire de réimager le script initialement demandé. En effet, la création d’un seul et unique script de 2000 lignes n’est pas une solution viable. Une telle approche rendrait le code difficile à lire, à maintenir et à déboguer. De plus, cela irait à l’encontre des principes de la programmation modulaire.
Le script a donc été divisé en plusieurs modules, chacun ayant une responsabilité spécifique. Cela permet de mieux organiser le code, de faciliter la maintenance et d'améliorer la lisibilité. Cela permet de réutiliser des fonctions dans différents contextes sans avoir à dupliquer le code. 

## Généralités {#Generalites} 

Dans cette section nous allons parcourir génralités des modules et des fonctions. Bien que les modules puissent être de fonctions, le principe d’in module est qu’ils peuvent contenir un ensemble de fonctions comme c’est le cas de « TPI_TSK_ShortTools.psm1 » la raison principale pour laquelle il y ait des modules contenant une seule fonction est le nombre de lignes de la fonction.

### Convention de nommage {#Con-Nommage} 

Le préfix "xxx" NomVariable 
Toutes les fonctions ont leur propre combinaison de caractères qui est utilisé pour les rendre la variable unique et éviter les conflits de nommage entre les différentes fonctions

#### Session
Le lancement de l’orchestrateur doit se faire avec la session de l’utilisateur ayant les droits nécessaires pour opérer l’AD


#### Les modules {Les-modules} 
Les modules sont nommés avec le préfixe « TPI_TSK_ » pour les modules de tâches   ou « TPI_OPS_ » pour les modules de d’opération, suivi du nom désiré en fonction des actions à réaliser. 

Exemple : 

*« TPI_OPS_ResetPassword.psm1 »* et de la même manière pour *« TPI_TSK_SimpleLogExporter.psm1 »*

#### Les fonctions 
Les fonctions sont nommées en suivant les recommandations des Verbes approuvés pour les commandes PowerShell. 
Donc, un *« verbe d’action »* plus *« - »* plus *« l’action é réaliser »*

Exemple : 
*Reset-ADUserPassword *ou *Get-ADUserBasicInfo* ou *New-RandomPassGeneration*

#### Les types des fonctions {Les-types-des-fonctions} 

Dans la section pour la convention de nommage nous avons évoqué le point pour les différents types de modules. Cela prend son sens ici. 
Bien que les modules d’opération contiennent des également des fonctions, celles-ci sont dépendantes des fonctions appartenant aux modules de tâches. Par conséquent, si les modules de tâches ne sont pas importés correctement ou sont défaillantes, les fonctions d’opérations ne pourront pas opérer correctement.
Fonctions d’opérations

Elles exécutent un ensemble de fonctions de tâche. 

Example : 
La fonction « Reset-ADUserPassword » appartient au module « TPI_OPS_ResetPassword.psm1 », comme l’indique son nom elle va changer le mot de passe du compte X. Sa correcte exécution dépend à son tour des fonctions de tâches telles que « Get-ADUserBasicInfo » qui va confirmer si l’utilisateur existe. Puis de la fonction « New-RandomPassGeneration » pour générer un mot de passé sécurisé et ainsi de suite.

#### Fonctions de tâche {Fonctions-de-tâche} 

Elles sont capables de réaliser des tâches dans le but d’obtenir un résultat spécifique. 

 Exemple : 

« New-RandomPassGeneration » appartiennent à un module « TPI_TSK_XXX.psm1 ».  Et dépend uniquement du système pour retourner un mot de passe.

### Configurations {#Configurations} 

Afin de réduire les modifications directes dans les lignes de code. Un standard a été établi sur la base de fichiers de configurations contenant les donnes dans un format HahsTable  dont deux paires de valeurs sont obligatoires 

`
    Type = "value0"	et 	Name = "value1"
`
Ce système devient très utile au moment de réaliser des opérations de masse ou lors des automatisations. Puisque les paramètres restent dans le même format, il est possible de créer autant de fichier de configuration que l’on souhaite. Cela permet une meilleure organisation 
Exemple
 
**Backups.conf** 

Contient les informations nécessaires pour sen connecter dans Azure et un vCenter 

```
@{
    type = "VMware2";
    Name = "vcenter.domian.local";
    Creds = "C:\scripts\inventory\vcenter.dimain.local.xml" 
}
@{ 
    type = "Azure";
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

Contient les informations nécessaires pour envoyer un email (server + body )

```
@{  
    Type = "Server";
    Name = "ResetPassword";
    SmtpServer = "smpt.beemusic.ch";
    Port = "25";
    From = "TestRoport@beemusic.ch";
} 
```
Ou bien 
```
@{  
    Type = "Server";
    Name = "fnzSMTP";
    SmtpServer = "SMTP.beemusic.ch";
    Port = "25";
    From = "TestRoport@beemusic.ch";
    To = "sergio.jimenez@beemusic.ch","admin@beemusic.ch";
}
```
Ou bien, un code HTML
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

Pour bien comprendre ce format, nous pouvons les assimiler à des blocks. L’avantage d’utiliser ce format est que nous pouvons les assembler de la manière qui nous convient les mieux. 
Se référer à la fonction Send-CustomEmailReport pour en savoir plus 

## Orchestrateur 

L’Orchestrator agit comme intermédiaire entre l’utilisateur et les modules. Voici un aperçu des interactions  

### Aperçu du script

Orchetrator.ps1 est au sommet des module et ajoute la couche UI ou interface utilisateur pour une expérience « User Friendly »
Pour éviter de modifier le script, il est possible de rajouter des opérations les rajoutant de puis le fichier de configuration (.\config\Menu.conf) 
Il est possible de rajouter des opérations en rajoutant le nom de l'opération dans la liste $intOprerationList et en créant le module d'opération correspondant.



# Debug
Pour autant que la session reste ouverte après la fermeture de l’orchestrateur, il est possible d’utiliser la commande Get-Help   pour obtenir de l’aide sur les fonctions. En effet, toutes les fonctions contiennent au minimum les points suivants.
. NOTES    .SYNOPSIS    .DESCRIPTION    .PARAMETER     .EXAMPLE    .OUTPUT .LINK 
De plus, presque tous les lignes de script contiennent des Write-Host commentés et qui peuvent aide    dans le suivi de l’exécution dans les étapes importantes

Exemple : La fonction pour l’opération « Review » 