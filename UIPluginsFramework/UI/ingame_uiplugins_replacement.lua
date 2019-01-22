-- ============================= --
--	Copyright 2019 FiatAccompli  --
-- ============================= --

-- Doing this with a ReplaceInGame script replacement rather than replacing InGame.lua
-- because I like to play nice and this way it's compatible with anything that 
-- replaces InGame.xml (e.g. CQUI).

-- ===========================================================================
-- Base File
-- ===========================================================================
include("InGame");

function UIPluginsReplacementInitialize() 
	for _, addin in ipairs(Modding.GetUserInterfaces("InGame_Screen")) do
		print("Loading InGame_Screen UI - " .. addin.ContextPath);
		local newContext = ContextPtr:LoadNewContext(addin.ContextPath);
		newContext:ChangeParent(Controls.Screens);
    newContext:SetHide(true);
	end

  for _, addin in ipairs(Modding.GetUserInterfaces("InGame_PartialScreen")) do
		print("Loading InGame_PartialScreen UI - " .. addin.ContextPath);
		local newContext = ContextPtr:LoadNewContext(addin.ContextPath);
		newContext:ChangeParent(Controls.PartialScreens);
    newContext:SetHide(true);
	end

  -- Put the partial screen hooks toolbar back on top of any plugin screens.
  -- And the same for the production panel so it goes on top of the partial 
  -- screen hooks.
  Controls.PartialScreenHooks:Reparent();
  Controls.ProductionPanel:Reparent();
end

UIPluginsReplacementInitialize();