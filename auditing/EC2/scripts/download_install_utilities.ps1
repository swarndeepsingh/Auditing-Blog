 #Run following as administrator window

 $script:utilitypath=''
 $script:auditdata=''
 $script:auditout=''
 $script:s3path=''
 $script:configfile='C:\aws\scripts\config.json'
 
 
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
 
  
 