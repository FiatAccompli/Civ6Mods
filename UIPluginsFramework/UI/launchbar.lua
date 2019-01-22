-- ===========================================================================
--	HUD Launch Bar
--	Controls raising full-screen and "choosers"
-- ===========================================================================

include( "GameCapabilities" );

local m_numOpen:number = 0;
local isTechTreeOpen	:boolean = false;
local isCivicsTreeOpen	:boolean = false;
local isGreatPeopleOpen	:boolean = false;
local isGreatWorksOpen	:boolean = false;
local isReligionOpen	:boolean = false;
local isGovernmentOpen	:boolean = false;

local m_isGreatPeopleUnlocked	:boolean = false;
local m_isGreatWorksUnlocked	:boolean = false;
local m_isReligionUnlocked		:boolean = false;
local m_isGovernmentUnlocked	:boolean = false;

local m_isTechTreeAvailable		:boolean = false;
local m_isCivicsTreeAvailable	:boolean = false;
local m_isGovernmentAvailable	:boolean = false;
local m_isReligionAvailable		:boolean = false;
local m_isGreatPeopleAvailable	:boolean = false;
local m_isGreatWorksAvailable	:boolean = false;

local isDebug			:boolean = false;			-- Set to true to force all hook buttons to show on game start	

-- Map from extra button ids to button controls.
local m_extraButtons:table = {};

-- ===========================================================================
--	Callbacks
-- ===========================================================================
function OnOpenGovernment()
	local ePlayer		:number = Game.GetLocalPlayer();
	if ePlayer == -1 then
		return; -- Probably autoplay
	end

	localPlayer = Players[ePlayer];
	if localPlayer == nil then
		return;
	end

	local kCulture:table	= localPlayer:GetCulture();
	if ( kCulture:IsInAnarchy() ) then -- Anarchy? No gov't for you.
		if isGovernmentOpen then
			LuaEvents.LaunchBar_CloseGovernmentPanel()
		end
		return;
	end

	if isGovernmentOpen then
		LuaEvents.LaunchBar_CloseGovernmentPanel()
	else
		CloseAllPopups();
		if (kCulture:CivicCompletedThisTurn() and kCulture:CivicUnlocksGovernment(kCulture:GetCivicCompletedThisTurn()) and not kCulture:GovernmentChangeConsidered()) then
			-- Blocking notification that NEW GOVERNMENT is available, make sure player takes a look	
			LuaEvents.LaunchBar_GovernmentOpenGovernments();
		else 
			-- Normal entry to my Government
			LuaEvents.LaunchBar_GovernmentOpenMyGovernment();
		end
	end
end

-- ===========================================================================
local m_ActiveAddition = nil;

function CloseAllPopups()
	LuaEvents.LaunchBar_CloseGreatPeoplePopup();
	LuaEvents.LaunchBar_CloseGreatWorksOverview();
	LuaEvents.LaunchBar_CloseReligionPanel();
	if isGovernmentOpen then
		LuaEvents.LaunchBar_CloseGovernmentPanel();
	end
	LuaEvents.LaunchBar_CloseTechTree();
	LuaEvents.LaunchBar_CloseCivicsTree();
  -- Pass m_ActiveAddition through a variable because some other mods (namely Better Report Screen)
  -- replace CloseAllPopups with a version that does not pass an argument through to this one.
  LuaEvents.LaunchBar_CloseAllExcept(m_ActiveAddition);
end

function CloseAllExcept(id:string)
  if m_ActiveAddition == nil then
    m_ActiveAddition = id;
    CloseAllPopups()
    m_ActiveAddition = nil;
  end
end

-- ===========================================================================
function OnOpenGreatPeople()
	if isGreatPeopleOpen then
		LuaEvents.LaunchBar_CloseGreatPeoplePopup();
	else
		CloseAllPopups();
		LuaEvents.LaunchBar_OpenGreatPeoplePopup();	
	end
end

-- ===========================================================================
function OnOpenGreatWorks()
	if isGreatWorksOpen then
		LuaEvents.LaunchBar_CloseGreatWorksOverview();
	else
		CloseAllPopups();
		LuaEvents.LaunchBar_OpenGreatWorksOverview();	
	end
end

