-- ===========================================================================
--	HUD Top of Screen Area 
--	XP1 Override
-- ===========================================================================
include( "TopPanel" );


-- ===========================================================================
-- Super functions
-- ===========================================================================
BASE_LateInitialize = LateInitialize;


-- ===========================================================================
function OnLocalPlayerTurnBegin()
	local eraTable:table = Game.GetEras();
	local localPlayerID:number = Game.GetLocalPlayer();

	if localPlayerID == PlayerTypes.NONE then
		Controls.Backing:SetTexture("TopBar_Bar");
	else
		local pGameEras:table = Game.GetEras();
		local isFinalEra:boolean = pGameEras:GetCurrentEra() == pGameEras:GetFinalEra();
		if isFinalEra then
			Controls.Backing:SetTexture("TopBar_Bar");
		else
			if eraTable:HasHeroicGoldenAge(localPlayerID) then
				Controls.Backing:SetTexture("TopBar_Bar_Heroic");
			elseif eraTable:HasGoldenAge(localPlayerID) then
				Controls.Backing:SetTexture("TopBar_Bar_Golden");
			elseif eraTable:HasDarkAge(localPlayerID) then
				Controls.Backing:SetTexture("TopBar_Bar_Dark");
			else
				Controls.Backing:SetTexture("TopBar_Bar");
			end
		end
	end
end


-- ===========================================================================
function LateInitialize()
	BASE_LateInitialize();
	Events.LocalPlayerTurnBegin.Add( OnLocalPlayerTurnBegin );
	OnLocalPlayerTurnBegin();
	if not XP1_LateInitialize then
		RefreshYields();
	end
end
