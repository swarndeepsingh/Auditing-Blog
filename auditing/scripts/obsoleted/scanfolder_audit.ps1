Param(
    [Parameter(Mandatory=$true)][string]$script:configfile
)
$script:auditout=''
$script:extension='csv'
$script:s3bucketname=''


function read-config()
{
    $config = Get-Content $script:configfile | out-string | ConvertFrom-Json 
    $script:auditout=$config.config.auditout| Out-String
    $script:s3bucketname=$config.config.s3bucketname| Out-String

    $script:auditout=$script:auditout.Replace("`r`n","")
    $script:s3bucketname=$script:s3bucketname.Replace("`r`n","")


} 


function convert_to_parquet()
{
    Get-ChildItem "$script:auditout" -Filter *.$extension |
    foreach-object {
        #call python here
        try 
        {
                # convert to parquet
                write-host "Convert to Parquet"  $_.FullName "to bucket" $script:s3bucketname "..."

                $status=python convert_upload_parquet.py $_.FullName $script:s3bucketname
                if(-not (Test-Path -Path "$script:auditout\processed" ) )
                {
                    New-Item -Path "$script:auditout\processed"  -ItemType "directory"
                }
                write-host "Moving file "  $_.FullName  " to archived\processed folder"
                move-item -Path $_.FullName -destination "$script:auditout\processed\"
        }
        
        catch [Exception]
        {
            write-host $_.Exception.Message
            write-host ("Error:" + $status +"`n`n")
        }
        
    }

}

read-config
convert_to_parquet