-- ===========================================================================
function OnOpenReligion()
	if isReligionOpen then
		LuaEvents.LaunchBar_CloseReligionPanel();
	else
		CloseAllPopups();
		LuaEvents.LaunchBar_OpenReligionPanel();	
	end
end

-- ===========================================================================
function OnOpenResearch()
	if isTechTreeOpen then
		LuaEvents.LaunchBar_CloseTechTree();
	else
		CloseAllPopups();
		LuaEvents.LaunchBar_RaiseTechTree();	
	end
end

-- ===========================================================================
function OnOpenCulture()
	if isCivicsTreeOpen then
		LuaEvents.LaunchBar_CloseCivicsTree();
	else
		CloseAllPopups();
		LuaEvents.LaunchBar_RaiseCivicsTree();	
	end
end

-- ===========================================================================
function OnOpenOldCityStates()
	LuaEvents.TopPanel_OpenOldCityStatesPopup();
end

function SetCivicsTreeOpen()
	isCivicsTreeOpen = true;
	OnOpen();
end

function SetTechTreeOpen()
	isTechTreeOpen = true;
	OnOpen();
end

function SetGreatPeopleOpen()
	isGreatPeopleOpen = true;
	OnOpen();
end

function SetGreatWorksOpen()
	isGreatWorksOpen = true;
	OnOpen();
end

function SetReligionOpen()
	isReligionOpen = true;
	OnOpen();
end

function SetGovernmentOpen()
	isGovernmentOpen = true;
	OnOpen();
end

function SetCivicsTreeClosed()
	isCivicsTreeOpen = false;
	OnClose();
end

function SetTechTreeClosed()
	isTechTreeOpen = false;
	OnClose();
end

function SetGreatPeopleClosed()
	isGreatPeopleOpen = false;
	OnClose();
end

function SetGreatWorksClosed()
	isGreatWorksOpen = false;
	OnClose();
end

function SetReligionClosed()
	isReligionOpen = false;
	OnClose();
end

function SetGovernmentClosed()
	isGovernmentOpen = false;
	OnClose();
end

-- ===========================================================================
function OnAddLaunchbarIcon(buttonInfo:table)
  local buttonId = buttonInfo.Id;

  local buttonInstance = m_extraButtons[buttonId]
  if not buttonInstance then
    buttonInstance = {};
    ContextPtr:BuildInstanceForControl("LaunchbarButtonInstance", buttonInstance, Controls.ButtonStack);
    m_extraButtons[buttonId] = buttonInstance;
  end

  local iconTexture = buttonInfo.IconTexture;

  -- Update Icon Info
  buttonInstance.Image:SetColor(iconTexture.Color or 0xFFFFFFFF);
  if iconTexture.Icon then 
    buttonInstance.Image:SetIcon(iconTexture.Icon);
  elseif iconTexture.Sheet then
    buttonInstance.Image:SetTexture(iconTexture.OffsetX or 0, iconTexture.OffsetY or 0, iconTexture.Sheet);
  end

  if buttonInfo.Tooltip then
    buttonInstance.Button:LocalizeAndSetToolTip(buttonInfo.Tooltip);
  end

  textureOffsetX = buttonInfo.BaseTexture.OffsetX or 0;
  textureOffsetY = buttonInfo.BaseTexture.OffsetY or 0;
  textureSheet = buttonInfo.BaseTexture.Sheet;

  local stateOffsetX = buttonInfo.BaseTexture.HoverOffsetX or textureOffsetX;
  local stateOffsetY = buttonInfo.BaseTexture.HoverOffsetY or textureOffsetY;

  if textureSheet then
    buttonInstance.Base:SetTexture(textureOffsetX, textureOffsetY, textureSheet);
    buttonInstance.Button:RegisterMouseEnterCallback(
        function()
          buttonInstance.Base:SetTextureOffsetVal(stateOffsetX, stateOffsetY);
          UI.PlaySound("Main_Menu_Mouse_Over");
        end);
    buttonInstance.Button:RegisterMouseExitCallback(
        function()
          buttonInstance.Base:SetTextureOffsetVal(textureOffsetX, textureOffsetY);
        end);
  end

  buttonInstance.Button:RegisterCallback( Mouse.eLClick, 
      function()
        CloseAllExcept(buttonId);
        LuaEvents.LaunchBar_CustomButtonClicked(buttonId);
      end);

  RefreshView();
