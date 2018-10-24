-- Decrease production for districts the more specialty districts a city has already built.  It would 
-- be preferable to increase the cost of a district the more districts a city has but there are no
-- modifiers that affect cost directly.  Everything in the game that affects how  much something costs 
-- is done by increasing/decreasing production (or increasing/decreasing the converted gold cost).
-- This way of doing it has a similar but not identical effect due to how it stacks with other 
-- percentage production modifiers.  Also it does not increase the effective cost of the district
-- when production comes from sources other than per-turn production.  These are:
-- Overflow: nothing we can do about this - the game's handling of overflow is out of our control
-- Resource harvesting/chopping: Similar to overflow, but since chopping is pretty op in the game 
--   I recommend using a mod that reduces chop harvests yields after the early game (when the modifiers 
--   applied by this mod start to become large enough that the impact is highly noticeable).
-- Reyna's promotion that allows buying districts with gold does not account for this "cost increase"
CREATE TABLE DCR_DistrictProductionAdjustments (
    NumDistricts INT NOT NULL,
	ProductionAdjustment INT NOT NULL
	PRIMARY KEY (NumDistricts) );

-- Aiming for effective production cost increase of 
-- 10/25/45/70/100/140/180/220/260/300% for second/third/... specialty district 
-- constructed in a city.  The modifier that's being applied is actually a percentage
-- production decrease and as soon as you have x districts in a city the modification 
-- for having x districts applies for all future districts built.  The modification stacks
-- additively rather than multiplicatively (that's just how the base game calculates it deep
-- in the binary).
--
-- This production decrease does not work perfectly as an equivalent to a cost increase
-- as other percentage production modifiers are also applied additively at the same 
-- time to compute the overall production multiplier.  If you're building the sixth district 
-- with an intended 100% cost increase (i.e. cummulative -50% production modification from 
-- these modifiers) and have an additional -10% production penalty from happiness 
-- then the production modifier is really -60% and the effective cost increase is 
-- 2.5x rather than the 2.2x that would result if modifiers were applied multiplicatively.
-- Similarly, modifiers that apply other production modification multipliers (such as
-- Tokimune's Divine Wind trait, the Veterancy government policy or some governor promotions)
-- will result in a less than desirable end result.  (E.g. Divine Wind's +100% bonus results
-- in a overall +25% production adjustment rather than the -75% that should apply at 10
-- specialty districts.)
--
-- I am not sure how this interacts with high level ais that recieve an additional 
-- production modifier to everything.  I believe that modifier is applied multiplicatively 
-- on top of everything else, but I'm too lazy to investigate and see if that's actually the case.
INSERT INTO DCR_DistrictProductionAdjustments (NumDistricts, ProductionAdjustment)
VALUES (1, -9),
       (2, -11),
       (3, -11),
       (4, -10),
       (5, -9),
       (6, -8),
       (7, -6),
       (8, -5),
       (9, -3),
       (10, -3);

-- This could be done in a cleaner method by attaching one game modifier to all cities and using a subject 
-- requirement set to control when it activates on each city rather than using a game modifier to turn 
-- right around and add a modifier to each city.  I tried this and it works.  Except that the detail tooltip when 
-- hovering over production in the city only shows the production modifier when the modifier is applied to 
-- a single city and when it uses the effect EFFECT_ADJUST_ALL_DISTRICTS_PRODUCTION.  If either of these is not 
-- true the modifier does not show up in the production tooltip.  This behavior can be seen in the base game: 
-- the city patron goddess pantheon bonus implemented in this less clean manner shows up in the tooltip as a 
-- +25% to district production while Tokimune's Divine Wind trait, the Veterancy policy card effect, and 
-- Liang's Zoning Commissioner promotion all apply a multiplier to production which works the same way (the numbers
-- work out to what they should) but does not show up in the tooltip.  As the tooltip text is generated somewhere 
-- deep in the dll (Why not in lua?  How to put this nicely?  Because civ programmers are shit at their job.)
-- there is nothing to do other than using this less clean method of implementation.

-- INSERT INTO Types (Type, Kind)
-- VALUES ('MODIFIER_DCR_ALL_CITIES_ADJUST_ALL_DISTRICT_PRODUCTION_RATE', 'KIND_MODIFIER');

-- INSERT INTO DynamicModifiers(ModifierType, CollectionType, EffectType)
-- VALUES ('MODIFIER_DCR_ALL_CITIES_ADJUST_ALL_DISTRICT_PRODUCTION_RATE', 'COLLECTION_ALL_CITIES', 'EFFECT_ADJUST_ALL_DISTRICTS_PRODUCTION');


