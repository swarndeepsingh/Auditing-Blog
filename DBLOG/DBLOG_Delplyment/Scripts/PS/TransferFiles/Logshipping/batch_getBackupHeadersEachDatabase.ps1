
cd c:\dblog

#AnnuityTransactions
.\batch_getBackupHeaders.ps1 -folder "\\10.18.25.251\NearLineBackup\SQLBackups\AN3\AN3PRODSQL01\AnnuityTransactions" -tool SQL -drservername LAAN4DRXSQL01 -full yes -diff no -trn no
.\batch_getBackupHeaders.ps1 -folder "\\10.18.25.251\NearLineBackup\SQLBackups\AN3\AN3PRODSQL01\AnnuityTransactions" -tool SQL -drservername LAAN4DRXSQL01 -full no -diff no -trn yes
.\batch_getBackupHeaders.ps1 -folder "\\10.18.25.251\NearLineBackup\SQLBackups\AN3\AN3PRODSQL01\AnnuityTransactions" -tool SQL -drservername LAAN4DRXSQL01 -full no -diff no -trn yes


#AnnuityProducts
.\batch_getBackupHeaders.ps1 -folder "\\10.18.25.251\NearLineBackup\SQLBackups\AN3\AN3PRODSQL01\AnnuityProducts" -tool SQL -drservername LAAN4DRXSQL01 -full yes -diff no -trn no
.\batch_getBackupHeaders.ps1 -folder "\\10.18.25.251\NearLineBackup\SQLBackups\AN3\AN3PRODSQL01\AnnuityProducts" -tool SQL -drservername LAAN4DRXSQL01 -full no -diff yes -trn no
.\batch_getBackupHeaders.ps1 -folder "\\10.18.25.251\NearLineBackup\SQLBackups\AN3\AN3PRODSQL01\AnnuityProducts" -tool SQL -drservername LAAN4DRXSQL01 -full no -diff no -trn yes


#FeedStaging
.\batch_getBackupHeaders.ps1 -folder "\\10.18.25.251\NearLineBackup\SQLBackups\AN3\AN3PRODSQL01\FeedStaging" -tool SQL -drservername LAAN4DRXSQL01 -full yes -diff no -trn no
.\batch_getBackupHeaders.ps1 -folder "\\10.18.25.251\NearLineBackup\SQLBackups\AN3\AN3PRODSQL01\FeedStaging" -tool SQL -drservername LAAN4DRXSQL01 -full no -diff yes -trn no
.\batch_getBackupHeaders.ps1 -folder "\\10.18.25.251\NearLineBackup\SQLBackups\AN3\AN3PRODSQL01\FeedStaging" -tool SQL -drservername LAAN4DRXSQL01 -full no -diff no -trn yes


#Lookups
.\batch_getBackupHeaders.ps1 -folder "\\10.18.25.251\NearLineBackup\SQLBackups\AN3\AN3PRODSQL01\Lookups" -tool SQL -drservername LAAN4DRXSQL01 -full yes -diff no -trn no
.\batch_getBackupHeaders.ps1 -folder "\\10.18.25.251\NearLineBackup\SQLBackups\AN3\AN3PRODSQL01\Lookups" -tool SQL -drservername LAAN4DRXSQL01 -full no -diff yes -trn no
.\batch_getBackupHeaders.ps1 -folder "\\10.18.25.251\NearLineBackup\SQLBackups\AN3\AN3PRODSQL01\Lookups" -tool SQL -drservername LAAN4DRXSQL01 -full no -diff no -trn yes


#security
.\batch_getBackupHeaders.ps1 -folder "\\10.18.25.251\NearLineBackup\SQLBackups\AN3\AN3PRODSQL01\Security" -tool SQL -drservername LAAN4DRXSQL01 -full yes -diff no -trn no
.\batch_getBackupHeaders.ps1 -folder "\\10.18.25.251\NearLineBackup\SQLBackups\AN3\AN3PRODSQL01\Security" -tool SQL -drservername LAAN4DRXSQL01 -full no -diff yes -trn no
.\batch_getBackupHeaders.ps1 -folder"\\10.18.25.251\NearLineBackup\SQLBackups\AN3\AN3PRODSQL01\Security" -tool SQL -drservername LAAN4DRXSQL01 -full no -diff no -trn yes

#System
.\batch_getBackupHeaders.ps1 -folder "\\10.18.25.251\NearLineBackup\SQLBackups\AN3\AN3PRODSQL01\System" -tool SQL -drservername LAAN4DRXSQL01 -full yes -diff no -trn no
.\batch_getBackupHeaders.ps1 -folder "\\10.18.25.251\NearLineBackup\SQLBackups\AN3\AN3PRODSQL01\System" -tool SQL -drservername LAAN4DRXSQL01 -full no -diff yes -trn no
.\batch_getBackupHeaders.ps1 -folder "\\10.18.25.251\NearLineBackup\SQLBackups\AN3\AN3PRODSQL01\System" -tool SQL -drservername LAAN4DRXSQL01 -full no -diff no -trn yes


#UI
.\batch_getBackupHeaders.ps1 -folder "\\10.18.25.251\NearLineBackup\SQLBackups\AN3\AN3PRODSQL01\UI" -tool SQL -drservername LAAN4DRXSQL01 -full yes -diff no -trn no
.\batch_getBackupHeaders.ps1 -folder "\\10.18.25.251\NearLineBackup\SQLBackups\AN3\AN3PRODSQL01\UI" -tool SQL -drservername LAAN4DRXSQL01 -full no -diff Yes -trn no
#.\batch_getBackupHeaders.ps1 -folder "\\10.18.25.251\NearLineBackup\SQLBackups\AN3\AN3PRODSQL01\UI" -tool SQL -drservername LAAN4DRXSQL01 -full no -diff no -trn yes