end

-- ===========================================================================
--	Lua Event
--	Tutorial system is requesting any screen openned, to be closed.
-- ===========================================================================
function OnTutorialCloseAll()
	CloseAllPopups();
end

-- ===========================================================================
--	Game Engine Event
-- ===========================================================================
function OnInterfaceModeChanged(eOldMode:number, eNewMode:number)
	if eNewMode == InterfaceModeTypes.VIEW_MODAL_LENS then
		ContextPtr:SetHide(true);
	end
	if eOldMode == InterfaceModeTypes.VIEW_MODAL_LENS then
		ContextPtr:SetHide(false);
	end
end


-- ===========================================================================
--	Refresh Data and View
-- ===========================================================================
function RealizeHookVisibility()
	m_isTechTreeAvailable = isDebug or HasCapability("CAPABILITY_TECH_TREE");
	Controls.ScienceButton:SetShow(m_isTechTreeAvailable);
	Controls.ScienceBolt:SetShow(m_isTechTreeAvailable);

	m_isCivicsTreeAvailable = isDebug or HasCapability("CAPABILITY_CIVICS_TREE");
	Controls.CultureButton:SetShow(m_isCivicsTreeAvailable);
	Controls.CultureBolt:SetShow(m_isCivicsTreeAvailable);

	m_isGreatPeopleAvailable = isDebug or (m_isGreatPeopleUnlocked and HasCapability("CAPABILITY_GREAT_PEOPLE_VIEW"));
	Controls.GreatPeopleButton:SetShow(m_isGreatPeopleAvailable);
	Controls.GreatPeopleBolt:SetShow(m_isGreatPeopleAvailable);

	m_isReligionAvailable = isDebug or (m_isReligionUnlocked and HasCapability("CAPABILITY_RELIGION_VIEW"));
	Controls.ReligionButton:SetShow(m_isReligionAvailable);
	Controls.ReligionBolt:SetShow(m_isReligionAvailable);

	m_isGreatWorksAvailable = isDebug or (m_isGreatWorksUnlocked and HasCapability("CAPABILITY_GREAT_WORKS_VIEW"));
	Controls.GreatWorksButton:SetShow(m_isGreatWorksAvailable);
	Controls.GreatWorksBolt:SetShow(m_isGreatWorksAvailable);

	m_isGovernmentAvailable = isDebug or (m_isGovernmentUnlocked and HasCapability("CAPABILITY_GOVERNMENTS_VIEW"));
	Controls.GovernmentButton:SetShow(m_isGovernmentAvailable);
	Controls.GovernmentBolt:SetShow(m_isGovernmentAvailable);

	RefreshView();
end

--	Note on hook show/hide functionality:
--	We do not serialize any of this data, but instead we will check gamestate OnTurnBegin to determine which hooks should be shown.
--	Once the show/hide flags have been set, we return from the function before performing the checks again.
--	For all of the hooks that start in a hidden state, there are two functions needed to correctly capture the event to show/hide the hook:
--	1/2) A function for capturing the event as it happens during a turn of gameplay
--	2/2) A function to check gamestate OnTurnBegin

-- *****************************************************************************
--	Religion Hook 
--	1/2) OnFaithChanged - triggered off of the FaithChanged game event
function OnFaithChanged()
	if (m_isReligionUnlocked) then
		return;
	end
	m_isReligionUnlocked = true;
	RealizeHookVisibility();
end

--	2/2) RefreshReligion - this function checks to see if any faith has been earned
function RefreshReligion()
	local ePlayer:number = Game.GetLocalPlayer();
	if ePlayer == -1 then
		-- Likely auto playing.
		return;
	end
	if m_isReligionUnlocked then
		return;
	end
	local localPlayer = Players[ePlayer];
	local playerReligion		:table	= localPlayer:GetReligion();
	local hasFaithYield			:boolean = playerReligion:GetFaithYield() > 0;
	local hasFaithBalance		:boolean = playerReligion:GetFaithBalance() > 0;
	if (hasFaithYield or hasFaithBalance) then
		m_isReligionUnlocked = true;
	end
	RealizeHookVisibility();
end

