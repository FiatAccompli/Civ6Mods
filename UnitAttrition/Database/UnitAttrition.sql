CREATE TABLE UA_UnitAttritionSetting (
   Name TEXT NOT NULL,
   UnitAttritionSet TEXT NOT NULL,
   -- Distance cost from closest supply point outside of which the attrition rate applies.
   DistanceCostRange INTEGER NOT NULL,
   -- Which types of units this attrition rate applies to.  E.g FORMATION_CLASS_NAVAL.
   FormationClass Text NOT NULL,
   -- Attrition rate (per turn hp lost by units) when you're more than DistanceCostRange distance 
   -- from an attrition supply point (e.g. city, but adjusted for pop size).
   AttritionRate INTEGER NOT NULL,

   FOREIGN KEY(UnitAttritionSet) REFERENCES UA_UnitAttritionSets(Name),
   FOREIGN KEY(FormationClass) REFERENCES UnitFormationClasses(FormationClassType),
   PRIMARY KEY(Name)
);

CREATE TABLE UA_UnitAttritionSets (
   Name TEXT NOT NULL,

   -- Max amount of attrition per turn allowed for a unit.
   MaxAttritionPerTurn INTEGER NOT NULL,

   -- Amount of attrition per turn alleviated for each food yield from a plot.  Simulates the ability of a unit to 
   -- support itself by living off the land.
   AttritionAlleviatedPerFood INTEGER NOT NULL,
   -- Initial cost to start at a city is max(<this> - city population, 0).  So larger cities have a larger effective 
   -- radius of support against attrition.
   PopulationDistanceCostOffset INTEGER NOT NULL,

   -- True if roads within the owner's borders reduce distance and allow attrition support to extend further.
   RoutesInOwnTerritory BOOLEAN NOT NULL CHECK (RoutesInOwnTerritory IN (0,1)),
   -- True if roads in neutral territory (owned by no civ) allow attrition support to extend further.
   RoutesInNeutralTerritory BOOLEAN NOT NULL CHECK (RoutesInNeutralTerritory IN (0,1)),
   -- True if roads in within a civ for which you have open borders within allow attrition support to extend further.
   RoutesInOpenBordersTerritory BOOLEAN NOT NULL CHECK (RoutesInOpenBordersTerritory IN (0,1)),
   -- True if roads in a city state for which a civ is suzerain allow attrition support to extend further.
   RoutesInCityStateSuzerain BOOLEAN NOT NULL CHECK (RoutesInCityStateSuzerain IN (0,1)),
   -- True if roads within a civ which is a declared frind with the player allow attrition support to extend further.
   RoutesInFriendTerritory BOOLEAN NOT NULL CHECK (RoutesInFriendTerritory IN (0,1)),
   -- True if roads in a civ which has an alliance (any kind) with the player allow attrition support to extend further.
   RoutesInAllianceTerritory BOOLEAN NOT NULL CHECK (RoutesInAllianceTerritory IN (0,1)),
   -- True if roads in a civ which has a military alliance with the player allow attrition support to extend further.
   RoutesInMilitaryAllianceTerritory BOOLEAN NOT NULL CHECK (RoutesInMilitaryAllianceTerritory IN (0,1)),
   -- True if roads in enemy territory reduce distance and allow attrition support to extend further.
   RoutesInEnemyTerritory BOOLEAN NOT NULL CHECK (RoutesInEnemyTerritory IN (0,1)),

   -- True if declared friendship with a civ causes its cities to be supply bases for unit attrition.
   FriendProvidesSupport BOOLEAN NOT NULL CHECK (FriendProvidesSupport IN (0,1)),
   -- True if an alliance (any kind) with a civ causes its cities to be supply bases for unit attrition.
   AllianceProvidesSupport BOOLEAN NOT NULL CHECK (AllianceProvidesSupport IN (0,1)),
   -- True if a military alliance with a civ causes its cities to be supply bases for unit attrition.
   MilitaryAllianceProvidesSupport BOOLEAN NOT NULL CHECK (MilitaryAllianceProvidesSupport IN (0,1)),
   -- True if being a suzerain of a city state causes its cites to be supply bases for unit attrition.
   CityStateSuzerainProvidesSupport BOOLEAN NOT NULL CHECK (CityStateSuzerainProvidesSupport IN (0,1)),

   PRIMARY KEY(Name)
);

