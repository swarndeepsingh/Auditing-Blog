 #Run following as administrator window

 Param(
[Parameter(Mandatory=$true)][string] $script:configfile
 )
 $script:utilitypath=''
 $script:auditdata=''
 $script:auditout=''
 $script:s3path=''
 #$script:configfile='C:\aws-sql-migration-automation\auditing\EC2\scripts\config.json'
 
 
 function read-config()
 {
    $config = Get-Content $script:configfile | out-string | ConvertFrom-Json 
    $sqlserver=$config.config.sqlserver| Out-String
    $script:auditdata=$config.config.auditdata| Out-String
    $script:auditout=$config.config.auditout| Out-String
    $script:s3path=$config.config.s3path| Out-String
    $script:utilitypath=$config.config.utilitiespaths| Out-String
 
    
    create-path($script:auditdata)
    create-path($script:auditout)
    create-path($script:s3path)
    create-path($script:utilitypath)
    
 }
 
 function create-path($path)
 {
     $path= $path.Replace("`r`n","")
     write-host("Testing path $path")
 
 
     if(!(Test-Path -Path $path  ))
     {
         write-host "path not found"
         $newitem = @{
             Path =$path
             ItemType ='Directory'
             Force =$true
         }
         write-host "Creating path $path"
         New-Item @newitem
     }
     else
     {
         write-host ("$path already exists")
     }
 } 
 
 function download-tools ($utilpath)
 {
     $utilpath = $utilpath.Replace("`r`n","")
     write-host("Test path $utilpath")
     cd $utilpath
    
     if(!(Test-Path -Path 'git.exe'))
     {
         # download git
         write-host('downloading Git')
        wget https://github.com/git-for-windows/git/releases/download/v2.27.0.windows.1/Git-2.27.0-64-bit.exe -outfile git.exe
     }

     if(!(Test-Path -Path 'sqlcmdlineutility.msi'))
     {
         # download sql libraries (required on host where SQL is not installed)
         write-host('downloading sqlcmdlineutility.msi')
         wget  https://go.microsoft.com/fwlink/?linkid=2082695  -outfile sqlcmdlineutility.msi
     }
 
     if(!(Test-Path -Path 'python-3.7.7.exe'))
     {
         # download python 3.7.7
         write-host('downloading python-3.7.7.exe')
         wget https://www.python.org/ftp/python/3.7.7/python-3.7.7.exe -outfile python-3.7.7.exe
     }
 
 
 
 }
 
 function install-tools($utilpath)
 {
     $utilpath = $utilpath.Replace("`r`n","")
     cd $utilpath
 
        # install sql libraries
     msiexec /i $utilpath\sqlcmdlineutility.msi /qn  IACCEPTMSSQLCMDLNUTILSLICENSETERMS=YES
 
     # install python
     .\python-3.7.7.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
 }
 
 
 read-config
 download-tools($script:utilitypath)
 install-tools($script:utilitypath)
 
  
 