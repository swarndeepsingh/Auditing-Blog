Param(
    [Parameter(Mandatory=$true)][string]$script:configfile
)
$script:auditout=''
$script:extension='csv'
$script:s3path=''


function read-config()
{
    $config = Get-Content $script:configfile | out-string | ConvertFrom-Json 
    $script:auditout=$config.config.auditout| Out-String
    $script:s3path=$config.config.s3path| Out-String

    $script:auditout=$script:auditout.Replace("`r`n","")
    $script:s3path=$script:s3path.Replace("`r`n","")


} 


function convert_to_parquet()
{
    Get-ChildItem "$script:auditout" -Filter *.$extension |
    foreach-object {
        #call python here
        try 
        {
                # convert to parquet
                $status=python convert_to_parquet.py  $_.FullName $script:s3path=''
                if(-not (Test-Path -Path "$script:auditout\processed" ) )
                {
                    New-Item -Path  -ItemType Directory
                }
                move-item $_.FullName "$script:auditout\processed\"
        }
        
        catch 
        {
            write-host ("Error:" + $status +"`n`n")
        }
        
    }

}

read-config
convert_to_parquet