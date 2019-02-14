-- ===========================================================================
--	HUD Partial Screen Hooks
--	Hooks to buttons in the upper right of the main screen HUD.
-- ===========================================================================
include("GameCapabilities");
include("InstanceManager");


-- ===========================================================================
--	Action Hotkeys
-- ===========================================================================
local m_ToggleCSId		:number = Input.GetActionId("ToggleCityStates");
local m_ToggleEspId		:number = Input.GetActionId("ToggleEspionage");
local m_ToggleRankingsId:number = Input.GetActionId("ToggleRankings");
local m_ToggleTradeId	:number = Input.GetActionId("ToggleTradeRoutes");    


-- ===========================================================================
--	GLOBALS
-- ===========================================================================


-- ===========================================================================
--	CONSTANTS
-- ===========================================================================
local MIN_BG_SIZE				: number = 226;		-- Minimum size for the non-tiling component of the launch container
local BG_PADDING				: number = 116;		-- Additional pad the background PAST the size of the hooks
local BG_TILE_PADDING			: number = 20;		-- Inner padding to give the tile of the hook bar so that it does not show behind the hook bar itself
local BG_TOTAL_OFFSCREEN_OFFSET	: number = -126;	-- Amount of negative offset to totally remove the partial hook bar from the screen.  Used so that we can add back the size of the hook stack to the bar when we have < 2 hooks visible


-- ===========================================================================
--	VARIABLES
-- ===========================================================================
local m_isEspionageUnlocked		:boolean = false;
local m_isTradeRoutesUnlocked	:boolean = false;
local m_isCityStatesUnlocked	:boolean = false;
local m_isDebug					:boolean = false;
local m_ScreenHookIM			:table = InstanceManager:new("ScreenHookInstance", "ScreenHookStack", Controls.ButtonStack);
local m_kPartialScreens			:table = {}	-- Screens that are considered "partial" and mutually exclusive in showing.


-- ===========================================================================
--	FUNCITONS
-- ===========================================================================


-- ===========================================================================
--	Checks all the screens or if a screen name is checked in, will check that
--	specific one.
--	RETURNS: true if any partial screen is open; false otherwise.
-- ===========================================================================
function IsPartialScreenOpen( optionalScreenName:string )
	local kScreensToCheck:table = m_kPartialScreens;
	if optionalScreenName then
		kScreensToCheck = { optionalScreenName };	-- Override with specific screne
	end

	-- Loop through the screens to check, they may be attached in a few locations
	-- so if one location fails, cascade to check the next location.
	for _,contextName:string in ipairs( kScreensToCheck ) do
		local pContextControl :table = ContextPtr:LookUpControl("/InGame/" .. contextName );
		if pContextControl == nil then
			pContextControl = ContextPtr:LookUpControl("/InGame/AdditionalUserInterfaces/" .. contextName );	-- Cascade check
		end
		if pContextControl == nil then
			UI.DataError("Cannot determine if partial screen \"/InGame/"..contextName.."\" is visible because it wasn't found at that path.");		
		elseif not pContextControl:IsHidden() then 
			return true;			
		end
	end
	return false;
end


-- ===========================================================================
--	UI Control Callback
-- ===========================================================================
function OnToggleReportsList()
	if IsPartialScreenOpen("ReportsList") then
		LuaEvents.PartialScreenHooks_CloseReportsList();
	else		
		if IsPartialScreenOpen() then				-- Only play open sound if no partial screen is open.
			LuaEvents.PartialScreenHooks_CloseAllExcept("ReportsList");
		end		
		LuaEvents.PartialScreenHooks_OpenReportsList();
	end	
end

-- ===========================================================================
--	UI Control Callback
-- ===========================================================================
function OnToggleEspionage()		
	if IsPartialScreenOpen("EspionageOverview") then
		LuaEvents.PartialScreenHooks_CloseEspionage();
	else		
		LuaEvents.MinimapPanel_CloseAllLenses();
		if IsPartialScreenOpen() then				-- Only play open sound if no partial screen is open.
			LuaEvents.PartialScreenHooks_CloseAllExcept("EspionageOverview");
		end		
		LuaEvents.PartialScreenHooks_OpenEspionage();
	end	
end