CREATE TABLE UA_UnitAttritionSetByEra (
   Era TEXT NOT NULL,
   UnitAttritionSet TEXT NOT NULL,

   FOREIGN KEY(Era) REFERENCES UA_UnitAttritionSetByEra(Era),
   FOREIGN KEY(UnitAttritionSet) REFERENCES UA_UnitAttritionSets(Name),
   PRIMARY KEY(Era)
);

CREATE TABLE UA_UnitAttritionFormationClassSettings(
  FormationClass TEXT NOT NULL,
  UseNavalAttritionWhenAtSea BOOLEAN NOT NULL CHECK (UseNavalAttritionWhenAtSea IN (0,1)),
  
  PRIMARY KEY(FormationClass)
);

INSERT INTO UA_UnitAttritionSets (Name, MaxAttritionPerTurn, AttritionAlleviatedPerFood, PopulationDistanceCostOffset, 
    RoutesInOwnTerritory, RoutesInNeutralTerritory, RoutesInOpenBordersTerritory, RoutesInCityStateSuzerain, 
        RoutesInFriendTerritory, RoutesInAllianceTerritory, RoutesInMilitaryAllianceTerritory, RoutesInEnemyTerritory, 
    FriendProvidesSupport, AllianceProvidesSupport, MilitaryAllianceProvidesSupport, CityStateSuzerainProvidesSupport)
VALUES ('UNIT_ATTRITION_SET_ANCIENT_DEFAULT', 30, 5, 6,
        1, 1, 0, 1, 1, 1, 1, 0,
		0, 0, 1, 1),
       ('UNIT_ATTRITION_SET_CLASSICAL_DEFAULT', 30, 5, 8,
	    1, 1, 0, 1, 1, 1, 1, 0,
		0, 0, 1, 1),
	   ('UNIT_ATTRITION_SET_MEDIEVAL_DEFAULT', 30, 2, 10,
	    1, 1, 0, 1, 1, 1, 1, 1,
		0, 0, 1, 1),
       ('UNIT_ATTRITION_SET_RENAISSANCE_DEFAULT', 30, 2, 12,
	    1, 1, 0, 1, 0, 1, 1, 1,
		0, 0, 1, 1),
       ('UNIT_ATTRITION_SET_INDUSTRIAL_DEFAULT', 30, 0, 14,
	    1, 1, 0, 1, 0, 1, 1, 1,
		0, 0, 1, 1),
       ('UNIT_ATTRITION_SET_MODERN_DEFAULT', 30, 0, 16,
	    1, 1, 0, 1, 0, 1, 1, 1,
		0, 0, 1, 1),
       ('UNIT_ATTRITION_SET_ATOMIC_DEFAULT', 30, 0, 18,
	    1, 1, 0, 1, 0, 1, 1, 1,
		0, 0, 1, 1),
       ('UNIT_ATTRITION_SET_INFORMATION_DEFAULT', 30, 0, 20,
	    1, 1, 0, 1, 0, 1, 1, 1,
		0, 0, 1, 1);

