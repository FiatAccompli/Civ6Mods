-- ============================= --
--	Copyright 2018 FiatAccompli  --
-- ============================= --

INSERT INTO LocalizedText (Language, Tag, Text)
VALUES ('en_US', 'LOC_CHY_GOVERNOR_PROMOTION_RESOURCE_MANAGER_SUPPLY_CHAIN_MANAGEMENT_NAME', 'Supply Chain Manager'),
       ('en_US', 'LOC_CHY_GOVERNOR_PROMOTION_RESOURCE_MANAGER_SUPPLY_CHAIN_MANAGEMENT_DESCRIPTION', 
	    'Industrial Zone buildings with regional benefits have +1 [ICON_Production] production. Regional range of Industrial Zone buildings reach 3 tiles further.');

UPDATE LocalizedText 
SET Text = REPLACE(Text, '+2 ', '+1 ')
WHERE Tag = 'LOC_GOVERNOR_PROMOTION_RESOURCE_MANAGER_SURPLUS_LOGISTICS_DESCRIPTION';