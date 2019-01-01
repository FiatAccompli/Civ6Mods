# District Cost Rework v1.0.0

Reworks district cost to be based on the number of districts of that type previously built 
in a civilization as well as the number of specialty districts (of any type) already 
present in the city.  The intent is that it should still be possible in the mid to late game to 
found a new city and get districts up and running fairly quickly (particularly if your 
empire is small).

## Changes:
* District cost no longer scales with game time or has catchup mechanisms relative to other civs.
* District cost nows scales based on the number of previous districts of that type constructed.
  Each district constructed adds 1/3 of the base cost of that district to future constructions of that district.
  (Does not apply to Neighborhoods.)
* Building a district in a city with 1/2/3/.../10 specialty districts already built increases district cost by 
  10/25/45/70/100/140/180/220/260/300%.
* Removes Reyna's Contractor promotion that allows buying districts with gold since the production modifications do not affect this cost.
  Replaced with Free Trade Zone promotion that boosts trade route gold yield.