-- *****************************************************************************
--	Great Works Hook 
--	1/2) OnGreatWorkCreated - triggered off of the GreatWorkCreated game event
--	*Note - a great work can be added and then traded away/ moved.  I think we should still allow the hook to stay
--	open in this case.  I think it would be strange behavior to have the hook be made available and then removed.
function OnGreatWorkCreated()
	if (m_isGreatWorksUnlocked) then
		return;
	end
	m_isGreatWorksUnlocked = true;
	RealizeHookVisibility();
end

-- also need to capture when a deal has left us with a great work
function OnDiplomacyDealEnacted()
	if (not m_isGreatWorksUnlocked) then
		RefreshGreatWorks();
	end
end

-- turns out, capturing a city can also net us pretty great works
function OnCityCaptured()
	if (not m_isGreatWorksUnlocked) then
		RefreshGreatWorks();
	end
end

--	2/2) RefreshGreatWorks - go through each building checking for GW slots, then query that slot for a slotted great work
function RefreshGreatWorks()
	local ePlayer:number = Game.GetLocalPlayer();
	if ePlayer == -1 then
		-- Likely auto playing.
		return;
	end
	if m_isGreatWorksUnlocked then
		return;
	end
	
	localPlayer = Players[ePlayer];  
	local pCities:table = localPlayer:GetCities();
	for i, pCity in pCities:Members() do
		if pCity ~= nil and pCity:GetOwner() == ePlayer then
			local pCityBldgs:table = pCity:GetBuildings();
			for buildingInfo in GameInfo.Buildings() do
				local buildingIndex:number = buildingInfo.Index;
				if(pCityBldgs:HasBuilding(buildingIndex)) then
					local numSlots:number = pCityBldgs:GetNumGreatWorkSlots(buildingIndex);
					if (numSlots ~= nil and numSlots > 0) then
						for slotIndex=0, numSlots - 1 do
							local greatWorkIndex:number = pCityBldgs:GetGreatWorkInSlot(buildingIndex, slotIndex);
							if (greatWorkIndex ~= -1) then
								m_isGreatWorksUnlocked = true;
								break;
							end
						end
					end
				end
			end
		end
	end
	RealizeHookVisibility();
end

function RefreshGreatPeople()
	local ePlayer:number = Game.GetLocalPlayer();
	if ePlayer == -1 then
		-- Likely auto playing.
		return;
	end
	if m_isGreatPeopleUnlocked then
		return;
	end

	-- Show button if we have any great people in the game
	for greatPerson in GameInfo.GreatPersonIndividuals() do
		m_isGreatPeopleUnlocked = true;
		break;
	end
	RealizeHookVisibility();
end

-- *****************************************************************************
--	Government Hook 
--	1/2) OnCivicCompleted - triggered off of the CivicCompleted event - check to see if the unlocked civic unlocked our first policy
function OnCivicCompleted(player:number, civic:number, isCanceled:boolean)
	local ePlayer:number = Game.GetLocalPlayer();
	if ePlayer == -1 then
		return;
	end
	if(not m_isGovernmentUnlocked) then
		local playerCulture:table = Players[ePlayer]:GetCulture();
		if (playerCulture:GetNumPoliciesUnlocked() > 0) then
			m_isGovernmentUnlocked = true;
			RealizeHookVisibility();
		end
	end
end

--	2/2) RefreshGovernment - Check against the number of policies unlocked
function RefreshGovernment()
	local ePlayer:number = Game.GetLocalPlayer();
	if ePlayer == -1 then
		-- Likely auto playing.
		return;
	end

	local fnSetFreePolicyFlag = function( bIsFree:boolean )
			Controls.PoliciesAvailableIndicator:SetShow(bIsFree);
			Controls.PoliciesAvailableIndicator:SetToolTipString(
				bIsFree and Locale.Lookup("LOC_HUD_GOVT_FREE_CHANGES") or nil );
		end

	-- GOVERNMENT BUTTON
	local kCulture:table = Players[ePlayer]:GetCulture();
	if ( kCulture:GetNumPoliciesUnlocked() <= 0 ) then
		Controls.GovernmentButton:SetToolTipString(Locale.Lookup("LOC_GOVERNMENT_DOESNT_UNLOCK"));
		Controls.GovernmentButton:GetTextControl():SetColor(0xFF666666);
	else
		m_isGovernmentUnlocked = true;
		Controls.GovernmentButton:SetHide(false);
		Controls.GovernmentBolt:SetHide(false);
		if ( kCulture:IsInAnarchy() ) then
			local iAnarchyTurns = kCulture:GetAnarchyEndTurn() - Game.GetCurrentGameTurn();
			Controls.GovernmentButton:SetDisabled(true);
			Controls.GovernmentIcon:SetColorByName("Civ6Red");
			Controls.GovernmentButton:SetToolTipString("[COLOR_RED]".. Locale.Lookup("LOC_GOVERNMENT_ANARCHY_TURNS", iAnarchyTurns) .. "[ENDCOLOR]");
			fnSetFreePolicyFlag( false );

		else
			Controls.GovernmentButton:SetDisabled(false);
			Controls.GovernmentIcon:SetColorByName("White");
			Controls.GovernmentButton:SetToolTipString(Locale.Lookup("LOC_GOVERNMENT_MANAGE_GOVERNMENT_AND_POLICIES"));
			fnSetFreePolicyFlag( kCulture:GetCostToUnlockPolicies() == 0 );
			
		end
	end
	RealizeHookVisibility();
