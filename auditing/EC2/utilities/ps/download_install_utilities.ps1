#Run following as administrator window

$path='c:\aws\utilities'
if(!(Test-Path -Path $path ))
{
    write-host "path not found"
    $newitem = @{
        Path = $path
        ItemType ='Directory'
        Force =$true
    }
    New-Item @newitem
}

wget  https://go.microsoft.com/fwlink/?linkid=2082695  -outfile $path\sqlcmdlineutility.msi

msiexec /i $path\sqlcmdlineutility.msi /qn  IACCEPTMSSQLCMDLNUTILSLICENSETERMS=YES

