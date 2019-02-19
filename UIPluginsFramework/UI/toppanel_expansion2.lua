-- ===========================================================================
--	HUD Top of Screen Area 
--	XP2 Override
-- ===========================================================================
include( "TopPanel_Expansion1" );


-- ===========================================================================
-- Super functions
-- ===========================================================================
BASE_RefreshYields = RefreshYields;
XP1_LateInitialize = LateInitialize;


-- ===========================================================================
-- Yield handles
-- ===========================================================================
local m_FavorYieldButton:table = nil;


-- ===========================================================================
--	OVERRIDE
-- ===========================================================================
function RefreshResources()
	local localPlayerID = Game.GetLocalPlayer();
	local localPlayer = Players[localPlayerID];
	if (localPlayerID ~= -1) then
		m_kResourceIM:ResetInstances(); 
		local pPlayerResources:table	=  localPlayer:GetResources();
		local yieldStackX:number		= Controls.YieldStack:GetSizeX();
		local infoStackX:number		= Controls.StaticInfoStack:GetSizeX();
		local metaStackX:number		= Controls.RightContents:GetSizeX();
		local screenX, _:number = UIManager:GetScreenSizeVal();
		local maxSize:number = screenX - yieldStackX - infoStackX - metaStackX - META_PADDING;
		if (maxSize < 0) then maxSize = 0; end
		local currSize:number = 0;
		local isOverflow:boolean = false;
		local overflowString:string = "";
		local plusInstance:table;
		for resource in GameInfo.Resources() do
			if (resource.ResourceClassType ~= nil and resource.ResourceClassType ~= "RESOURCECLASS_BONUS" and resource.ResourceClassType ~="RESOURCECLASS_LUXURY" and resource.ResourceClassType ~="RESOURCECLASS_ARTIFACT") then
				local stockpileAmount:number = pPlayerResources:GetResourceAmount(resource.ResourceType);
				local stockpileCap:number = pPlayerResources:GetResourceStockpileCap(resource.ResourceType);
				local reservedAmount:number = pPlayerResources:GetReservedResourceAmount(resource.ResourceType);
				local accumulationPerTurn:number = pPlayerResources:GetResourceAccumulationPerTurn(resource.ResourceType);
				local importPerTurn:number = pPlayerResources:GetResourceImportPerTurn(resource.ResourceType);
				local bonusPerTurn:number = pPlayerResources:GetBonusResourcePerTurn(resource.ResourceType);
				local unitConsumptionPerTurn:number = pPlayerResources:GetUnitResourceDemandPerTurn(resource.ResourceType);
				local powerConsumptionPerTurn:number = pPlayerResources:GetPowerResourceDemandPerTurn(resource.ResourceType);
				local totalConsumptionPerTurn:number = unitConsumptionPerTurn + powerConsumptionPerTurn;
				local totalAmount:number = stockpileAmount + reservedAmount;

				if (totalAmount > stockpileCap) then
					totalAmount = stockpileCap;
				end

				local iconName:string = "[ICON_"..resource.ResourceType.."]";

				local totalAccumulationPerTurn:number = accumulationPerTurn + importPerTurn + bonusPerTurn;

				resourceText = iconName .. " " .. stockpileAmount;

				local numDigits:number = 3;
				if (stockpileAmount >= 10) then
					numDigits = 4;
				end
				local guessinstanceWidth:number = math.ceil(numDigits * FONT_MULTIPLIER);

				local tooltip:string = iconName .. " " .. Locale.Lookup(resource.Name);
				if (reservedAmount ~= 0) then
					--instance.ResourceText:SetColor(0xFF2DFFF8); -- YELLOW
					tooltip = tooltip .. "[NEWLINE]" .. totalAmount .. "/" .. stockpileCap .. " " .. Locale.Lookup("LOC_RESOURCE_ITEM_IN_STOCKPILE");
					tooltip = tooltip .. "[NEWLINE]-" .. reservedAmount .. " " .. Locale.Lookup("LOC_RESOURCE_ITEM_IN_RESERVE");
				else
					--instance.ResourceText:SetColor(0xFFFFFFFF); -- WHITE
					tooltip = tooltip .. "[NEWLINE]" .. totalAmount .. "/" .. stockpileCap .. " " .. Locale.Lookup("LOC_RESOURCE_ITEM_IN_STOCKPILE");
				end
				if (totalAccumulationPerTurn >= 0) then
					tooltip = tooltip .. "[NEWLINE]" .. Locale.Lookup("LOC_RESOURCE_ACCUMULATION_PER_TURN", totalAccumulationPerTurn);
				else
					tooltip = tooltip .. "[NEWLINE][COLOR_RED]" .. Locale.Lookup("LOC_RESOURCE_ACCUMULATION_PER_TURN", totalAccumulationPerTurn) .. "[ENDCOLOR]";
				end
				if (accumulationPerTurn > 0) then
					tooltip = tooltip .. "[NEWLINE] " .. Locale.Lookup("LOC_RESOURCE_ACCUMULATION_PER_TURN_EXTRACTED", accumulationPerTurn);
				end
				if (importPerTurn > 0) then
					tooltip = tooltip .. "[NEWLINE] " .. Locale.Lookup("LOC_RESOURCE_ACCUMULATION_PER_TURN_FROM_CITY_STATES", importPerTurn);
				end
				if (bonusPerTurn > 0) then
					tooltip = tooltip .. "[NEWLINE] " .. Locale.Lookup("LOC_RESOURCE_ACCUMULATION_PER_TURN_FROM_BONUS_SOURCES", bonusPerTurn);
				end
				if (totalConsumptionPerTurn > 0) then
					tooltip = tooltip .. "[NEWLINE]" .. Locale.Lookup("LOC_RESOURCE_CONSUMPTION", totalConsumptionPerTurn);
					if (unitConsumptionPerTurn > 0) then
						tooltip = tooltip .. "[NEWLINE]" .. Locale.Lookup("LOC_RESOURCE_UNIT_CONSUMPTION_PER_TURN", unitConsumptionPerTurn);
					end
					if (powerConsumptionPerTurn > 0) then
						tooltip = tooltip .. "[NEWLINE]" .. Locale.Lookup("LOC_RESOURCE_POWER_CONSUMPTION_PER_TURN", powerConsumptionPerTurn);
					end
				end

				if (stockpileAmount > 0 or totalAccumulationPerTurn > 0 or totalConsumptionPerTurn > 0) then
					if(currSize + guessinstanceWidth < maxSize and not isOverflow) then
						if (stockpileCap > 0) then
							local instance:table = m_kResourceIM:GetInstance();
							if (totalAccumulationPerTurn > totalConsumptionPerTurn) then
								instance.ResourceVelocity:SetHide(false);
								instance.ResourceVelocity:SetTexture("CityCondition_Rising");
							elseif (totalAccumulationPerTurn < totalConsumptionPerTurn) then
								instance.ResourceVelocity:SetHide(false);
								instance.ResourceVelocity:SetTexture("CityCondition_Falling");
							else
								instance.ResourceVelocity:SetHide(true);
							end

							instance.ResourceText:SetText(resourceText);
							instance.ResourceText:SetToolTipString(tooltip);
							instanceWidth = instance.ResourceText:GetSizeX();
							currSize = currSize + instanceWidth;
						end
					else
						if (not isOverflow) then 
							overflowString = tooltip;
							local instance:table = m_kResourceIM:GetInstance();
							instance.ResourceText:SetText("[ICON_Plus]");
							plusInstance = instance.ResourceText;
						else
							overflowString = overflowString .. "[NEWLINE]" .. tooltip;
						end
						isOverflow = true;
					end
				end
			end
		end

		if (plusInstance ~= nil) then
			plusInstance:SetToolTipString(overflowString);
		end
		
		Controls.ResourceStack:CalculateSize();
		
		if(Controls.ResourceStack:GetSizeX() == 0) then
			Controls.Resources:SetHide(true);
		else
			Controls.Resources:SetHide(false);
		end
	end