INSERT INTO UA_UnitAttritionSetting (Name, UnitAttritionSet, FormationClass, DistanceCostRange, AttritionRate)
VALUES ('UNIT_ATTRITION_ANCIENT_LAND_LOW', 'UNIT_ATTRITION_SET_ANCIENT_DEFAULT', 'FORMATION_CLASS_LAND_COMBAT', 10, 10),
       ('UNIT_ATTRITION_ANCIENT_LAND_MEDIUM', 'UNIT_ATTRITION_SET_ANCIENT_DEFAULT', 'FORMATION_CLASS_LAND_COMBAT', 13, 10),
       ('UNIT_ATTRITION_ANCIENT_LAND_HIGH', 'UNIT_ATTRITION_SET_ANCIENT_DEFAULT', 'FORMATION_CLASS_LAND_COMBAT', 16, 10),
	   ('UNIT_ATTRITION_ANCIENT_NAVAL_LOW', 'UNIT_ATTRITION_SET_ANCIENT_DEFAULT', 'FORMATION_CLASS_NAVAL', 10, 10),
       ('UNIT_ATTRITION_ANCIENT_NAVAL_MEDIUM', 'UNIT_ATTRITION_SET_ANCIENT_DEFAULT', 'FORMATION_CLASS_NAVAL', 13, 10),
	   ('UNIT_ATTRITION_ANCIENT_NAVAL_HIGH', 'UNIT_ATTRITION_SET_ANCIENT_DEFAULT', 'FORMATION_CLASS_NAVAL', 16, 10);

INSERT INTO UA_UnitAttritionSetting (Name, UnitAttritionSet, FormationClass, DistanceCostRange, AttritionRate)
SELECT REPLACE(Name, 'ANCIENT', 'CLASSICAL'), Replace(UnitAttritionSet, 'ANCIENT', 'CLASSICAL'), FormationClass, DistanceCostRange + 1, AttritionRate
FROM UA_UnitAttritionSetting WHERE Name LIKE '%ANCIENT_LAND%';

INSERT INTO UA_UnitAttritionSetting (Name, UnitAttritionSet, FormationClass, DistanceCostRange, AttritionRate)
SELECT REPLACE(Name, 'CLASSICAL', 'MEDIEVAL'), Replace(UnitAttritionSet, 'CLASSICAL', 'MEDIEVAL'), FormationClass, DistanceCostRange + 1, AttritionRate
FROM UA_UnitAttritionSetting WHERE Name LIKE '%CLASSICAL_LAND%';

INSERT INTO UA_UnitAttritionSetting (Name, UnitAttritionSet, FormationClass, DistanceCostRange, AttritionRate)
SELECT REPLACE(Name, 'MEDIEVAL', 'RENAISSANCE'), Replace(UnitAttritionSet, 'MEDIEVAL', 'RENAISSANCE'), FormationClass, DistanceCostRange + 1, AttritionRate
FROM UA_UnitAttritionSetting WHERE Name LIKE '%MEDIEVAL_LAND%';

INSERT INTO UA_UnitAttritionSetting (Name, UnitAttritionSet, FormationClass, DistanceCostRange, AttritionRate)
SELECT REPLACE(Name, 'RENAISSANCE', 'INDUSTRIAL'), Replace(UnitAttritionSet, 'RENAISSANCE', 'INDUSTRIAL'), FormationClass, DistanceCostRange + 1, AttritionRate
FROM UA_UnitAttritionSetting WHERE Name LIKE '%RENAISSANCE_LAND%';

INSERT INTO UA_UnitAttritionSetting (Name, UnitAttritionSet, FormationClass, DistanceCostRange, AttritionRate)
SELECT REPLACE(Name, 'INDUSTRIAL', 'MODERN'), Replace(UnitAttritionSet, 'INDUSTRIAL', 'MODERN'), FormationClass, DistanceCostRange + 1, AttritionRate
FROM UA_UnitAttritionSetting WHERE Name LIKE '%INDUSTRIAL_LAND%';

INSERT INTO UA_UnitAttritionSetting (Name, UnitAttritionSet, FormationClass, DistanceCostRange, AttritionRate)
SELECT REPLACE(Name, 'MODERN', 'ATOMIC'), Replace(UnitAttritionSet, 'MODERN', 'ATOMIC'), FormationClass, DistanceCostRange + 1, AttritionRate
FROM UA_UnitAttritionSetting WHERE Name LIKE '%MODERN_LAND%';