-- ===========================================================================
--	UI Control Callback
-- ===========================================================================
function OnToggleCityStates()
	if IsPartialScreenOpen("CityStates") then
		LuaEvents.PartialScreenHooks_CloseCityStates();
	else		
		LuaEvents.MinimapPanel_CloseAllLenses();
		if IsPartialScreenOpen() then				-- Only play open sound if no partial screen is open.
			LuaEvents.PartialScreenHooks_CloseAllExcept("CityStates");
		end		
		LuaEvents.PartialScreenHooks_OpenCityStates();
	end	
end

-- ===========================================================================
--	UI Control Callback
-- ===========================================================================
function OnToggleTradeOverview()
	if IsPartialScreenOpen("TradeOverview") then
		LuaEvents.PartialScreenHooks_CloseTradeOverview();
	else		
		LuaEvents.MinimapPanel_CloseAllLenses();
		if IsPartialScreenOpen() then				-- Only play open sound if no partial screen is open.
			LuaEvents.PartialScreenHooks_CloseAllExcept("TradeOverview");
		end		
		LuaEvents.PartialScreenHooks_OpenTradeOverview();
	end	
end

-- ===========================================================================
--	UI Control Callback
-- ===========================================================================
function OnToggleWorldRankings()
	if IsPartialScreenOpen("WorldRankings") then
		LuaEvents.PartialScreenHooks_CloseWorldRankings();
	else		
		LuaEvents.MinimapPanel_CloseAllLenses();
		if IsPartialScreenOpen() then				-- Only play open sound if no partial screen is open.
			LuaEvents.PartialScreenHooks_CloseAllExcept("WorldRankings");
		end		
		LuaEvents.PartialScreenHooks_OpenWorldRankings();
	end	
end

-- ===========================================================================
--	UI Control Callback
-- ===========================================================================
function OnOpenDiplomacy()
	LuaEvents.TopPanel_OpenDiplomacyActionView();
end

-- ===========================================================================
--	Add content and size.
-- ===========================================================================
function Realize()

	m_ScreenHookIM:ResetInstances();	-- Reset screen hooks instances
	m_kPartialScreens = {};				-- Fresh table

	AddScreenHooks();

	table.insert(m_kPartialScreens, "WorldRankings");	-- Staticly definted in XML

	-- The Launch Bar width should accomodate how many hooks are currently in the stack.  
	Controls.ButtonStack:CalculateSize();

	if( MIN_BG_SIZE > Controls.ButtonStack:GetSizeX() + BG_PADDING) then
		Controls.LaunchBacking:SetSizeX(MIN_BG_SIZE);
		Controls.LaunchBacking:SetOffsetX(BG_TOTAL_OFFSCREEN_OFFSET + (Controls.ButtonStack:GetSizeX() + BG_TILE_PADDING));
	else
		Controls.LaunchBacking:SetOffsetX(2);
		Controls.LaunchBacking:SetSizeX(Controls.ButtonStack:GetSizeX() + BG_PADDING);
	end
	Controls.LaunchBackingDropShadow:SetSizeX(Controls.ButtonStack:GetSizeX() + BG_TILE_PADDING);
	Controls.LaunchBackingTile:SetSizeX(Controls.ButtonStack:GetSizeX() - BG_TILE_PADDING);

	LuaEvents.PartialScreenHooks_Realize();	-- Signal resize occurred.
end

-- ===========================================================================
--	Add any dynamic screen hooks which get displayed in the order that they are added.
--	Most every screen hooks are dynamic except those that needed explict 
--	tutorial tags within them.
-- ===========================================================================
function AddScreenHooks()
	AddCityStateHook();
	AddTradeHook();
	AddEspionageHook();
	AddReportsHook();
end

-- ===========================================================================
function AddCityStateHook()
	if (m_isCityStatesUnlocked and HasCapability("CAPABILITY_CITY_STATES_VIEW")) then
		AddScreenHook("CityStates", "LaunchBar_Hook_CityStates", "LOC_PARTIALSCREEN_CITYSTATES_TOOLTIP", OnToggleCityStates );
	end
end

-- ===========================================================================
function AddTradeHook()
	if (m_isTradeRoutesUnlocked and HasCapability("CAPABILITY_TRADE_VIEW")) then
		AddScreenHook("TradeOverview", "LaunchBar_Hook_Trade", "LOC_PARTIALSCREEN_TRADEROUTES_TOOLTIP", OnToggleTradeOverview );
	end
end

