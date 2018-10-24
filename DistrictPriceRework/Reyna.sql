-- Replace Reyna's Contractor promotion (can purchase districts with gold) 
-- with the Free Trade Zone promotion that gives +2 gold to both parties for 
-- incoming trade routes from other civs and gives +2 gold for outgoing international 
-- trade routes.

INSERT INTO Types (Type, Kind)
VALUES ('DCR_GOVERNOR_PROMOTION_MERCHANT_FREE_TRADE_ZONE', 'KIND_GOVERNOR_PROMOTION');

INSERT INTO Modifiers (ModifierId, ModifierType)
VALUES ('DCR_FREE_TRADE_ZONE_TRADE_ROUTE_EXTRA_GOLD_TO_OTHERS', 'MODIFIER_SINGLE_CITY_ADJUST_TRADE_ROUTE_YIELD_TO_OTHERS'),
       ('DCR_FREE_TRADE_ZONE_TRADE_ROUTE_EXTRA_GOLD_FROM_OTHERS', 'MODIFIER_SINGLE_CITY_ADJUST_TRADE_ROUTE_YIELD_FROM_OTHERS'),
       ('DCR_FREE_TRADE_ZONE_TRADE_ROUTE_EXTRA_GOLD_FOR_INTERNATIONAL', 'MODIFIER_SINGLE_CITY_ADJUST_TRADE_ROUTE_YIELD_FOR_INTERNATIONAL');

INSERT INTO ModifierArguments (ModifierId, Name, Type, Value)
VALUES ('DCR_FREE_TRADE_ZONE_TRADE_ROUTE_EXTRA_GOLD_TO_OTHERS', 'YieldType', 'ARGTYPE_IDENTITY', 'YIELD_GOLD'),
       ('DCR_FREE_TRADE_ZONE_TRADE_ROUTE_EXTRA_GOLD_TO_OTHERS', 'Amount', 'ARGTYPE_IDENTITY', '2'),
       ('DCR_FREE_TRADE_ZONE_TRADE_ROUTE_EXTRA_GOLD_FROM_OTHERS', 'YieldType', 'ARGTYPE_IDENTITY', 'YIELD_GOLD'),
       ('DCR_FREE_TRADE_ZONE_TRADE_ROUTE_EXTRA_GOLD_FROM_OTHERS', 'Amount', 'ARGTYPE_IDENTITY', '2'),
       ('DCR_FREE_TRADE_ZONE_TRADE_ROUTE_EXTRA_GOLD_FOR_INTERNATIONAL', 'YieldType', 'ARGTYPE_IDENTITY', 'YIELD_GOLD'),
       ('DCR_FREE_TRADE_ZONE_TRADE_ROUTE_EXTRA_GOLD_FOR_INTERNATIONAL', 'Amount', 'ARGTYPE_IDENTITY', '2');

-- Create the new governor promotion Free Trade Zone
INSERT INTO GovernorPromotions (GovernorPromotionType, Name, Description, Level, Column, BaseAbility)
VALUES ('DCR_GOVERNOR_PROMOTION_MERCHANT_FREE_TRADE_ZONE',
        'LOC_DCR_GOVERNOR_PROMOTION_THE_MERCHANT_FREE_TRADE_ZONE_NAME',
        'LOC_DCR_GOVERNOR_PROMOTION_THE_MERCHANT_FREE_TRADE_ZONE_DESCRIPTION',
        3, 0, 0);

-- Associate the modifiers with it.	   
INSERT INTO GovernorPromotionModifiers (GovernorPromotionType, ModifierId) 
VALUES ('DCR_GOVERNOR_PROMOTION_MERCHANT_FREE_TRADE_ZONE', 'DCR_FREE_TRADE_ZONE_TRADE_ROUTE_EXTRA_GOLD_TO_OTHERS'),
       ('DCR_GOVERNOR_PROMOTION_MERCHANT_FREE_TRADE_ZONE', 'DCR_FREE_TRADE_ZONE_TRADE_ROUTE_EXTRA_GOLD_FROM_OTHERS'),
       ('DCR_GOVERNOR_PROMOTION_MERCHANT_FREE_TRADE_ZONE', 'DCR_FREE_TRADE_ZONE_TRADE_ROUTE_EXTRA_GOLD_FOR_INTERNATIONAL');

-- Remove contractor promotion from merchant promotions
DELETE FROM GovernorPromotionSets
WHERE GovernorType = 'GOVERNOR_THE_MERCHANT' AND 
      GovernorPromotion = 'GOVERNOR_PROMOTION_MERCHANT_CONTRACTOR';

-- Add Free Trade Zone in.
INSERT INTO GovernorPromotionSets (GovernorType, GovernorPromotion)
VALUES ('GOVERNOR_THE_MERCHANT', 'DCR_GOVERNOR_PROMOTION_MERCHANT_FREE_TRADE_ZONE');

UPDATE GovernorPromotionPrereqs
SET GovernorPromotionType = 'DCR_GOVERNOR_PROMOTION_MERCHANT_FREE_TRADE_ZONE'
WHERE GovernorPromotionType = 'GOVERNOR_PROMOTION_MERCHANT_CONTRACTOR';

UPDATE GovernorPromotionPrereqs
SET PrereqGovernorPromotion = 'DCR_GOVERNOR_PROMOTION_MERCHANT_FREE_TRADE_ZONE'
WHERE PrereqGovernorPromotion = 'GOVERNOR_PROMOTION_MERCHANT_CONTRACTOR';
