param([string]$modsSource, [string] $to="", [string] $name="")

./AlterModInfoFiles.ps1 -To $modsSource

# Builds a zip file of current mods from the solution for uploading to GitHub release.
# Mods with version < 100 are not included in the zip.

# This can be configured as an external tool (Tools > External Tools) in Modbuddy with settings
# Name: Build Release
# Command: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
# Arguments: -file "CreateRelease.ps1"
# Initial Directory: "$(SolutionDir)"

# Unfortunately there doesn't seem to be a generic way to get the Civ6 local mods path within Modbuddy.
# So if you've got it somewhere besides the default (is that even possible?) you'll need to specify it 
# by adding a -ModsSource argument to the external tools arguments above.
if ($modsSource -eq "") {
  $modsSource = Join-Path $env:USERPROFILE "Documents\My Games\Sid Meier's Civilization VI\Mods"
}

$outputName = Get-Date -Format "yyyy_MM_dd_HH_mm"
if ($name -ne "") {
  $outputName = $outputName + "_" + $name
}
$outputName = Join-Path $to $outputName

# Get source mods directories
$moddirs = Get-ChildItem -Directory
foreach ($match in $moddirs) {
  $source = Join-Path $modsSource $match.Name
  $modVersion = [int] (Select-String -Path (Join-Path $source "*.modinfo") -Pattern 'version="(\d+)"' | Select-Object -First 1).Matches.Groups[1].Value
  if ($modVersion -ge 100) {
    Compress-Archive -Update -Path $source -DestinationPath $outputName
    Write-Host "[$match] Added to" $outputName
  } else {
    Write-Host "[$match] Skipped"
  }
}

Write-Host
Write-Host "Created zip $outputName"
Write-Host