end

-- ===========================================================================
function RefreshView()
	-- The Launch Bar width should accomodate how many hooks are currently in the stack.  
	Controls.ButtonStack:CalculateSize();
	Controls.ButtonStack:ReprocessAnchoring();
	Controls.LaunchBacking:SetSizeX(Controls.ButtonStack:GetSizeX()+116);
	Controls.LaunchBackingTile:SetSizeX(Controls.ButtonStack:GetSizeX()-20);
	Controls.LaunchBarDropShadow:SetSizeX(Controls.ButtonStack:GetSizeX());
	-- When we change size of the LaunchBar, we send this LuaEvent to the Diplomacy Ribbon, so that it can change scroll width to accommodate it
	LuaEvents.LaunchBar_Resize(Controls.ButtonStack:GetSizeX());
end

function UpdateTechMeter( localPlayer:table )
	if ( localPlayer ~= nil and Controls.ScienceHookWithMeter:IsVisible() ) then
		local playerTechs				= localPlayer:GetTechs();
		local currentTechID		:number = playerTechs:GetResearchingTech();

		if(currentTechID >= 0) then
			local progress			:number = playerTechs:GetResearchProgress(currentTechID);
			local cost				:number	= playerTechs:GetResearchCost(currentTechID);
	
			Controls.ScienceMeter:SetPercent(progress/cost);
		else
			Controls.ScienceMeter:SetPercent(0);
		end

		local techInfo:table = GameInfo.Technologies[currentTechID];
		if (techInfo ~= nil) then
			local textureString = "ICON_" .. techInfo.TechnologyType;
			local textureOffsetX, textureOffsetY, textureSheet = IconManager:FindIconAtlas(textureString,38);
			if textureSheet ~= nil then
				Controls.ResearchIcon:SetTexture(textureOffsetX, textureOffsetY, textureSheet);
			end
		end
	else
		Controls.ResearchIcon:SetTexture(0, 0, "LaunchBar_Hook_TechTree");
	end
end

function UpdateCivicMeter( localPlayer:table)
	if ( localPlayer ~= nil and Controls.CultureHookWithMeter:IsVisible() ) then
		local playerCivics				= localPlayer:GetCulture();
		local currentCivicID    :number = playerCivics:GetProgressingCivic();

		if(currentCivicID >= 0) then
			local civicProgress			:number = playerCivics:GetCulturalProgress(currentCivicID);
			local civicCost				:number	= playerCivics:GetCultureCost(currentCivicID);
	
			Controls.CultureMeter:SetPercent(civicProgress/civicCost);
		else
			Controls.CultureMeter:SetPercent(0);
		end

		local CivicInfo:table = GameInfo.Civics[currentCivicID];
		if (CivicInfo ~= nil) then
			local civictextureString = "ICON_" .. CivicInfo.CivicType;
			local civictextureOffsetX, civictextureOffsetY, civictextureSheet = IconManager:FindIconAtlas(civictextureString,38);
			if civictextureSheet ~= nil then
				Controls.CultureIcon:SetTexture(civictextureOffsetX, civictextureOffsetY, civictextureSheet);
			end
		end
	else
		Controls.CultureIcon:SetTexture(0, 0, "LaunchBar_Hook_CivicsTree");
	end
end