-- It's abundantly unclear what the game defines as a specialty district.  Fortunately, experiments indicate it 
-- does not include aqueducts and neighborhoods.  (And also not the built-in replacements of mbanza and bath, 
-- but who knows if that extends to other custom replacements of those districts).  So it appears a specialty district
-- is anything that would count against district limits.

-- It is rather fortuitous that it works this way since otherwise city population would have to be used as a 
-- proxy for number of districts.

-- Create RequirementSets DCR_CITY_HAS_{1,2,3,4,5,6,7,8,9,10}_SPECIALTY_DISTRICTS.  The game already has 
-- equivalents for 1,2, and 3 but it's easiest to be consistent and create a custom one for all values.
INSERT INTO RequirementSets (RequirementSetId, RequirementSetType)
SELECT 'DCR_CITY_HAS_' || NumDistricts || '_SPECIALTY_DISTRICTS', 'REQUIREMENTSET_TEST_ALL'
FROM DCR_DistrictProductionAdjustments;

INSERT INTO Requirements (RequirementId, RequirementType)
SELECT 'DCR_REQUIRES_CITY_HAS_' || NumDistricts || '_SPECIALTY_DISTRICTS', 
       'REQUIREMENT_CITY_HAS_X_SPECIALTY_DISTRICTS'
FROM DCR_DistrictProductionAdjustments;

INSERT INTO RequirementArguments (RequirementId, Name, Type, Value)
SELECT 'DCR_REQUIRES_CITY_HAS_' || NumDistricts || '_SPECIALTY_DISTRICTS', 
       'Amount', 
       'ARGTYPE_IDENTITY', 
       NumDistricts
FROM DCR_DistrictProductionAdjustments;

INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId)
SELECT 'DCR_CITY_HAS_' || NumDistricts || '_SPECIALTY_DISTRICTS', 
       'DCR_REQUIRES_CITY_HAS_' || NumDistricts || '_SPECIALTY_DISTRICTS'
FROM DCR_DistrictProductionAdjustments;

-- Create a modifier that applies the actual production decrease.
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, NewOnly, Permanent, OwnerRequirementSetId, SubjectRequirementSetId)
SELECT 'DCR_CITY_HAS_' || NumDistricts || '_SPECIALTY_DISTRICTS_ADJUSTED_DISTRICT_PRODUCTION_MODIFIER',
       'MODIFIER_SINGLE_CITY_ADJUST_DISTRICT_PRODUCTION_MODIFIER', 0, 0, 0, NULL,
       'DCR_CITY_HAS_' || NumDistricts || '_SPECIALTY_DISTRICTS'
FROM DCR_DistrictProductionAdjustments;

INSERT INTO ModifierArguments(ModifierId, Name, Type, Value)
SELECT 'DCR_CITY_HAS_' || NumDistricts || '_SPECIALTY_DISTRICTS_ADJUSTED_DISTRICT_PRODUCTION_MODIFIER',
       'Amount',
       'ARGTYPE_IDENTITY',
       ProductionAdjustment
FROM DCR_DistrictProductionAdjustments;

-- And the modifier that applies this modifier to each city founded.
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, NewOnly, Permanent, OwnerRequirementSetId, SubjectRequirementSetId)
SELECT 'DCR_CITY_HAS_' || NumDistricts || '_SPECIALTY_DISTRICTS_ADJUSTED_DISTRICT_PRODUCTION', 
       'MODIFIER_ALL_CITIES_ATTACH_MODIFIER', 0, 0, 0, NULL, NULL
FROM DCR_DistrictProductionAdjustments;

INSERT INTO ModifierArguments(ModifierId, Name, Type, Value)
SELECT 'DCR_CITY_HAS_' || NumDistricts || '_SPECIALTY_DISTRICTS_ADJUSTED_DISTRICT_PRODUCTION', 
       'ModifierId', 
       'ARGTYPE_IDENTITY', 
       'DCR_CITY_HAS_' || NumDistricts || '_SPECIALTY_DISTRICTS_ADJUSTED_DISTRICT_PRODUCTION_MODIFIER'
FROM DCR_DistrictProductionAdjustments;

-- Add that modifier to game modifiers so it affects every city from the get-go.
INSERT INTO GameModifiers (ModifierId)
SELECT 'DCR_CITY_HAS_' || NumDistricts || '_SPECIALTY_DISTRICTS_ADJUSTED_DISTRICT_PRODUCTION'
FROM DCR_DistrictProductionAdjustments;

-- TODO: Consider whether to apply an offset to the production reductions for neighborhoods so 
-- that they have a fixed cost.  Inclined not to do so.