INSERT INTO UA_UnitAttritionSetting (Name, UnitAttritionSet, FormationClass, DistanceCostRange, AttritionRate)
SELECT REPLACE(Name, 'ATOMIC', 'INFORMATION'), Replace(UnitAttritionSet, 'ATOMIC', 'INFORMATION'), FormationClass, DistanceCostRange + 1, AttritionRate
FROM UA_UnitAttritionSetting WHERE Name LIKE '%ATOMIC_LAND%';


INSERT INTO UA_UnitAttritionSetting (Name, UnitAttritionSet, FormationClass, DistanceCostRange, AttritionRate)
SELECT REPLACE(Name, 'ANCIENT', 'CLASSICAL'), Replace(UnitAttritionSet, 'ANCIENT', 'CLASSICAL'), FormationClass, DistanceCostRange + 2, AttritionRate
FROM UA_UnitAttritionSetting WHERE Name LIKE '%ANCIENT_NAVAL%';

INSERT INTO UA_UnitAttritionSetting (Name, UnitAttritionSet, FormationClass, DistanceCostRange, AttritionRate)
SELECT REPLACE(Name, 'CLASSICAL', 'MEDIEVAL'), Replace(UnitAttritionSet, 'CLASSICAL', 'MEDIEVAL'), FormationClass, DistanceCostRange + 2, AttritionRate
FROM UA_UnitAttritionSetting WHERE Name LIKE '%CLASSICAL_NAVAL%';

INSERT INTO UA_UnitAttritionSetting (Name, UnitAttritionSet, FormationClass, DistanceCostRange, AttritionRate)
SELECT REPLACE(Name, 'MEDIEVAL', 'RENAISSANCE'), Replace(UnitAttritionSet, 'MEDIEVAL', 'RENAISSANCE'), FormationClass, DistanceCostRange + 2, AttritionRate
FROM UA_UnitAttritionSetting WHERE Name LIKE '%MEDIEVAL_NAVAL%';

UPDATE UA_UnitAttritionSetting
SET DistanceCostRange = DistanceCostRange + 3
WHERE Name LIKE '%RENAISSANCE_NAVAL_MEDIUM%';

UPDATE UA_UnitAttritionSetting
SET DistanceCostRange = DistanceCostRange + 6
WHERE Name LIKE '%RENAISSANCE_NAVAL_HIGH%';

INSERT INTO UA_UnitAttritionSetting (Name, UnitAttritionSet, FormationClass, DistanceCostRange, AttritionRate)
SELECT REPLACE(Name, 'RENAISSANCE', 'INDUSTRIAL'), Replace(UnitAttritionSet, 'RENAISSANCE', 'INDUSTRIAL'), FormationClass, DistanceCostRange + 3, AttritionRate
FROM UA_UnitAttritionSetting WHERE Name LIKE '%RENAISSANCE_NAVAL%';

UPDATE UA_UnitAttritionSetting
SET DistanceCostRange = DistanceCostRange + 3
WHERE Name LIKE '%INDUSTRIAL_NAVAL_MEDIUM%';

UPDATE UA_UnitAttritionSetting
SET DistanceCostRange = DistanceCostRange + 6
WHERE Name LIKE '%INDUSTRIAL_NAVAL_HIGH%';

INSERT INTO UA_UnitAttritionSetting (Name, UnitAttritionSet, FormationClass, DistanceCostRange, AttritionRate)
SELECT REPLACE(Name, 'INDUSTRIAL', 'MODERN'), Replace(UnitAttritionSet, 'INDUSTRIAL', 'MODERN'), FormationClass, DistanceCostRange + 3, AttritionRate
FROM UA_UnitAttritionSetting WHERE Name LIKE '%INDUSTRIAL_NAVAL%';

INSERT INTO UA_UnitAttritionSetting (Name, UnitAttritionSet, FormationClass, DistanceCostRange, AttritionRate)
SELECT REPLACE(Name, 'MODERN', 'ATOMIC'), Replace(UnitAttritionSet, 'MODERN', 'ATOMIC'), FormationClass, DistanceCostRange + 4, AttritionRate
FROM UA_UnitAttritionSetting WHERE Name LIKE '%MODERN_NAVAL%';

