--[[
-- Created by Tyler Berry, Aug 14 2017
-- Copyright (c) Firaxis Games
--]]
-- ===========================================================================
-- Base File
-- ===========================================================================
include("WorldTracker");
include("AllianceResearchSupport");

-- ===========================================================================
--	CACHE BASE FUNCTIONS
-- ===========================================================================
BASE_UpdateResearchPanel = UpdateResearchPanel;
BASE_RealizeCurrentResearch = RealizeCurrentResearch;
BASE_ShouldUpdateResearchPanel = ShouldUpdateResearchPanel;
BASE_RealizeEmptyMessage = RealizeEmptyMessage;

-- ===========================================================================
--	OVERRIDE BASE FUNCTIONS
-- ===========================================================================
function UpdateResearchPanel( isHideResearch:boolean )
	CalculateAllianceResearchBonus();
	BASE_UpdateResearchPanel(isHideResearch);
end

function RealizeCurrentResearch( playerID:number, kData:table, kControl:table )

	BASE_RealizeCurrentResearch(playerID, kData, kControl);

	if kControl == nil then
		kControl = Controls;
	end

	local showAllianceIcon = false;
	if kData ~= nil then
		local techID = GameInfo.Technologies[kData.TechType].Index;
		if AllyHasOrIsResearchingTech(techID) then
			kControl.AllianceIcon:SetToolTipString(GetAllianceIconToolTip());
			kControl.AllianceIcon:SetColor(GetAllianceIconColor());
			showAllianceIcon = true;
		end
	end
	kControl.Alliance:SetShow(showAllianceIcon);
end

function ShouldUpdateResearchPanel(ePlayer:number, eTech:number)
	return BASE_ShouldUpdateResearchPanel(ePlayer, eTech) or HasMaxLevelResearchAlliance(ePlayer);
end

-- ===========================================================================

function RealizeEmptyMessage(panelsVisible:boolean)
	local crisisData = Game.GetEmergencyManager():GetEmergencyInfoTable(Game.GetLocalPlayer());
	BASE_RealizeEmptyMessage(panelsVisible or (next(crisisData) ~= nil));
end

function Initialize()
	ContextPtr:LoadNewContext("WorldCrisisTracker", Controls.PanelStack);
	Controls.TutorialGoals:SetHide(true);
	Controls.PanelStack:CalculateSize();
end
Initialize();