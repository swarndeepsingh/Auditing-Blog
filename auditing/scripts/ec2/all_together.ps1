#download and install utilities
cd C:\aws-sql-migration-automation\auditing\scripts
.\download_install_utilities.ps1 C:\aws-sql-migration-automation\auditing\scripts\config.json


# Setup databases and audits
cd C:\aws-sql-migration-automation\auditing\scripts\ec2
.\setupdbconfiguration.ps1 C:\aws-sql-migration-automation\auditing\scripts\config.json

#install python classes
pip install pandas
pip install pyarrow
pip install boto3
pip install s3parq

# extract data from audit binaries to CSV
cd C:\aws-sql-migration-automation\auditing\scripts
.\audit_to_csv.ps1 C:\aws-sql-migration-automation\auditing\scripts\config.json

cd C:\aws-sql-migration-automation\auditing\scripts
.\scanfolder_audit.ps1 C:\aws-sql-migration-automation\auditing\scripts\config.json