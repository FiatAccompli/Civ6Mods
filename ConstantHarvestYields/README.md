# Constant Harvest Yields v1.0.0

Changes harvest yields to no longer scale with tech/civic progress. Yields from terrain 
harvests are fixed at a value that is roughly the same as harvesting at the middle of the 
classical era.  Harvest yields for bonus resources are fixed at a value that is roughly 
the same as harvesting at the middle of the medieval era.

As removing harvest yield scaling significantly reduces the use of Magnus' Groundbreaker 
promotion (+50% to harvest yields) (and, honestly, because that promotion is rather overpowered) the
following changes are made to Magnus' promotion tree: 
* Groundbreaker promotion removed.
* New promotion Supply Chain Manager.
  * +1 production to industrial zone buildings with a regional production effect.
  * +3 range to the area of effect of industrial zone buildings.
* Surplus Logistics promotion is now Magnus's default promotion. 
  * Modified to only provide +1 food (down from +2) to trade routes ending in the city.

![Magnus rework](Documentation/Magnus.jpg)

### Recommendation
As making harvest yields constant requires changing a global parameter that 
also effects district cost scaling it is recommended to also use a mod that changes how 
district costs are handled.  For example: [District Cost Rework](../DistrictCostRework)

### Installation
[Steam version]()