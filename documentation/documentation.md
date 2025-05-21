Conception
Note : 
Dans les derniers tests au 20 mai 2025, certains modules montrent encore des erreurs. Nous pouvons dire que le n’est pas complet malgré les bases établis lors de la conception.
Example.
  
Généralités
Le préfix "xxx" NomVariable 
Toutes les fonctions ont leur propre combinaison de caractères qui est utilisé pour les rendre la variable unique et éviter les conflits de nommage entre les différentes fonctions
Session
Le lancement de l’orchestrateur doit se faire avec la session de l’utilisateur ayant les droits nécessaires pour opérer l’AD
Modélisation
Afin de suive les Exigences techniques dans le cahier de charge, pour Maintenance et évolutivité :
« Le code doit être modulaire pour permettre des extensions ou des mises à jour futures (par ex., ajout de nouvelles opérations ou intégration avec des outils tiers). Les fonctions principales doivent être réutilisables et indépendantes. (Par ex., même fonction de génération de mod de passe pour « Joiner » ou « Leaver » »
Il a été nécessaire de réimager le script initialement demandé. En effet, la création d’un seul et unique script de 2000 lignes n’est pas une solution viable. Une telle approche rendrait le code difficile à lire, à maintenir et à déboguer. De plus, cela irait à l’encontre des principes de la programmation modulaire.
Le script a donc été divisé en plusieurs modules, chacun ayant une responsabilité spécifique. Cela permet de mieux organiser le code, de faciliter la maintenance et d'améliorer la lisibilité. Cela permet de réutiliser des fonctions dans différents contextes sans avoir à dupliquer le code. 
 Convention de nommage 
Les modules
Les modules sont nommés avec le préfixe « TPI_TSK_ » pour les modules de tâches   ou « TPI_OPS_ » pour les modules de d’opération, suivi du nom désiré en fonction des actions à réaliser.
Exemple : 
« TPI_OPS_ResetPassword.psm1 » et de la même manière pour « TPI_TSK_SimpleLogExporter.psm1 »
Les fonctions 
Les fonctions sont nommées en suivant les recommandations des Verbes approuvés pour les commandes PowerShell  . Donc, un « verbe d’action » plus « - » plus « l’action é réaliser »
Exemple : 
Reset-ADUserPassword ou Get-ADUserBasicInfo ou New-RandomPassGeneration
Types des fonctions
Dans la section pour la convention de nommage nous avons évoqué le point pour les différents types de modules. Cela prend son sens ici. 
Bien que les modules d’opération contiennent des également des fonctions, celles-ci sont dépendantes des fonctions appartenant aux modules de tâches. Par conséquent, si les modules de tâches ne sont pas importés correctement ou sont défaillantes, les fonctions d’opérations ne pourront pas opérer correctement.
Fonctions d’opérations
Elles exécutent un ensemble de fonctions de tâche. 
Example : 
La fonction « Reset-ADUserPassword » appartient au module « TPI_OPS_ResetPassword.psm1 », comme l’indique son nom elle va changer le mot de passe du compte X. Sa correcte exécution dépend à son tour des fonctions de tâches telles que « Get-ADUserBasicInfo » qui va confirmer si l’utilisateur existe. Puis de la fonction « New-RandomPassGeneration » pour générer un mot de passé sécurisé et ainsi de suite.
Fonctions de tâche
Elles sont capables de réaliser des tâches dans le but d’obtenir un résultat spécifique. 
 Exemple : 
« New-RandomPassGeneration » appartiennent à un module « TPI_TSK_XXX.psm1 ».  Et dépend uniquement du système pour retourner un mot de passe.

Configurations 
Afin de réduire les modifications directes dans les lignes de code. Un standard a été établi sur la base de fichiers de configurations contenant les donnes dans un format HahsTable  dont deux paires de valeurs sont obligatoires
    Type = "value0"	et 	Name = "value1"
Ce système devient très utile au moment de réaliser des opérations de masse ou lors des automatisations. Puisque les paramètres restent dans le même format, il est possible de créer autant de fichier de configuration que l’on souhaite. Cela permet une meilleure organisation 
Exemple
 
Backups.conf
Contient les informations nécessaires pour sen connecter dans Azure et un vCenter
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

Menu.conf
Contient les informations nécessaires pour afficher le menu des opérations
@{  
    Type = "Menu";
    Name = "UI";
    Options = "Joiner","Suspension","Leaver","Review","Reset Password"
}
SMTP.conf
Contient les informations nécessaires pour envoyer un email (server + body)
@{  
    Type = "Server";
    Name = "ResetPassword";
    SmtpServer = "172.16.3.100";
    Port = "25";
    From = "TestRoport@beemusic.ch";
}
Ou bien 
@{  
    Type = "Server";
    Name = "fnzSMTP";
    SmtpServer = "SMTP.beemusic.ch";
    Port = "25";
    From = "TestRoport@fnz.com";
    To = "sergio.jimenez@fnz.com","admin@sergio.jimenez.ch";
}
Ou bien, un code HTML
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
Pour bien comprendre ce format, nous pouvons les assimiler à des blocks. L’avantage d’utiliser ce format est que nous pouvons les assembler de la manière qui nous convient les mieux. 
Se référer à la fonction Send-CustomEmailReport pour en savoir plus
Debug
Pour autant que la session reste ouverte après la fermeture de l’orchestrateur, il est possible d’utiliser la commande Get-Help   pour obtenir de l’aide sur les fonctions. En effet, toutes les fonctions contiennent au minimum les points suivants.
. NOTES    .SYNOPSIS    .DESCRIPTION    .PARAMETER     .EXAMPLE    .OUTPUT .LINK 
De plus,   presque tous les lignes de script contiennent des Write-Host commentés et qui peuvent aide    dans le suivi de l’exécution dans les étapes importantes

Exemple : La fonction pour l’opération « Review » 

 
Orchestrateur
L’Orchestrator agit comme intermédiaire entre l’utilisateur et les modules. Voici un aperçu des interactions  
Aperçu du script
Orchetrator.ps1 est au sommet des module et ajoute la couche UI ou interface utilisateur pour une expérience « User Friendly »
Pour éviter de modifier le script, il est possible de rajouter des opérations les rajoutant de puis le fichier de configuration (.\config\Menu.conf) 
        Il est possible de rajouter des opérations en rajoutant le nom de l'opération dans la liste $intOprerationList et en créant le module d'opération correspondant.

Modules
Dans cette section nous allons parcourir les modules el les fonctions. Bien que les modules puissent être de fonctions, le principe d’in module est qu’ils peuvent contenir un ensemble de fonctions comme c’est le cas de « TPI_TSK_ShortTools.psm1 » la raison principale pour laquelle il y ait des modules contenant une seule fonction est le nombre de lignes de la fonction.
Modules d’opération
Les modules d’opération se caractérisent par leur dépendance des fonctions dans le modules de tâche.
TPI_OPS_BackupAzureVM.psm1
TPI_OPS_BackupVcenterVM.psm1
TPI_OPS_Joiner.psm1
TPI_OPS_Leaver.psm1
TPI_OPS_ResetPassword.psm1
TPI_OPS_Review.psm1
TPI_OPS_Suspension.psm1
Get-VMsFromAzure
DESCRIPTION
Cette fonction permet de se connecter à une liste d'entités Azure et retrouver la liste des machines virtuelles appartenant à un utilisateur
Elle utilise les informations d'identification fournies dans le fichier « Backup.conf »
Etant donne que l’environnement azure peuvent être très différents, il n'est pas possible d'adapter la fonction pour chaque environnement. En effet, du fait que Microsoft encourage l'utilisation de l'authentification à deux facteurs, cela peut causer de nombreux problèmes de connexion.
La fonction a donc été conçue dans une perspective d'automatisation suivante.
Prérequis :
- PowerShell 7 ou supérieur
- Les module Az.XXXXX et Microsoft.Graph installés et importés.
- Une application dans Entra ID avec autorisation Impersonation pour Microsoft Graph et Custon Azure roll 
- Un certificat valide pour l'authentification.

PARAMETER Entities
Liste des entités Azure à traiter dans « Backup.conf », chaque entité doit contenir les informations suivantes :
- tenantId : ID du locataire Azure
- clientId : ID du client Azure
- certPath : chemin d'accès au certificat
- certName : nom du certificat
- type : type de l'entité (doit être "Azure")

Par defaut dans : ".\modules\config\Backup.conf". 

PARAMETER Users
Liste des utilisateurs à traiter. Chaque utilisateur doit être spécifié par son nom d'utilisateur au format SAN (SamAccoountName).
Dans une chine de caractères, le nom d'utilisateur doit être au format SAN (ex : Standar.User  ou Standar.User,Bee.Admin).
Chemin d'accès local où les fichiers CSV seront exportés.
EXAMPLE
GetVMsFromAzureEntities -azEntitiesList ".\modules\config\BackupCreds.conf" -localWorkspace "C:\Temp\AzureVMs" -Users "Standar.User,Bee.Admin"
OUTPUTS
La liste des machines virtuelles donc les utilisateurs sont dans la liste des utilisateurs fournie.


Get-VMsFromVcenters
DESCRIPTION
Cette fonction se connecte à chaque vCenter défini dans le fichier de configuration et récupère les machines virtuelles (VMs) dont l'annotation "Owner" correspond à l'un des utilisateurs fournis.
Elle retourne un tableau d'objets contenant les informations de base des VMs.
Le fichier déconfiguration par defaut est -->.\modules\config\Backups.conf
Les modules requis sont :  VMware.PowerCLI
PARAMETER Users
Liste des utilisateurs dont les VMs doivent être récupérées. 
EXAMPLE
Get-VMsFromVcenters -Users user1,user2
OUTPUTS
Un tableau d'objets contenant les informations de base des VMs ou $null si aucune donnée n'est collectée.
Set-NewPassworForADUser
DESCRIPTION
Cette fonction permet de réinitialiser le mot de passe d'un utilisateur Active Directory.
Elle reinitialise le mot de passe d'un utilisateur AD et envoie un e-mail avec le nouveau mot de passe à son manager ou une adresse e-mail spécifiée.
Si le manager n'est pas spécifié, la fonction demande à l'utilisateur de le saisir.
PARAMETER Users
Liste des utilisateurs à réinitialiser. Peut être une chaîne de caractères ou un chemin vers un fichier CSV/TXT contenant les utilisateurs
Si c'est une chaîne de caractères, elle doit être séparée par des virgules.
Si c'est un chemin vers un fichier, le fichier doit contenir une liste d'utilisateurs, un par ligne.
Exemple : "user1,user2,user3" ou "C:\path\to\file.csv"
Set-NewPasswordForADUser -Users "user1,user2,user3"

OUTPUTS
La fonction retourne un objet contenant les informations de l'utilisateur AD.
Par exemple, si l'utilisateur est trouvé, la fonction retourne un objet contenant le nom, le mot de passe et d'autres informations.

Add_JoinerFromUsersList
DESCRIPTION
Cette fonction permet de créer un utilisateur dans Active Directory avec deux options :
1. En fournissant une chaîne de caractères contenant les informations de l'utilisateur (user1,user2,user3).
    Elle vérifie si l'utilisateur existe déjà dans l'AD, sinon elle crée un nouvel utilisateur sur la base de l'utilisateur miroir. 
2. En fournissant un fichier CSV contenant les informations de l'utilisateur (.\file\path.csv). 
         Exemple de fichier CSV : Re référer au fichier csv  « AD_UserStructureTemplate.csv »       
PARAMETER Users
Liste d'utilisateurs au format CSV ou chaîne de caractères contenant les informations de l'utilisateur (user1,user2,user3).
Si un fichier est fourni, il doit être au format CSV ou txt : 
"Luc Lefevre,Paul Chevalier,Paul Fontaine,Sophie Moreau" 
OU 
".\file\templatePath.csv/txt (un utilisateur par ligne)"
PARAMETER Mirror 
Optionnel :
Nom d'utilisateur ou adresse e-mail d'un utilisateur miroir. 
Si un fichier est fourni, il doit être au format :  "email" ou "userName 

EXAMPLE
Add-JoinerFromUsersList -Users "user1,user2,user3" -Mirror "userMirror"
Add-JoinerFromUsersList -Users ".\file\path.csv" -Mirror "userMirror"
Add-JoinerFromUsersList -Users ".\file\templatePath.csv"
OUTPUTS
Une confirmation de la création de l'utilisateur dans Active Directory.
NOTE
Dû au fait des erreur d’importation de module, mentionnés au début de ce document, une demande d’analyse IA a été faite 
 
Solution appliquée (Il se peut que certaines lignes de code ne soient pas passé en revue)
 
Suspend-ADUsersFromList
DESCRIPTION
Cette fonction permet de suspendre les utilisateurs de l'AD à partir d'une liste. 
Elle désactive le compte utilisateur, change le mot de passe et empêche l'utilisateur de changer le mot de passe. La fonction prend en entrée une liste d'utilisateurs sous forme de chaîne ou de chemin vers un fichier CSV.
Variables Importantes :
$supUsersList : Liste des utilisateurs à suspendre
$supCurrentLocation : Emplacement actuel du script
$supLegacyPassGen : Chemin vers le module TPI_TSK_ShortTools pour exécuter paralèlement la focntion Use-RandomPassGenerator
$supValidSingleUser : Informations sur un utilisateur valide

Fonctions Importantes :
-	 Use-RandomPassGenerator (dans le module TPI_TSK_ShortTools nécessite une exécution sous PowerShell 5 inférieure)

PARAMETER Users
Liste des utilisateurs à suspendre. Peut-être une chaîne de noms d'utilisateur séparés par des virgules ou un chemin vers un fichier CSV contenant les noms d'utilisateur.
Exemple : user1,user2,user3 ou "C:\Path\To\users.csv"
EXAMPLE
Suspend-ADUsersFromList -Users user1,user2,user3
Suspend-ADUsersFromList -Users "C:\Path\To\users.csv"
OUTPUTS
La fonction ne renvoie pas de valeur, mais elle affiche des messages d'état pour chaque utilisateur traité. Elle affiche également un message d'erreur si l'utilisateur n'existe pas ou n'est pas valide.
Start-ADDeactivatedUsersReview
DESCRIPTION
Cette fonction permet de passer en revue les comptes inactifs dans Active Directory. Elle recherche les comptes inactifs, affiche une liste et propose des options pour supprimer ou saisir manuellement des comptes à supprimer.
Elle utilise la fonction Show-OptionsMenuToSelect pour afficher un menu d'options à l'utilisateur. La fonction utilise également la fonction Use-TextResizer pour formater les noms d'utilisateur et les afficher de manière lisible.
La fonction utilise la fonction Confirm-AlwaysReadHost pour demander à l'utilisateur de saisir une liste de comptes à supprimer manuellement.
Elle ne contient pas de paramètres d'entrée, mais elle utilise des variables internes pour stocker les informations sur les comptes inactifs.
 Variables Importantes :
$rewListUsersToReview : Liste des comptes inactifs trouvés dans AD
$rewReviewdUserList : Liste des comptes inactifs avec des informations sur le nom complet, le 
$rewValidSingleUser : Informations sur un compte inactif spécifique

EXAMPLE
Start-ADDeactivatedUsersReview
Cette commande exécute la fonction Start-ADDeactivatedUsersReview
OUTPUTS
La fonction renvoie la liste des comptes inactifs trouvés dans AD. Avec des informations sur le nom complet, le nom de compte, la date du dernier changement de mot de passe et l'état de verrouillage.
Cette liste est stockée dans la variable $rewReviewdUserList et au moment de l'affichage, elle est triée par nom complet dans un ordre croissant (A-Z).
LINK
Remove-LeaverUsersFromAD 
DESCRIPTION
Cette fonction permet de désactiver les utilisateurs AD et les déplacer dans l'OU CompanyLeaverTemp. Elle utilise la fonction Get-ADUserBasicData pour récupérer les informations de l'utilisateur. Elle utilise également la fonction Use-RandomPassGenerator pour générer un mot de passe aléatoire.
PARAMETER Users
Liste des utilisateurs à désactiver. Peut-être une chaîne de caractères ou un chemin vers un fichier CSV/TXT contenant les utilisateurs
Si c'est une chaîne de caractères, elle doit être séparée par des virgules.
Si c'est un chemin vers un fichier, le fichier doit contenir une liste d'utilisateurs, un par ligne.
Exemple : "user1,user2,user3" ou "C:\path\to\file.csv"

EXAMPLE
Cette commande désactive les utilisateurs user1, user2 et user3 dans Active Directory.
Remove-LeaverUsersFromAD -Users "user1,user2,user3"
Cette commande désactive les utilisateurs spécifiés dans le fichier Users.txt dans Active Directory.
Remove-LeaverUsersFromAD -Users "C:\Users\Administrator\Desktop\ActiveDirectory\Users.txt"

OUTPUTS
S'il n'y a pas d'erreurs, pour chaque utilisateur traité, la fonction retourne un message indiquant que le traitement a été effectué avec succès.
Par exemple, 
    	Traitement de :                             	Yan.Rousseau
Changement de mot de passe :                    	Success
Eviter le changement de mot de passe :         	Success
Pas de groupes AD trouvés pour ce compte (si applicable)
Mise à jour de la description :       		Success
Déplacement vers l'OU CompanyLeaverTemp :       	Success
Modules de tâches
TPI_TSK_AlwaysReadHost.psm1
TPI_TSK_ConvertAnyText2Normal.psm1
TPI_TSK_CopyADUserMemberships.psm1
TPI_TSK_GetADUserBasicData.psm1
TPI_TSK_SendCustomEmailReport.psm1
TPI_TSK_ShortTools.psm1 (Contient des fonctions très courtes)
TPI_TSK_ShowOptionsMenuToSelect.psm1

Convert-AnyText2Normal
DESCRIPTION
Cette fonction permet de supprimer les accents des mots. Remplacer les caractères spéciaux par leur manuellement et mettre en majuscules ou minuscules si nécessaire. Elle utilise la méthode Normalize de la classe System.String pour normaliser le texte et la méthode GetUnicodeCategory de la classe System.Globalization.CharUnicodeInfo pour identifier les caractères non accentués.

Lors des tests de la fonction, il a été observé que la méthode Normalize ne supprimait pas tous les accents des caractères spéciaux.
Par exemple, le caractère "ß" est remplacé par "ss" et le caractère "ö" est remplacé par "oe". De même, la fonction nécessite d'être exécutée dans un environnement PowerShell 7 ou supérieur.
PARAMETER text
Le texte à normaliser. Comme "L'été de Sußie avec Jösè, ça l'a fatiguée l'œuf"
PARAMETER Replace
Un dictionnaire manuel. Par exemple, @{ "ß" = "ss"; "ö" = "oe" }
Un autre cas observé c'est lors de la création d'un nom d'OU dans Active Directory. En effet, si le nom d'OU est composé d'un seul mot, il faut vraiment faire attention aux espaces avant et après le nom de l'OU. Car cela peut créer des erreurs.
Par exemple, si le nom de l'OU est "OU= Test" au lieu de "OU=Test"
Solution, la fonction Convert-AnyText2Normal peut être utilisée non seulement pour normaliser le nom de l'OU mais aussi pour remplacer ses espaces ou supprimer.
Par exemple, "= " vers "=" la composition serait @{ "= " = "=" }
PARAMETER Lower
Si vrai, le texte sera converti en minuscules.
PARAMETER Upper   
Si vrai, le texte sera converti en majuscules.
EXAMPLE
Convert-AnyText2Normal -Text "L'été de Sußie avec Jösè, ça l'a fatiguée l'œuf" 
Ou bien
Convert-AnyText2Normal -Text "L'été de Sußie avec Jösè, ça l'a fatiguée l'œuf" -Replace @{ "ß" = "ss"; "ö" = "oe" } -Lower $true
OUTPUTS
Un texte normalisé sans accents et sans caractères spéciaux et sans spaces si demandé dans le paramètre -Replace.


Confirm-AlwaysReadHost
DESCRIPTION
Cette fonction est une version améliorée de Read-Host qui demande à l'utilisateur de saisir une valeur et continue de le faire jusqu'à ce qu'une valeur fournie. 
Elle affiche un message d'aide si l'utilisateur ne fournit pas de valeur après X tentatives. Le nombre de tentatives, le message d'aide et le message de remerciement peuvent être personnalisés.
PARAMETER Counts
Le nombre de tentatives autorisées avant d'afficher un message d'aide. 
Par défaut, il est défini sur 3. 
Il est possible de cacher le nombre de tentatives an commentant le ligne à partir de "(attempt $arhAptem of $arhCount)"
PARAMETER Thank
Le message de remerciement à afficher après une saisie réussie. 
Par défaut, il est défini sur "Tank you!".
PARAMETER Message
Le message à afficher lors de la demande de saisie. 
Par défaut, il est défini sur "Entrez une valeur ".
PARAMETER MessageAide
Le message d'aide à afficher si l'utilisateur ne fournit pas de valeur après X tentatives. Par défaut, il est défini sur "Veuillez fournir queleque chose au moins ".
EXAMPLE
Confirm-AlwaysReadHost -Counts 5 -Message "Entrez une adresse email" -MessageAide "Please provide something at least!"
# Demande à l'utilisateur de saisir une adresse e-mail et continue de le faire jusqu'à ce qu'une valeur soit fournie. 
# Affiche un message d'aide après 5 tentatives infructueuses.
EXAMPLE
Confirm-AlwaysReadHost -Counts 3 -Message "Entrez une valeur" -Thank "Merci!"
# Demande à l'utilisateur de saisir une valeur et continue de le faire
OUTPUTS
Renvoie la valeur saisie par l'utilisateur.

Copy-ADUserMemberships
DESCRIPTION
Cette fonction permet de répliquer les groupes d'un utilisateur dans un autre utilisateur.
PARAMETER Mirror
L'utilisateur (au format SAN) dont les groupes seront copiés.
PARAMETER Targets
Les utilisateurs cibles (au format SAN) qui recevront les groupes de l'utilisateur miroir.
EXAMPLE
Opération simple 1 to 1
Copy-ADUserMemberships -Mirror "source.user" -Target "target.user"
Ou bien 
Operation simple 1 to n (Bulk mode) ou les destinataires sont séparés par une virgule.
Copy-ADUserMemberships -Mirror "source.user" -Target target.user, target.user1, target.user2 
Get-ADUserBasicData
DESCRIPTION
Cette fonction permet de vérifier si un utilisateur existe dans Active Directory en fonction de son adresse e-mail ou de son nom d'utilisateur.
Elle retourne un objet contenant des informations sur l'utilisateur, y compris son existence, son chemin d'OU et son nom d'utilisateur.
PARAMETER User
L'adresse e-mail ou le nom d'utilisateur de l'utilisateur à vérifier.
EXAMPLE
Get-ADUserBasicData -Users "monUser"
Get-ADUserBasicData -Users monUser@example.ch
Get-ADUserBasicData -Users "monUser@example.ch, monUser"

OUTPUTS
Trois résultats sont attendus :
1. Exists $true/$false si l'utilisateur existe ou pas
2. OU  le chemin de l'utilisateur dans l'AD
3. Name le nom de l'utilisateur dans l'AD
4. Email l'adresse email de l'utilisateur dans l'AD
5. Manager, s'il existe le manager de l'utilisateur dans l'AD
Send-CustomEmailReport
DESCRIPTION
Cette fonction envoie un email en utilisant un modèle et un serveur SMTP spécifiés dans un fichier de configuration. Elle assemble les informations du serveur SMTP, du modèle d'email et du contenu de l'email avant de l'envoyer.
Le fichier de configuration doit être au format HashTable 
Variables Importantes :
$esrSMTPServerName : Nom du Template pour le serveur SMTP
$esrMailTemplateName : Nom du Template pour le mail
$esrValidMailBodyData : Contenu du mail 
$esrPathMailConfig : Chemin vers le fichier de configuration
$esrValidMail : Contenu du mail assemblé

Fonctions Utilisés :
- Get-Content
- Invoke-Expression
- Send-MailMessage
PARAMETER Template
Nom du Template pour le mail. Il est reporté dans la variable $esrMailTemplateName
PARAMETER Server
Nom du Template pour le serveur SMTP. Il est reporté dans la variable $esrSMTPServerName (Le Template par défaut ne contient pas d'identifiant pour le serveur SMTP)
PARAMETER Content
Contenu du mail. Il est reporté dans la variable $esrValidMailBodyData
PARAMETER Config
Chemin vers le fichier de configuration. Par défaut, il est défini sur ".\modules\config\SMTP.conf"
PARAMETER AdditionalConfig
Configuration supplémentaire pour le mail à envoyer. Il est reporté dans la variable $esrAdditionalConfig
Il est utile par pour customiser le destinataire ou le sujet ou les cc 
EXAMPLE
Send-CustomEmailReport -Template "ResetPassword" -Server "fnzSMTP" -Content "Ceci est un test de l'envoi d'un email"
Cette commande envoie un email en utilisant le modèle "ResetPassword" et le serveur SMTP "fnzSMTP" avec le contenu spécifié.
EXAMPLE
$esrMailContent = "Ceci est un test de l'envoi d'un email"
$ServerName = "fnzSMTP"
$TemplateName = "ResetPassword"
Send-CustomEmailReport -Template $TemplateName -Server $ServerName -Content $myMailContent [-Config ".\modules\config\SMTP.conf" -AdditionalConfig $myAdditionalConfig]

OUTPUTS
Aucun
Note : Pour la réalisation de l’assemblage, il a été nécessaire de faire recours IA.
 
Use-SimplePatternMatcher
DESCRIPTION
Cette fonction vérifie si une chaîne de caractères correspond à un motif spécifique déjà défini. Elle retourne un booléen indiquant si la correspondance a été trouvée ou non.
PARAMETER Type
Le type de motif à vérifier. Les types disponibles sont : "ou", "mail", "domain", "pathtxt", "pathcsv".
PARAMETER String
La chaîne de caractères à vérifier.
EXAMPLE
Use-SimplePatternMatcher -Type "ou" -String "OU=Informatique,OU=Company"
Use-SimplePatternMatcher -Type "mail" -String "username@example.com"
Use-SimplePatternMatcher -Type "domain" -String "example.com"
Use-SimplePatternMatcher -Type "pathtxt" -String ["C:\Path\To\File.txt" ou ".\Path\To\File.txt"]
Use-SimplePatternMatcher -Type "pathcsv" -String ["C:\Path\To\File.csv" ou ".\Path\To\File.csv"]
OUTPUTS
Un booléen indiquant si la correspondance a été trouvée ou non.
Use-CustomWorkingDirectory
DESCRIPTION
Cette fonction crée un répertoire de travail basé sur la date actuelle. Le répertoire est créé dans un répertoire parent spécifié ou le répertoire par défaut si aucun n'est spécifié.  
PARAMETER ParentDir
Le répertoire parent dans lequel le répertoire de travail sera créé. Si aucun répertoire parent n'est spécifié, un répertoire par défaut sera utilisé.
EXAMPLE
La fonction est appelée sans paramètre, elle utilisera le répertoire par défaut.
Use-CustomWorkingDirectory 
La fonction peur être appelée avec paramètre, elle utilisera le répertoire par défaut.
Use-CustomWorkingDirectory -ParentDir "C:\Mon\Propre\Chemin\"
OUTPUTS
Chemin du répertoire de travail par défaut : "C:\TPI-ScriptLogs\dd-MM-yy_hh-mm-ss"
Chemin du répertoire de travail spécifié : "C:\Mon\Propre\Chemin\dd-MM-yy_hh-mm-ss"
Use-RandomPassGenerator
DESCRIPTION
Cette fonction génère un mot de passe aléatoire complexe de la longueur spécifiée. Le mot de passe contient des lettres majuscules, minuscules, chiffres et caractères spéciaux.
Elle utilise l'API System.Web.Security pour garantir la complexité du mot de passe. Elle doit être lancée avec powerShell 5.1. Car elle utilise la fonction GeneratePassword de l'API System.Web.Security. quie n'esplt pas disponible dans PowerShell Core.
PARAMETER -Length
La longueur du mot de passe à générer. La valeur par défaut est 15 caractères.
EXAMPLE
Use-RandomPassGenerator -Length 12
OUTPUTS
Un mot de passe aléatoire complexe de la longueur spécifiée.
Exemple : "A1b2C3d4E5f6G7h8"
Use-TextResizer
DESCRIPTION
Cette fonction permet de réduire un texte à une taille spécifique. Si le texte est plus long que la taille spécifiée, il sera tronqué et remplacé par "..." à la fin. C’est utile pour rendre les outputs plus lisibles. 
PARAMETER label
Le texte à réduire.
PARAMETER width
La largeur maximale du texte pour appliquer la réduction.
PARAMETER last
Le suffixe à ajouter à la fin du texte réduit. Par défaut, il est défini sur "...". Si "Ignore" est spécifié, aucun suffixe ne sera ajouté.
EXAMPLE
Use-TextResizer "This is a very long line of text line" 21
$malimite = 21
$extraLong = "This is a very long line of text line"
Write-Host (Use-TextResizer -label "And extra long line would work?" -Width 20) -NoNewline
Write-Host $extraLong -ForegroundColor Yellow

OUTPUTS
Un texte rétréci
Use-LogsExporter
DESCRIPTION
Cette fonction permet de réduire un texte à une taille spécifique. Si le texte est plus long que la taille spécifiée, il sera tronqué et remplacé par "..." à la fin. C’est utile pour rendre les outputs plus lisibles. 
PARAMETER logMessage
Le texte à réduire.
PARAMETER directory
La largeur maximale du texte pour appliquer la réduction.
EXAMPLE
TPI-LogsExporter -logMessage "Test message" -directory "C:\Logs"
OUTPUTS
Information vous indiquant où se trouve le fichier log
Show-OptionsMenuToSelect
DESCRIPTION
Ce script permet d'afficher un menu d'options en boucle et retourne l'option sélectionnée par l'utilisateur. Il utilise la fonction Read-Host pour demander à l'utilisateur de sélectionner une option parmi une liste d'options.
La fonction utilise également la fonction Write-Host pour afficher les options et les messages d'erreur. Elle utilise des numéros pour identifier les options et une boucle do-while pour valider la sélection de l'utilisateur.
Ce que l'utilisateur doit faire c'est de sélectionner une option (un numéro) parmi la liste d'options affichée.
PARAMETER Options
L'adresse e-mail ou le nom d'utilisateur de l'utilisateur à vérifier.
EXAMPLE
Il est possible de créer une liste d'options dynamiques, par exemple, en ajoutant des options supplémentaires.
$testlist = @("Joiner", "Suspension", "Leaver", "Review", "Resetpassword", "BackupAzureVM", "BackupVcenterVM")
 Show-OptionsMenuToSelect -Options ($testlist + "Exit")
EXAMPLE
La puissance de la fonction réside dans le fait qu'elle peut être utilisée dans n'importe quel script, par exemple, avec case ou bien switch dont le nom de l'option est peut-être dans une variable.

$rewOption1 = "Supprimer"
$rewOption2 = "Saisir manuellement"
$rewOption3 = "Annuler"
$rewOptionsList = @("$rewOption1", "$rewOption2", "$rewOption3")
$rewValidOption = Show-OptionsMenuToSelect -Options $rewOptionsList
switch ($rewValidOption) "$rewOption1"<mon script 1>} "$rewOption2"{<mon script 2>} "$rewOption3"{<mon script 3>} }

OUTPUTS
La fonction retourne l'option sélectionnée par l'utilisateur.
Par exemple, si l'utilisateur sélectionne "Joiner", la fonction retourne "Joiner".
Conclusion
Cette suite de scripts reste modifiable et cette version peut être déjà obsolète
