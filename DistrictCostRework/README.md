# District Cost Rework v1.0.0

Are you:
* Annoyed at how steeply district costs ramp up after the early game?
* Think it's ridiculous how long it takes to get a new city up and running in the later ages of the game?  
* Find it a bit unrealistic that modern socities apparently spend decades figuring out where to place a shopping mall?
(Well, in this case you should probably sit through a local city council meeting, but I digress.)

If any of these are the case this might be the mod you're looking for!

In the base game, district cost is based primarily on the progress of the game, with minor offsets
for lagging behind other civilizations.  At a conceptual level, it simply doesn't make sense for 
the cost of pointing to where a building should be built to scale based on technology.  
Similarly, while it makes sense that building a new district in a large city at later stages of the 
game would be more costly than in the early game, it doesn't make much sense for it to cost exactly 
the same amount in a smaller and more recently founded city.  This mod reworks district costs to 
address these issues.

First, district cost is no longer tied to tech/civic progress.  Instead it is based on the number 
of districts of that particular type previously built by in the civilization as well as the number of 
specialty districts (of any type) already present in the city.  The intent is that it should still be possible 
in the mid to late game to found a new city and get districts up and running fairly quickly (particularly if your 
empire is small).

### Changes:
* District cost no longer scales with game time or has catchup mechanisms relative to other civs.
* District cost scales based on the number of previous districts of that type constructed by the civilization.
  Each district constructed adds 40% of the base cost of a district to future constructions of that district.
  (Neighborhoods are still fixed cost.)  The 40% increase cost is a gameplay concession to penalize 
  indiscriminate building of districts and prevent ICS.
* Building a district in a city with 1/2/3/.../10 specialty districts already built increases district cost by 
  10/25/45/70/100/140/180/220/260/300%.  Larger cities should have bigger districts that take more 
  production to construct (but not, in practice, more turns to construct since larger cities will have 
  more production per turn).
* Removes Reyna's Contractor promotion for buying districts with gold since the production scaling described 
  above does not affect the converted gold cost, so districts would be unreasonably cheap to purchase. 
  (And, honestly, because I simply don't like the district purchase mechanic.) 
* New promotion for Reyna - Free Trader:
  * Adds +2 gold to outgoing international trade routes.
  * Adds +2 gold for both parties to incoming international trade routes.

The end result of these changes is that districts should cost a similar amount of production as the base 
game in the early eras but much less in later eras and for smaller empires.

### Compatibility
This mod should be compatible with all other mods and since the statements
that change district costs are generic it should alter the costs of custom districts 
added by other mods.  However, as with any mod, unforeseen conflicts may occur.

### Installation
* [Steam workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=1621028856) 
* [Manual install](https://github.com/FiatAccompli/Civ6Mods/releases)


### Disclaimer
Sid Meier's Civilization VI, Civ, Civilization, 2K Games, Firaxis Games, and 
Take-Two Interactive Software are all trademarks and/or registered trademarks of 
Take-Two Interactive Software, Inc who do not sponsor, endorse, authorize or are 
in any other way associated with this mod.

This mod is provided "as is", without warranty of any kind, express or implied, 
including but not limited to the warranties of merchantability, fitness for a 
particular purpose and noninfringement. In no event shall the authors or copyright 
holders be liable for any claim, damages or other liability, whether in an action 
of contract, tort or otherwise, arising from, out of or in connection with the mod
or the use or other dealings in the mod.