end


-- ===========================================================================
--	Favor in the top bar should not ship as is.
--	TODO: Remove this implementation
-- ===========================================================================
function RefreshYields()
	BASE_RefreshYields();

	local localPlayerID = Game.GetLocalPlayer();
	if localPlayerID ~= -1 then 
		local localPlayer = Players[localPlayerID];

		--Favor
		m_FavorYieldButton = m_FavorYieldButton or m_YieldButtonDoubleManager:GetInstance();
		local playerFavor	:number = localPlayer:GetFavor();
		local favorPerTurn	:number = localPlayer:GetFavorPerTurn();
		local tooltip		:string = Locale.Lookup("LOC_WORLD_CONGRESS_TOP_PANEL_FAVOR_TOOLTIP");

		local details = localPlayer:GetFavorPerTurnToolTip();
		if(details and #details > 0) then
			tooltip = tooltip .. "[NEWLINE]" .. details;
		end

		m_FavorYieldButton.YieldBalance:SetText(Locale.ToNumber(playerFavor, "#,###.#"));
		m_FavorYieldButton.YieldBalance:SetColorByName("ResFavorLabelCS");
		m_FavorYieldButton.YieldPerTurn:SetText(FormatValuePerTurn(favorPerTurn));	
		m_FavorYieldButton.YieldPerTurn:SetColorByName("ResFavorLabelCS");
		m_FavorYieldButton.YieldBacking:SetToolTipString(tooltip);
		m_FavorYieldButton.YieldBacking:SetColorByName("ResFavorLabelCS");
		m_FavorYieldButton.YieldIconString:SetText("[ICON_FAVOR_LARGE]");
		m_FavorYieldButton.YieldButtonStack:CalculateSize();
	end	
end


-- ===========================================================================
function LateInitialize()
	XP1_LateInitialize();
	Events.FavorChanged.Add( OnRefreshYields );
	if not XP2_LateInitialize then
		RefreshYields();
	end
end