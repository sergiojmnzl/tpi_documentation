Here is a simple flow chart:
```mermaid
flowchart TD
    Orchestrator["Orchestrator<br/>Import des modules<br/>Execute les operations<br/>Execute des tâches"]

    subgraph left [Import de fonctions]
        Operations[Modules d’operation]
        Joiner[Joiner]
        Suspension[Suspension]
        Leaver[Leaver]
        Review[Review]
        BackupAzure[Backup Azure VM]
        BackupVMware[Backup VMware VM]
        Operations --> Joiner & Suspension & Leaver & Review & BackupAzure & BackupVMware
    end

    subgraph middle [HashTable Data]
        Configs[Configurations]
        Backups[Backups.conf]
        SMTP[SMTP.conf]
        Menu[Menu.conf]
        Configs --> Backups & SMTP & Menu
    end

    subgraph right [Modules de tâches]
        ShowOptions[Show-OptionsMenuToSelect]
        UseDir[Use-CustomWorkingDirectory]
        UsePass[Use-RandomPassGenerator]
        SendEmail[Send-CustomEmailReport]
        ConfirmHost[Confirm-AlwaysReadHost]
        GetUser[Get-ADUserBasicData]
        ConvertText[Convert-AnyText2Normal]
        CopyMemberships[Copy-ADUserMemberships]
        PatternMatch[Use-SimplePatternMatcher]
        TextResizer[Use-TextResizer]
        LogExporter[Use-LogsExporter]
    end

    Orchestrator --> Operations
    Orchestrator --> Configs
    Orchestrator --> ShowOptions
    ShowOptions --> UseDir & UsePass & SendEmail & ConfirmHost & GetUser & ConvertText & CopyMemberships & PatternMatch & TextResizer & LogExporter
```