-- Change districts using COST_PROGRESSION_NUM_AVG_PLUS_TECH.  These are:
--  HOLY_SITE
--  CAMPUS
--  ENCAMPMENT
--  HARBOR
--  AERODROME
--  COMMERCIAL_HUB
--  ENTERTAINMENT_COMPLEX
--  THEATRE
--  INDUSTRIAL_ZONE
--  ACROPOLIS
--  HANSA
--  LAVRA
--  STREET_CARNIVAL
--  ROYAL_NAVY_DOCKYARD
--  IKANDA
--  SEOWON
--  GOVERNMENT
--
-- Increase district cost by a factor of 50%.  This slightly increases the cost of very early districts (campus, holy site, 
-- and encampment) and breaks even when the majority of the ancient era techs/civics are researched (in practice this is 
-- largely equivalent to entering the classical age.)  This is generally a good thing as it forces the choice of 
-- initial districts to have a significant impact.  On the other side of the change, this gives a small effective 
-- boost to the first commercial and theatre districts as they come slightly later than this break-even point
-- (theatre probably needs it since it's slightly underpowered while commercial/harbor doesn't need the buff but 
-- it's probably post R&F as trade routes are gated by the level 1 building and not on building the district itself).
-- It gives a larger boost to industrial districts, but this is fine as they're underpowered at the moment).
-- It also adjusts any custom districts from other mods, which is desirable if they replace a district from the 
-- base game and not so desirable if it's a new type of district (but better than leaving them with the old cost
-- progression model).
--
-- Update the cost progression increase for the district to be 1/3 of the updated cost so every 3 copies built of the 
-- district adds 1 increment of the base cost.
UPDATE Districts SET 
    Cost = Cost * 1.5,
	CostProgressionModel = 'COST_PROGRESSION_PREVIOUS_COPIES',
	CostProgressionParam1 = Cost / 2
WHERE CostProgressionModel = 'COST_PROGRESSION_NUM_UNDER_AVG_PLUS_TECH';

-- Aerodromes come way later in the game so increase the base cost and increment to 3x (2x over the base 1.5x above) what 
-- it was with COST_PROGRESSION_NUM_UNDER_AVG_PLUS_TECH (cost should be roughly the same as base game when initially researched).
-- This is a significant discount (~50% from the base game) for the aerodrome district, which probably is nowhere near enough 
-- to do anything about it being the weakest district in the game.
UPDATE Districts SET
    Cost = Cost * 2,
	CostProgressionParam1 = CostProgressionParam1 * 2
WHERE DistrictType = 'DISTRICT_AERODROME';

-- Apply the same 3x cost to aerodrome replacements (although there are not currently any unless another mod
-- adds a custom one).
UPDATE Districts SET 
    Cost = Cost * 2,
	CostProgressionParam1 = CostProgressionParam1 * 2
WHERE EXISTS 
    (SELECT * FROM DistrictReplaces WHERE CivUniqueDistrictType = DistrictType AND ReplacesDistrictType = 'DISTRICT_AERODROME');

-- Update the cost of districts using COST_PROGRESSION_GAME_PROGRESS to be a fixed cost.  These are:
--  AQUEDUCT
--  BATH
--  NEIGHBORHOOD
--  MBANZA
-- 
-- Cost multiplier is 2.5x since aqueduct/baths come slightly later in the game than most specialty districts and this keeps the 
-- effective cost slightly less than any of the specialty districts (as is the case in the base game) when they 
-- are typically discovered.
--
-- This will also affect custom districts and that's less desirable than for COST_PROGRESSION_NUM_UNDER_AVG_PLUS_TECH, 
-- but it is what it is.
UPDATE Districts SET
    Cost = Cost * 2,
	CostProgressionModel = 'NO_COST_PROGRESSION',
	CostProgressionParam1 = 0
WHERE CostProgressionModel = 'COST_PROGRESSION_GAME_PROGRESS';

-- Neighborhoods come rather later in the game than most of the other districts (except for AERODROME) so increase their 
-- cost to 3x what was assigned under the old cost progression model.  Note that you'll probably only be building them in 
-- cities with 4 or more specialty districts already built at which point the effective cost will be 3x * 1.7 = 5.1x which 
-- should be very similar to what they would cost in the base game when they're first available.
UPDATE Districts SET
    Cost = Cost * 1.5
WHERE DistrictType = 'DISTRICT_NEIGHBORHOOD';

-- Apply the same 3x cost to neighborhood replacements.
UPDATE Districts SET 
    Cost = Cost * 1.5
WHERE EXISTS 
    (SELECT * FROM DistrictReplaces WHERE CivUniqueDistrictType = DistrictType AND ReplacesDistrictType = 'DISTRICT_NEIGHBORHOOD');

-- Clean everything up a little just so the numbers display nicer in game.
UPDATE Districts SET Cost = ROUND(Cost), CostProgressionParam1 = ROUND(CostProgressionParam1);