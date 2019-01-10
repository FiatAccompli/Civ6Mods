# District Cost Rework v1.0.0

Are you:
* Annoyed at how steeply district costs ramp up after the early game?
* Think it's ridiculous how long it takes to get a new city up and running in the later ages of the game?  
* Find it a bit unrealistic that modern socities apparently spend decades figuring out where to place a shopping mall?
(Well, in this case you should probably sit through a local city council meeting, but I digress.)

If any of these are the case for you this might be the mod you're looking for!

In the base game, district cost is based primarily on the progress of the game, with minor offsets
for lagging behind other civilizations.  While it makes sense that building a new district in a large 
city at later stages of the game would be more costly than in the beginning, it doesn't make much sense 
for it to cost exectly the same in a smaller and more recently founded city.

This mod reworks district cost so it is no longer tied to tech/civic progress.  Instead it is based on the number 
of districts of that particular type previously built by in the civilization as well as the number of 
specialty districts (of any type) already present in the city.  The intent is that it should still be possible 
in the mid to late game to found a new city and get districts up and running fairly quickly (particularly if your 
empire is small).

### Changes:
* District cost no longer scales with game time or has catchup mechanisms relative to other civs.
* District cost scales based on the number of previous districts of that type constructed.
  Each district constructed adds 40% of the base cost of a district to future constructions of that district.
  (Neighborhoods are still fixed cost.)  The 40% increase cost is a gameplay concession to penalize 
  indiscriminate building of districts and prevent ICS.
* Building a district in a city with 1/2/3/.../10 specialty districts already built increases district cost by 
  10/25/45/70/100/140/180/220/260/300%.  Llarger cities should have bigger districts that take more 
  production to construct (but not, in practice, more turns to construct since larger cities will have 
  more production per turn).
* Removes Reyna's Contractor promotion for buying districts with gold since the production scaling described 
  above does not affect the converted gold cost, so districts would be unreasonably cheap to purchase. 
  (And, honestly, because I simply don't like the district purchase mechanic.) 
* New promotion for Reyna - Free Trader:
  * Adds +2 gold to outgoing international trade routes.
  * Adds +2 gold for both parties to incoming international trade routes.

### Compatibility
District Cost Rework should be compatible with all other mods and since the statements
that change district costs are generic it should alter the costs of custom districts 
added by other mods.  However, as with any mods, unforeseen conflicts may occur.
