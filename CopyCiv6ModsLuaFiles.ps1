param([string] $from, [string] $to="")

## Copies all lua files in mods in modbuddy projects into the mods in the Civ6 mods folder.
## Do this because you can't do a build of the Modbuddy solution as Civ6 locks the folders 
## containing lua files and the build command will attempt to delete them and error out.  In order to 
## succeed you have to exit the Civ6 game (to main menu is sufficient) then build and restart the game.
## That's a super slow development cycle.  Fortunately Civ6 will reload lua files (for ui) and allow 
## you to re-include them (in FireTuner) if they are edited in place.  Unfortunately, that's not 
## an inherently great solution because the files edited are generated as part of the build process
## (they're copies of the "real" code in the Modbuddy solution).   So once editted you need to copy
## the edits back to the real sources in Modbuddy.  Not very convenient!  This script serves as an 
## alternate "build" command that allows editing the lua code in Modbuddy and then doing a very quick 
## "build" to get it running in Civ6.

## This can be configured as an external tool (Tools > External Tools) with settings
## Name: Quick Build Lua Scripts
## Command: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
## Arguments: -file "$(SolutionDir)CopyCiv6ModsLuaFiles.ps1" -From "$(SolutionDir)"

## Unfortunately there doesn't seem to be a way to get 
if ($to -eq "") {
  $to = Join-Path $env:USERPROFILE "Documents\My Games\Sid Meier's Civilization VI\Mods"
}

$matches = Get-ChildItem -Path $from -Recurse -Include "*.lua"
          
$matches | Copy-Item -Destination {
            $destination = Join-Path $to $_.FullName.Substring($from.length)
            Write-Host $_.FullName "\tto\t" $destination
            $destination
           }

Write-Host "Copied" $matches.count "lua files" 