-- ===========================================================================
function AddEspionageHook()
	if (m_isEspionageUnlocked and HasCapability("CAPABILITY_ESPIONAGE_VIEW")) then
		AddScreenHook("EspionageOverview", "LaunchBar_Hook_Espionage", "LOC_PARTIALSCREEN_ESPIONAGE_TOOLTIP", OnToggleEspionage );
	end
end

-- ===========================================================================
function AddReportsHook()
	if ( HasCapability("CAPABILITY_REPORTS_LIST") ) then
		AddScreenHook("ReportsList", "LaunchBar_Hook_Reports", "LOC_PARTIALSCREEN_REPORTS_TOOLTIP", OnToggleReportsList );
	end
end

-- ===========================================================================
--	Add a button to the partial screen hooks.
--
--	contextName,	Name of the context which will be shown.
--	texture,		Texture to show on the button.
--	tooltip,		Tooltip when mouse hovered (or 2nd finger touch)
--	callback,		The function executed when activated.
-- ===========================================================================
function AddScreenHook( contextName:string, texture:string, tooltip:string, callback:ifunction)
	
	if m_kPartialScreens[contextName] == nil then
		table.insert(m_kPartialScreens, contextName);
	else
		UI.DataError("Attempt to add a screen hook '"..contextName.."' which already exists!");
		return;
	end
	
	local screenHookInst:table = m_ScreenHookIM:GetInstance();
	screenHookInst.ScreenHookImage:SetTexture(texture);
	screenHookInst.ScreenHookButton:SetToolTipString(Locale.Lookup(tooltip));
	screenHookInst.ScreenHookButton:RegisterCallback( Mouse.eLClick, callback );
	screenHookInst.ScreenHookButton:RegisterCallback( Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);
end

-- ===========================================================================
--	Event
--	Capture the meet civ event to see if we have encountered a city-state
-- ===========================================================================
function OnDiplomacyMeet( player1ID:number, player2ID:number )
	if(not m_isCityStatesUnlocked) then
		local LocalPlayerID:number = Game.GetLocalPlayer();
		-- Have a local player?
		if(LocalPlayerID ~= -1) then
			-- Was the local player involved, and was it a minor civ that was met?
			local metPlayer = Players[player2ID];
			if (player1ID == LocalPlayerID and metPlayer:IsMinor()) then
				m_isCityStatesUnlocked = true;
				Realize();
			end
		end
	end
end

-- ===========================================================================
function CheckTradeCapacity( pLocalPlayer:table )
	if (not m_isTradeRoutesUnlocked) then
		local playerTrade	:table	= pLocalPlayer:GetTrade();
		local routesCapacity:number = playerTrade:GetOutgoingRouteCapacity();
		if (routesCapacity > 0) then
			m_isTradeRoutesUnlocked = true;
		end
	end
end

-- ===========================================================================
function CheckSpyCapacity( pLocalPlayer:table )
	if (not m_isEspionageUnlocked) then
		local playerDiplo	:table = pLocalPlayer:GetDiplomacy();
		local spyCapacity:number = playerDiplo:GetSpyCapacity();
		if (spyCapacity > 0) then
			m_isEspionageUnlocked = true;
		end
	end
end

-- ===========================================================================
--	Event
--	Capture spies or traders becoming unlocked
-- ===========================================================================
function OnCivicCompleted( player:number, civic:number, isCanceled:boolean)
	if player == Game.GetLocalPlayer() and (not m_isEspionageUnlocked or not m_isTradeRoutesUnlocked) then
		local pLocalPlayer :table = Players[player];
		if (pLocalPlayer == nil) then
			return;
		end
		CheckTradeCapacity(pLocalPlayer);
		CheckSpyCapacity(pLocalPlayer);

		Realize();
	end
end

-- ===========================================================================
--	Event
-- ===========================================================================
function OnResearchCompleted( player:number, tech:number )
	if player == Game.GetLocalPlayer() and not m_isTradeRoutesUnlocked then
		local pLocalPlayer = Players[player];
		if pLocalPlayer then
			return;
		end
		CheckTradeCapacity(pLocalPlayer);

		Realize();
	end
end

-- ===========================================================================
--	Event
--	Check trade, spy, and partial screen hooks
-- ===========================================================================
function OnTurnBegin()
	local ePlayer:number = Game.GetLocalPlayer();
	if ePlayer == -1 then
		return;
	end
	pLocalPlayer = Players[ePlayer];  

	CheckTradeCapacity(pLocalPlayer);
	CheckSpyCapacity(pLocalPlayer);
	CheckCityStatesUnlocked(pLocalPlayer);

	Realize();
