Param([Parameter(Mandatory=$true)][string]$folder
, [Parameter(Mandatory=$true)][string]$extension
, [Parameter(Mandatory=$true)][string]$s3localfolder
)

function scan($folder)
{
    Get-ChildItem "$folder" -Filter *.$extension |
    foreach-object {
        #call python here
        try 
        {
                # convert to parquet
                $status=python convert_to_parquet.py  $_.FullName $s3localfolder
                if(-not (Test-Path -Path "$folder\processed" ) )
                {
                    New-Item -Path  -ItemType Directory
                }
                move-item $_.FullName "$folder\processed\"
        }
        
        catch 
        {
            write-host ("Error:" + $status +"`n`n")
        }
        
    }

}

scan($folder)