-- ===========================================================================
function OnTurnBegin()
	local localPlayer				= Players[Game.GetLocalPlayer()];
	if (localPlayer == nil) then
		return;
	end

	UpdateTechMeter(localPlayer);
	UpdateCivicMeter(localPlayer);

	RefreshGovernment();
	RefreshGreatWorks();
	RefreshGreatPeople();
	RefreshReligion();
	RefreshView();
end

function OnOpen()
	m_numOpen = m_numOpen+1;
	local screenX, screenY:number = UIManager:GetScreenSizeVal();
	if screenY <= 850 then
		Controls.LaunchContainer:SetOffsetY(-35);
	end
	LuaEvents.LaunchBar_CloseChoosers();
end

function OnClose()
	m_numOpen = m_numOpen-1;
	if(m_numOpen < 0 )then
		m_numOpen = 0;
	end
	if m_numOpen == 0 then
		Controls.LaunchContainer:SetOffsetY(-5);
	end
end

-- ===========================================================================
function OnToggleResearchPanel(hideResearch)
	Controls.ScienceHookWithMeter:SetHide(not hideResearch);
	UpdateTechMeter(Players[Game.GetLocalPlayer()]);
end

function OnToggleCivicPanel(hideResearch)
	Controls.CultureHookWithMeter:SetHide(not hideResearch);
	UpdateCivicMeter(Players[Game.GetLocalPlayer()]);
end

-- Reset the hooks when the player changes for hotseat.
function OnLocalPlayerChanged()	
	m_isGreatPeopleUnlocked	= false;
	m_isGreatWorksUnlocked	= false;
	m_isReligionUnlocked	= false;	
	m_isGovernmentUnlocked	= false;
	RefreshGovernment();
	RefreshGreatPeople();
	RefreshGreatWorks();
	RefreshReligion();
end

-- ===========================================================================
--	Input Hotkey Event (Extended in XP1 to hook extra panels)
-- ===========================================================================
function OnInputActionTriggered( actionId )
	if ( m_isTechTreeAvailable ) then
		if ( actionId == Input.GetActionId("ToggleTechTree") ) then
			OnOpenResearch();
		end
	end

	if ( m_isCivicsTreeAvailable ) then
		if ( actionId == Input.GetActionId("ToggleCivicsTree") ) then
			OnOpenCulture();
		end
	end

	if ( m_isGovernmentAvailable ) then
		if ( actionId == Input.GetActionId("ToggleGovernment") ) then
			OnOpenGovernment();
		end
	end

	if ( m_isReligionAvailable ) then
		if ( actionId == Input.GetActionId("ToggleReligion") ) then
			OnOpenReligion();
		end
	end
	
	if ( m_isGreatPeopleAvailable ) then
		if ( actionId == Input.GetActionId("ToggleGreatPeople") and UI.QueryGlobalParameterInt("DISABLE_GREAT_PEOPLE_HOTKEY") ~= 1 ) then
			OnOpenGreatPeople();
		end
	end

	if ( m_isGreatWorksAvailable ) then
		if ( actionId == Input.GetActionId("ToggleGreatWorks") and UI.QueryGlobalParameterInt("DISABLE_GREAT_WORKS_HOTKEY") ~= 1 ) then
			OnOpenGreatWorks();
		end
	end
end



-- ===========================================================================
function PlayMouseoverSound()
	UI.PlaySound("Main_Menu_Mouse_Over");
end

-- ===========================================================================
function TriggerCustomButtonAddition()
  LuaEvents.LaunchBar_RegisterAdditions();
end

function OnInit(isReload:boolean)
  -- Refresh UI (which buttons are available)
  if isReload then
    TriggerCustomButtonAddition();
  end
end

