param([string] $dir="")

# So there's an annoying number of things that you can do in a valid .modinfo file 
# that are not supported by modbuddy.  For example, you can have a LocalizedText element 
# that translates the mod name/description/teaser.  But there's no way to create this
# (as far as I can tell) within Modbuddy.  This script allows defining a modinfo_fixer.xml 
# file in the root directory of the mod that can be applied to alter the generated .modinfo
# file after ModBuddy creates it.

# This can be configured as an external tool (Tools > External Tools) in Modbuddy with settings
# Name: Fix ModInfo Files
# Command: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
# Arguments: -file "$(SolutionDir)AlterModInfoFiles.ps1"

function XSLT(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$InputFile,
     
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$Transform,
     
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$OutputFile
)
{
 
    try
    {
        $memoutput = New-Object System.IO.MemoryStream(1024)
        $Xslt = New-Object System.Xml.Xsl.XslCompiledTransform
        $Xslt.Load($Transform)
        $xmlWriter = [System.Xml.XmlWriter]::Create($memoutput, $Xslt.OutputSettings)
        $Xslt.Transform($InputFile, $xmlWriter)
        $xmlWriter.Close()
        #$memoutput.Seek(0, [System.IO.SeekOrigin]::Begin)
        $outputStream = New-Object System.IO.FileStream($OutputFile, [System.IO.FileMode]::Create)
        $memoutput.WriteTo($outputStream)
        $outputStream.Close()
    }
    catch
    {
        Write-Error $_.Exception
    }
}


if ($dir -eq "") {
  $dir = Join-Path $env:USERPROFILE "Documents\My Games\Sid Meier's Civilization VI\Mods"
}

$matches = Get-ChildItem -Path $dir -Recurse -Include ("modinfo_fixer.xml")
foreach ($match in $matches) {
  $modinfos = Get-ChildItem -Recurse -Path $match.Directory -Include ("*.modinfo")
  foreach ($modinfo in $modinfos) {
    XSLT -InputFile $modinfo.FullName -OutputFile $modinfo.FullName -Transform $match.FullName
    Write-Host Applied $match.FullName to $modinfo.FullName
  }
}

Write-Host "Updated" $matches.count "modinfo files" 