end

-- ===========================================================================
function CheckCityStatesUnlocked( pLocalPlayer:table )
	--	Check to see if the player has met any city-states
	if (not m_isCityStatesUnlocked) then
		local localDiplomacy:table = pLocalPlayer:GetDiplomacy();
		local aPlayers = PlayerManager.GetAliveMinors();
		for _, pPlayer in ipairs(aPlayers) do
			if (pPlayer:IsMinor() and localDiplomacy:HasMet(pPlayer:GetID())) then
				m_isCityStatesUnlocked = true;	
			end
		end
	end
end

-- ===========================================================================
--	Game Engine Event
-- ===========================================================================
function OnInterfaceModeChanged( eOldMode:number, eNewMode:number )
	if eNewMode == InterfaceModeTypes.VIEW_MODAL_LENS then
		ContextPtr:SetHide(true);
	end
	if eOldMode == InterfaceModeTypes.VIEW_MODAL_LENS then
		ContextPtr:SetHide(false);
	end
end


-- ===========================================================================
--	Input Hotkey Event
--	actionId,	A number from the engine which represents a hotkey pressed.
-- ===========================================================================
function OnInputActionTriggered( actionId:number )

	if actionId == m_ToggleRankingsId and HasCapability("CAPABILITY_WORLD_RANKINGS") then
        OnToggleWorldRankings();
        UI.PlaySound("Play_UI_Click");
	end
	
	if m_isCityStatesUnlocked and actionId == m_ToggleCSId and HasCapability("CAPABILITY_CITY_STATES_VIEW") then
        OnToggleCityStates();
        UI.PlaySound("Play_UI_Click");
	end

	if m_isEspionageUnlocked and actionId == m_ToggleEspId and HasCapability("CAPABILITY_ESPIONAGE_VIEW") then
        if UI.QueryGlobalParameterInt("DISABLE_ESPIONAGE_HOTKEY") ~= 1 then
            OnToggleEspionage();
            UI.PlaySound("Play_UI_Click");
        end
	end

	if m_isTradeRoutesUnlocked and actionId == m_ToggleTradeId and HasCapability("CAPABILITY_TRADE_VIEW") then
        OnToggleTradeOverview();
        UI.PlaySound("Play_UI_Click");
	end
end

-- ===========================================================================
--	Event
--	Reset the hooks that are visible for hotseat
-- ===========================================================================
function OnLocalPlayerChanged()
	m_isEspionageUnlocked	= false;	
	m_isTradeRoutesUnlocked	= false;
	m_isCityStatesUnlocked	= false;
	OnTurnBegin();
end

-- ===========================================================================
--	Lua Event
--	Tutorial system is requesting any partial screens open, to be closed.
-- ===========================================================================
function OnTutorialCloseAll()
	LuaEvents.PartialScreenHooks_CloseAllExcept("_AllTheThings");
end


-- ===========================================================================
--	Any initial state functions called here; may be "added" or "replaced" by
--	a MOD (such as an expansion).
-- ===========================================================================
function LateInitialize()
	OnTurnBegin();
end

-- ===========================================================================
--	Called after all contexts (this and replacement contexts) are loaded.
-- ===========================================================================
function OnInit( isReload:boolean )
	LateInitialize();
end

-- ===========================================================================
function Initialize()

	ContextPtr:SetInitHandler( OnInit );
	Controls.WorldRankingsButton:RegisterCallback( Mouse.eLClick,	OnToggleWorldRankings );
	Controls.WorldRankingsButton:RegisterCallback( Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);

	Events.CivicCompleted.Add(OnCivicCompleted);
	Events.ResearchCompleted.Add(OnResearchCompleted);
	Events.DiplomacyMeet.Add( OnDiplomacyMeet );
	Events.InputActionTriggered.Add( OnInputActionTriggered );
	Events.InterfaceModeChanged.Add( OnInterfaceModeChanged );
	Events.LocalPlayerChanged.Add( OnLocalPlayerChanged );
	Events.TurnBegin.Add( OnTurnBegin );

	LuaEvents.Tutorial_CloseAllPartialScreens.Add( OnTutorialCloseAll );	
end
Initialize();