-- ===========================================================================
function Initialize()
	Controls.CultureButton:RegisterCallback(Mouse.eLClick, OnOpenCulture);
	Controls.CultureButton:RegisterCallback( Mouse.eMouseEnter, PlayMouseoverSound);
	Controls.GovernmentButton:RegisterCallback( Mouse.eLClick, OnOpenGovernment );
	Controls.GovernmentButton:RegisterCallback( Mouse.eMouseEnter, PlayMouseoverSound);
	Controls.GreatPeopleButton:RegisterCallback( Mouse.eLClick, OnOpenGreatPeople );
	Controls.GreatPeopleButton:RegisterCallback( Mouse.eMouseEnter, PlayMouseoverSound);
	Controls.GreatWorksButton:RegisterCallback( Mouse.eLClick, OnOpenGreatWorks );
	Controls.GreatWorksButton:RegisterCallback( Mouse.eMouseEnter, PlayMouseoverSound);
	Controls.ReligionButton:RegisterCallback( Mouse.eLClick, OnOpenReligion );
	Controls.ReligionButton:RegisterCallback( Mouse.eMouseEnter, PlayMouseoverSound);
	Controls.ScienceButton:RegisterCallback(Mouse.eLClick, OnOpenResearch);
	Controls.ScienceButton:RegisterCallback( Mouse.eMouseEnter, PlayMouseoverSound);
	
	Events.TurnBegin.Add( OnTurnBegin );
	Events.VisualStateRestored.Add( OnTurnBegin );
	Events.CivicCompleted.Add( OnCivicCompleted );				-- To capture when we complete Code of Laws
	Events.CivicChanged.Add(OnTurnBegin);
	Events.ResearchChanged.Add(OnTurnBegin);
	Events.TreasuryChanged.Add( RefreshGovernment );
	Events.GovernmentPolicyChanged.Add( RefreshGovernment );
	Events.GovernmentPolicyObsoleted.Add( RefreshGovernment );
	Events.GovernmentChanged.Add( RefreshGovernment );
	Events.AnarchyBegins.Add( RefreshGovernment );
	Events.AnarchyEnds.Add( RefreshGovernment );
	Events.InterfaceModeChanged.Add( OnInterfaceModeChanged );
	Events.GreatWorkCreated.Add( OnGreatWorkCreated );
	Events.FaithChanged.Add( OnFaithChanged );
	Events.LocalPlayerChanged.Add( OnLocalPlayerChanged );
	Events.DiplomacyDealEnacted.Add( OnDiplomacyDealEnacted );
	Events.CityOccupationChanged.Add( OnCityCaptured ); -- kinda bootleg, but effective

	LuaEvents.CivicsTree_CloseCivicsTree.Add(SetCivicsTreeClosed);
	LuaEvents.CivicsTree_OpenCivicsTree.Add( SetCivicsTreeOpen );	
	LuaEvents.Government_CloseGovernment.Add( SetGovernmentClosed );
	LuaEvents.Government_OpenGovernment.Add( SetGovernmentOpen );	
	LuaEvents.GreatPeople_CloseGreatPeople.Add( SetGreatPeopleClosed );
	LuaEvents.GreatPeople_OpenGreatPeople.Add( SetGreatPeopleOpen );
	LuaEvents.GreatWorks_CloseGreatWorks.Add( SetGreatWorksClosed );
	LuaEvents.GreatWorks_OpenGreatWorks.Add( SetGreatWorksOpen );
	LuaEvents.Religion_CloseReligion.Add( SetReligionClosed );
	LuaEvents.Religion_OpenReligion.Add( SetReligionOpen );	
	LuaEvents.TechTree_CloseTechTree.Add(SetTechTreeClosed);
	LuaEvents.TechTree_OpenTechTree.Add( SetTechTreeOpen );
	LuaEvents.Tutorial_CloseAllLaunchBarScreens.Add( OnTutorialCloseAll );

	if HasCapability("CAPABILITY_TECH_TREE") then
		LuaEvents.WorldTracker_ToggleResearchPanel.Add(OnToggleResearchPanel);
	end
	if HasCapability("CAPABILITY_CIVICS_TREE") then
		LuaEvents.WorldTracker_ToggleCivicPanel.Add(OnToggleCivicPanel);
	end

	-- Hotkeys!
	-- Yes, it needs to be wrapped in an anonymous function, because OnInputActionTriggered is overriden elsewhere (like XP1)
	Events.InputActionTriggered.Add( function(actionId) OnInputActionTriggered(actionId) end );

  LuaEvents.LaunchBar_AddButton.Add( OnAddLaunchbarIcon );
  LuaEvents.LaunchBar_EnsureExclusive.Add(CloseAllExcept);

  ContextPtr:SetInitHandler(OnInit);
  Events.LoadScreenClose.Add(TriggerCustomButtonAddition);

	OnTurnBegin();	
end
Initialize();
