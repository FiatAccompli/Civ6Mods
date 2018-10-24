-- Replaces Magnus' initial Groundbreaker promotion (+50% harvest yields) with the supply chain management promotion
-- (+1 production to industrial zone regional buildings and +3 regional range for industrial zone).  This is the same as 
-- great engineer Nikola Tesla's ability but nerfed to +1 production.

-- Create modifiers for the Supply Chain Management promotion. 
INSERT INTO Types (Type, Kind)
VALUES ('CHY_GOVERNOR_PROMOTION_RESOURCE_MANAGER_SUPPLY_CHAIN_MANAGEMENT', 'KIND_GOVERNOR_PROMOTION'),
       ('CHY_MODIFIER_SINGLE_CITY_DISTRICTS_ADJUST_REGIONAL_YIELD', 'KIND_MODIFIER'),
	   ('CHY_MODIFIER_SINGLE_CITY_DISTRICTS_ADJUST_REGIONAL_RANGE', 'KIND_MODIFIER');

INSERT INTO DynamicModifiers (ModifierType, CollectionType, EffectType)
VALUES ('CHY_MODIFIER_SINGLE_CITY_DISTRICTS_ADJUST_REGIONAL_YIELD', 'COLLECTION_CITY_DISTRICTS', 'EFFECT_ADJUST_DISTRICT_EXTRA_REGIONAL_YIELD'),
       ('CHY_MODIFIER_SINGLE_CITY_DISTRICTS_ADJUST_REGIONAL_RANGE', 'COLLECTION_CITY_DISTRICTS', 'EFFECT_ADJUST_DISTRICT_EXTRA_REGIONAL_RANGE');

INSERT INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId)
VALUES ('CHY_SUPPLY_CHAIN_MANAGEMENT_BUILDING_PRODUCTION', 'CHY_MODIFIER_SINGLE_CITY_DISTRICTS_ADJUST_REGIONAL_YIELD', 'DISTRICT_IS_INDUSTRIAL_ZONE'),
	   ('CHY_SUPPLY_CHAIN_MANAGEMENT_REGIONAL_RANGE_BONUS', 'CHY_MODIFIER_SINGLE_CITY_DISTRICTS_ADJUST_REGIONAL_RANGE', 'DISTRICT_IS_INDUSTRIAL_ZONE');

INSERT INTO ModifierArguments (ModifierId, Name, Type, Value)
VALUES ('CHY_SUPPLY_CHAIN_MANAGEMENT_BUILDING_PRODUCTION', 'YieldType', 'ARGTYPE_IDENTITY', 'YIELD_PRODUCTION'),
	   ('CHY_SUPPLY_CHAIN_MANAGEMENT_BUILDING_PRODUCTION', 'Amount', 'ARGTYPE_IDENTITY', '1'),
	   ('CHY_SUPPLY_CHAIN_MANAGEMENT_REGIONAL_RANGE_BONUS', 'Amount', 'ARGTYPE_IDENTITY', '3');

-- Create the new governor promotion Supply Chain Management
INSERT INTO GovernorPromotions (GovernorPromotionType, Name, Description, Level, Column, BaseAbility)
VALUES ('CHY_GOVERNOR_PROMOTION_RESOURCE_MANAGER_SUPPLY_CHAIN_MANAGEMENT',
        'LOC_CHY_GOVERNOR_PROMOTION_RESOURCE_MANAGER_SUPPLY_CHAIN_MANAGEMENT_NAME',
		'LOC_CHY_GOVERNOR_PROMOTION_RESOURCE_MANAGER_SUPPLY_CHAIN_MANAGEMENT_DESCRIPTION',
		2, 0, 0);

-- Associate the modifiers with it.	   
INSERT INTO GovernorPromotionModifiers (GovernorPromotionType, ModifierId) 
VALUES ('CHY_GOVERNOR_PROMOTION_RESOURCE_MANAGER_SUPPLY_CHAIN_MANAGEMENT', 'CHY_SUPPLY_CHAIN_MANAGEMENT_BUILDING_PRODUCTION'),
       ('CHY_GOVERNOR_PROMOTION_RESOURCE_MANAGER_SUPPLY_CHAIN_MANAGEMENT', 'CHY_SUPPLY_CHAIN_MANAGEMENT_REGIONAL_RANGE_BONUS');
 
-- Update whatever required industrialist prereq to now require supply chain management.
UPDATE GovernorPromotionPrereqs 
SET PrereqGovernorPromotion = 'CHY_GOVERNOR_PROMOTION_RESOURCE_MANAGER_SUPPLY_CHAIN_MANAGEMENT' 
WHERE PrereqGovernorPromotion = 'GOVERNOR_PROMOTION_RESOURCE_MANAGER_INDUSTRIALIST';
 
 -- Update prereqs for Expedition and Industrialist promotions to be surplus logistics.
UPDATE GovernorPromotionPrereqs SET PrereqGovernorPromotion='GOVERNOR_PROMOTION_RESOURCE_MANAGER_SURPLUS_LOGISTICS' WHERE GovernorPromotionType='GOVERNOR_PROMOTION_RESOURCE_MANAGER_EXPEDITION';
UPDATE GovernorPromotionPrereqs SET PrereqGovernorPromotion='GOVERNOR_PROMOTION_RESOURCE_MANAGER_SURPLUS_LOGISTICS' WHERE GovernorPromotionType='GOVERNOR_PROMOTION_RESOURCE_MANAGER_INDUSTRIALIST' ;

-- Remove Groundbreaker if it still shows up somewhere.
DELETE FROM GovernorPromotionPrereqs 
WHERE PrereqGovernorPromotion='GOVERNOR_PROMOTION_RESOURCE_MANAGER_GROUNDBREAKER';

-- Update the visual order of Surplus Logistics and Industrialist promotions
UPDATE GovernorPromotions SET Level=0, Column=1, BaseAbility=1 WHERE GovernorPromotionType='GOVERNOR_PROMOTION_RESOURCE_MANAGER_SURPLUS_LOGISTICS';
UPDATE GovernorPromotions SET Level=1, Column=0 WHERE GovernorPromotionType='GOVERNOR_PROMOTION_RESOURCE_MANAGER_INDUSTRIALIST';

-- Remove Groundbreaker from Magnus' promotions.
DELETE FROM GovernorPromotionSets 
WHERE GovernorType = 'GOVERNOR_THE_RESOURCE_MANAGER' AND GovernorPromotion = 'GOVERNOR_PROMOTION_RESOURCE_MANAGER_GROUNDBREAKER';

-- And add Supply Chain Management in
INSERT INTO GovernorPromotionSets (GovernorType, GovernorPromotion)
VALUES ('GOVERNOR_THE_RESOURCE_MANAGER', 'CHY_GOVERNOR_PROMOTION_RESOURCE_MANAGER_SUPPLY_CHAIN_MANAGEMENT');

INSERT INTO GovernorPromotionPrereqs (GovernorPromotionType, PrereqGovernorPromotion)
VALUES ('CHY_GOVERNOR_PROMOTION_RESOURCE_MANAGER_SUPPLY_CHAIN_MANAGEMENT', 'GOVERNOR_PROMOTION_RESOURCE_MANAGER_INDUSTRIALIST');

-- Reduce the amount of food provided by Surplus Logistics to incoming trade routes now that it is the built-in promotion.
UPDATE ModifierArguments SET Value = Value / 2
WHERE ModifierId = 'SURPLUS_LOGISTICS_TRADE_ROUTE_FOOD' AND Name = 'Amount';
