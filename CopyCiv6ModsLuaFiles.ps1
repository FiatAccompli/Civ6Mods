param([string] $to="")

# Copies all lua files in mods in modbuddy projects into the mods in the Civ6 mods folder.
# Do this because you can't do a build of the Modbuddy solution as Civ6 locks the folders 
# containing lua files and the build command will attempt to delete them and error out.  In order to 
# succeed you have to exit the Civ6 game (to main menu is sufficient) then build and restart the game.
# That's a super slow development cycle.  Fortunately Civ6 will reload lua files (for ui) and allow 
# you to re-include them (for gameplay scripts) (in FireTuner) if they are edited in place.  
# Unfortunately, that's not an inherently great solution because the files edited are generated as part 
# of the build process (they're copies of the "real" code in the Modbuddy solution).   So once editted 
# you need to copy the edits back to the real sources in Modbuddy.  Not very convenient!  This script 
# serves as an  alternate "build" command that allows editing the lua code in Modbuddy and then doing 
# a very quick "build" to get it up and running in Civ6.

# This can be configured as an external tool (Tools > External Tools) in Modbuddy with settings
# Name: Quick Build Lua, XML, and SQL
# Command: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
# Arguments: -file "CopyCiv6ModsLuaFiles.ps1"
# Initial Directory: "$(SolutionDir)"

# Unfortunately there doesn't seem to be a generic way to get the Civ6 local mods path within Modbuddy.
# So if you've got it somewhere besides the default (is that even possible?) you'll need to specify it 
# by adding a -To argument to the external tools arguments above.
if ($to -eq "") {
  $to = Join-Path $env:USERPROFILE "Documents\My Games\Sid Meier's Civilization VI\Mods"
}

$matches = Get-ChildItem -Recurse -Include ("*.lua", "*.xml", "*.sql", "*.dds") -Exclude ("modinfo_fixer.xml")

$matches | Copy-Item -Destination {
            $destination = Join-Path $to $_.FullName.Substring($pwd.Path.Length)
            Write-Host $_.FullName "to" $destination
            $destination
           }

Write-Host "Copied" $matches.count "lua, xml, and sql files" 