<#
    .Description
    desinstal l'agent FusionInventory et install GLPI Agent .
    il faut préalable tou copier dans un partage accécible en lecture a tous les pc du domaine ($ScriptDir=\\partage.local\deploiment\agent_glpi\)
    - GLPI-Agent-1.4-x64.msi;GLPI-Agent-1.4-x86.msi et votre fichier.pem ainssi que le scripte.ps1 .
	
	
#>

# recuperation de l'amplacement du script
$ScriptDir = "https://github.com/sysadminexact/glpi/GLPI-Exact.ps1"


Write-Host "Current script directory is $ScriptDir"
# decomanter pour forcer la variable #$ScriptDir
#$ScriptDir="\\partage.local\deploiment\agent_glpi\"
$cacertfile="agent.srv.glpi.pem"
$serveur="XXXXXXXXXXXXXXXXX"
## 
if ( $([System.Environment]::Is64BitOperatingSystem) -eq $True ){
$MSI = "https://github.com/glpi-project/glpi-agent/releases/download/1.6.1/GLPI-Agent-1.6.1-x64.msi" 
}else {
$MSI = "https://github.com/glpi-project/glpi-agent/releases/download/1.6.1/GLPI-Agent-1.6.1-x86.msi" 
}
$installDir="C:\Program Files\GLPI-Agent"
$IDfile="$installDir\ID_gpo_install.csv"
$ipdeploiment="0004"
$Param=" /quiet SERVER='$serveur' ADD_FIREWALL_EXCEPTION=1 QUICKINSTALL=1 ADDLOCAL=ALL LOGFILE_MAXSIZE=10 RUNNOW=1 LISTEN=1 EXECMODE=1 DEBUG=1 CA_CERT_FILE=`"$installDir\$cacertfile`" INSTALLDIR=`"$installDir`""
$unistallParam=" /X {E1BE6C18-6BF4-1014-844A-F1F114E3EA24} /quiet"
$install=$false
if ($(Test-Path $IDfile) -eq $false )  {
$install=$true
}
else {
    $IDtab = Import-Csv -Path $IDfile 
    $idinstall = $IDtab.ID
    if ( $ipdeploiment -eq $idinstall ){
        Start-Process -FilePath "$installDir\glpi-agent.bat" -Wait -WorkingDirectory  $installDir
    } else {
        $install=$true
    }
}

if ($(Test-Path $MSI ) -eq $false) {
	$install=$false
}

if ($install -eq $true)
{
## on desinstalle fusion si il et présent
    if ($(Test-Path "C:\Program Files\FusionInventory-Agent\Uninstall.exe") -eq $true ) 
    {
    Start-Process -FilePath "C:\Program Files\FusionInventory-Agent\Uninstall.exe" -ArgumentList "/S" -Wait -WorkingDirectory  "C:\Program Files\FusionInventory-Agent\"
    }

    if ($(Test-Path "C:\Program Files (x86)\FusionInventory-Agent\Uninstall.exe") -eq $true ) 
    {
    Start-Process -FilePath "C:\Program Files (x86)\FusionInventory-Agent\Uninstall.exe" -ArgumentList "/S" -Wait -WorkingDirectory  "C:\Program Files (x86)\FusionInventory-Agent\"
    }
## on install GLPI Agent
Write-Host "/i $MSI $Param"

New-Item "$installDir" -ItemType Directory
Copy-Item -Path "$ScriptDir\$cacertfile" -Destination "$installDir\$cacertfile"
Start-Process -FilePath "$env:systemroot\system32\msiexec.exe" -ArgumentList "$unistallParam" -Wait -PassThru -WorkingDirectory  $ScriptDir
$process = Start-Process -FilePath "$env:systemroot\system32\msiexec.exe" -ArgumentList "/i $MSI $Param " -Wait -PassThru -WorkingDirectory  $ScriptDir
if ($($process.ExitCode) -eq "0"){
    "ID" | Out-File -FilePath $IDfile  -Encoding 'UTF8'
    $ipdeploiment | Out-File -FilePath $IDfile  -Append  -Encoding 'UTF8'
}
}