UPDATE UA_UnitAttritionSetting
SET DistanceCostRange = DistanceCostRange + 2
WHERE Name LIKE '%ATOMIC_NAVAL_MEDIUM%';

UPDATE UA_UnitAttritionSetting
SET DistanceCostRange = DistanceCostRange + 4
WHERE Name LIKE '%ATOMIC_NAVAL_HIGH%';

INSERT INTO UA_UnitAttritionSetting (Name, UnitAttritionSet, FormationClass, DistanceCostRange, AttritionRate)
SELECT REPLACE(Name, 'ATOMIC', 'INFORMATION'), Replace(UnitAttritionSet, 'ATOMIC', 'INFORMATION'), FormationClass, DistanceCostRange + 4, AttritionRate
FROM UA_UnitAttritionSetting WHERE Name LIKE '%ATOMIC_NAVAL%';


INSERT INTO UA_UnitAttritionSetByEra (Era, UnitAttritionSet)
SELECT EraType, 'UNIT_ATTRITION_SET_ANCIENT_DEFAULT' FROM Eras;

UPDATE UA_UnitAttritionSetByEra SET UnitAttritionSet = 'UNIT_ATTRITION_SET_CLASSICAL_DEFAULT' WHERE Era = 'ERA_CLASSICAL';
UPDATE UA_UnitAttritionSetByEra SET UnitAttritionSet = 'UNIT_ATTRITION_SET_MEDIEVAL_DEFAULT' WHERE Era = 'ERA_MEDIEVAL';
UPDATE UA_UnitAttritionSetByEra SET UnitAttritionSet = 'UNIT_ATTRITION_SET_RENAISSANCE_DEFAULT' WHERE Era = 'ERA_RENAISSANCE';
UPDATE UA_UnitAttritionSetByEra SET UnitAttritionSet = 'UNIT_ATTRITION_SET_INDUSTRIAL_DEFAULT' WHERE Era = 'ERA_INDUSTRIAL';
UPDATE UA_UnitAttritionSetByEra SET UnitAttritionSet = 'UNIT_ATTRITION_SET_MODERN_DEFAULT' WHERE Era = 'ERA_MODERN';
UPDATE UA_UnitAttritionSetByEra SET UnitAttritionSet = 'UNIT_ATTRITION_SET_ATOMIC_DEFAULT' WHERE Era = 'ERA_ATOMIC';
UPDATE UA_UnitAttritionSetByEra SET UnitAttritionSet = 'UNIT_ATTRITION_SET_INFORMATION_DEFAULT' WHERE Era = 'ERA_INFORMATION';


INSERT INTO UA_UnitAttritionFormationClassSettings (FormationClass, UseNavalAttritionWhenAtSea)
VALUES ('FORMATION_CLASS_LAND_COMBAT', 1);

-- NavigationProperties is a primitive ORM mapping for having the game automatically connect objects together in GameInfo.
-- Make it hook up Eras.DefaultUnitAttritionSet and UnitAttritionSets.SettingsCollection.
INSERT INTO NavigationProperties (BaseTable, PropertyName, TargetTable, IsCollection, Query)
VALUES ('Eras', 'DefaultUnitAttritionSet', 'UA_UnitAttritionSets', 0, 'SELECT T3.rowid FROM Eras AS T1 INNER JOIN UA_UnitAttritionSetByEra AS T2 ON T2.Era = T1.EraType INNER JOIN UA_UnitAttritionSets T3 ON T2.UnitAttritionSet = T3.Name WHERE T1.rowid = ? ORDER BY T3.rowid ASC LIMIT 1'),
	   ('UA_UnitAttritionSets', 'SettingsCollection', 'UA_UnitAttritionSetting', 1, 'SELECT T1.rowid FROM UA_UnitAttritionSetting AS T1 INNER JOIN UA_UnitAttritionSets AS T2 ON T2.Name = T1.UnitAttritionSet where T2.rowid = ? ORDER BY T1.rowid ASC');
