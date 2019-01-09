-- ============================= --
--	Copyright 2018 FiatAccompli  --
-- ============================= --

-- Colors for lenses.

-- Yellow to bright purple.
INSERT INTO Colors (Type, Red, Green, Blue, Alpha)
VALUES ('COLOR_UNIT_ATTRITION_LENS_RATE_0', 0, 0.75, 0, 0.5),
       ('COLOR_UNIT_ATTRITION_LENS_RATE_5', 1, 1, 0, 0.5),
       ('COLOR_UNIT_ATTRITION_LENS_RATE_10', 1, 0.5, 0, 0.5),
       ('COLOR_UNIT_ATTRITION_LENS_RATE_15',   1, 0, 0, 0.5),
       ('COLOR_UNIT_ATTRITION_LENS_RATE_20', 1, 0, 0.5, 0.5),
       ('COLOR_UNIT_ATTRITION_LENS_RATE_GT_20', 1, 0, 1, 0.5);

-- 10 colors around the color wheel starting at red.
INSERT INTO Colors (Type, Red, Green, Blue, Alpha)
VALUES ('COLOR_UNIT_ATTRITION_DISTANCE_LENS_0', 1, 0, 0, 0.5),
       ('COLOR_UNIT_ATTRITION_DISTANCE_LENS_1', 1, 0.6, 0, 0.5),
       ('COLOR_UNIT_ATTRITION_DISTANCE_LENS_2', 0.8, 1, 0, 0.5),
       ('COLOR_UNIT_ATTRITION_DISTANCE_LENS_3', 0.2, 1, 0, 0.5),
       ('COLOR_UNIT_ATTRITION_DISTANCE_LENS_4', 0, 1, 0.4, 0.5),
       ('COLOR_UNIT_ATTRITION_DISTANCE_LENS_5', 0, 1, 1, 0.5),
       ('COLOR_UNIT_ATTRITION_DISTANCE_LENS_6', 0, 0.4, 1, 0.5),
       ('COLOR_UNIT_ATTRITION_DISTANCE_LENS_7', 0.2, 0, 1, 0.5),
       ('COLOR_UNIT_ATTRITION_DISTANCE_LENS_8', 0.8, 0, 1, 0.5),
       ('COLOR_UNIT_ATTRITION_DISTANCE_LENS_9', 1, 0, 0.6, 0.5),
	   ('COLOR_UNIT_ATTRITION_DISTANCE_LENS_UNREACHABLE', 1, 1, 1, 0.5);