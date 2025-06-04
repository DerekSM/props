--[[
				  _________.__    .__                                  
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     / 
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/  
						\/      \/        \/\/         \/              

		Everything HUD related
]]--

local _R = debug.getregistry()
local surface = surface
local draw = draw

	-- CREDITS: blackawps
local matBlurScreen = Material( "pp/blurscreen" )

function _R.Panel:DrawBackgroundBlur( blurAmnt )
	--[[blurAmnt = blurAmnt or 5
	surface.SetMaterial( matBlurScreen )    
	surface.SetDrawColor( 255, 255, 255, 255 )
	
	local x, y = self:LocalToScreen( 0, 0 )
		
	for i=0.33, 1, 0.33 do
		matBlurScreen:SetFloat( "$blur", blurAmnt * i )
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect( x * -1, y * -1, ScrW(), ScrH() )
	end]]
	
	
	
	-- do nothing cause FPS LOSS
end

-- i think i refigured out how to make universal huds even with siht like ScrH() - 35

-- for an example like ScrH() - 35,
-- lua_run_cl print( ScrH() / (ScrH() + 35) )
-- then the output is what you use,
--	ScrH() * 0.962


surface.CreateFont( "props_HUDTextULTRATiny",
	{
	font = "TargetID",
	size = 12, --ScreenScale( 5.6 ),
	weight = 550,
	}
)
surface.CreateFont( "props_HUDTextVeryTiny",
	{
	font = "TargetID",
	size = 14, --ScreenScale( 6.2 ),
	weight = 600,
	}
)	
surface.CreateFont("props_HUDTextTiny",
				{
				font = "TargetID",
				size = 16,--ScreenScale( 7.1 ), --16,
				weight = 600,
				})
surface.CreateFont("props_HUDTextSmall",
				{
				font = "TargetID",
				size = 20, --ScreenScale( 8.9 ), --20,
				--size = 20,
				weight = 600,
				})
surface.CreateFont("props_HUDTextMedium",
				{
				font = "TargetID",
				--size = 30,
				size = 30,--ScreenScale( 13.3 ),
				weight = 700,
				})
surface.CreateFont( "props_HUDTextLarge",
	{
	font = "TargetID",
	size = 36, --ScreenScale( 16 ),--36,
	weight = 700,
	}
)
surface.CreateFont("props_HUDTextHuge",
				{
				font = "TargetID",
				size = 46,--ScreenScale( 20.45 ), --46,
				weight = 700,
				})
surface.CreateFont( "props_HUDTextMASSIVE",
				{
				font = "TargetID",
				size = 128,
				weight = 900,
				}
				)
AddClientConfigItem( "props_BaseHUDX",
	{
	Name = "Main HUD X Positioning",
	--Category = "Player Management",
	default = 15,
	min = 0,
	max = ScrW(),
	type = "integer",
	desc = "Drag the slider to move the main HUD horizontally across the screen",
	decimals = 0,
	listening = true, -- If true, will change while sliding the number bar
	}
)
AddClientConfigItem( "props_BaseHUDY",
	{
	Name = "Main HUD Y Positioning",
	--Category = "Player Management",
	default = math.ceil( ScrH() * GetUniversalSize( 110, 900 ) ),
	min = 0,
	max = ScrH(),
	type = "integer",
	desc = "Drag the slider to move the main HUD vertically across the screen",
	decimals = 0,
	listening = true, -- If true, will change while sliding the number bar
	}
)
AddClientConfigItem( "props_HUDShowPropOwnerPopup",
	{
	Name = "Main HUD Show Prop Owner",
	default = true,
	type = "boolean",
	desc = "Show the Prop Owner HUD when looking at a prop",
	}
)
AddClientConfigItem( "props_BattleHUDCondensed",
	{
	Name = "Condense Battle HUD",
	default = false,
	type = "boolean",
	desc = "Make the battle HUD smaller (takes effect next fight)",
	}
)


hook.Add( "HUDShouldDraw", "props_OverrideDefaultHUD", function( name )
	if name == "CHudHealth" then return false end
end )

local function CreateHUD( b_noMotd )
	if not _G.LocalPlayer or not IsValid( LocalPlayer() ) then
		timer.Simple( 0.5, function() CreateHUD() end )
		return
	end
	
	if IsValid( VGUI_BASECONTENT ) then
		VGUI_BASECONTENT:Remove()
		VGUI_BASECONTENT = nil
	end
	
	if IsValid( VGUI_introBackground ) then
		VGUI_introBackground:Remove()
		VGUI_introBackground = nil
	end
	
		-- saved for now.
	--if not b_noMotd and ULib and ULib.ucl.query( LocalPlayer(), "ulx who" ) and GetConVarString( "ulx_showMotd" ) == "1" then
	if not b_noMotd then
		if PROPKILL.Config[ "ulx_showmotd" ] and PROPKILL.Config[ "ulx_showmotd" ].default then
			RunConsoleCommand( "ulx", "motd" )
		else
			if not props_HasOpenedMenuBefore then
				RunConsoleCommand( "props_menu" )
			end
		end 
	end
	
	local propsPlayer = IsValid(LocalPlayer():GetObserverTarget()) and LocalPlayer():GetObserverTarget() or LocalPlayer() --LocalPlayer():GetViewEntity()
	
	VGUI_BASECONTENT = vgui.Create( "DPanel" )
	--VGUI_BASECONTENT:SetPos( 15, math.ceil( ScrH() * GetUniversalSize( 110, 900 ) ))
	VGUI_BASECONTENT:SetPos( PROPKILL.ClientConfig["props_BaseHUDX"].currentvalue, PROPKILL.ClientConfig["props_BaseHUDY"].currentvalue )
	--VGUI_BASECONTENT:SetSize( 350, 95 )
		-- 350 / 1440 = 0.243
	VGUI_BASECONTENT:SetSize( ScrW() * 0.243, ScrH() * 0.1055 )
	VGUI_BASECONTENT:ParentToHUD()
	VGUI_BASECONTENT.Paint = function( self, w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, Color( 31, 31, 31, 235  ) )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 27, 26, 26, 235 ) )
		self:DrawBackgroundBlur( 4 )
	end
	VGUI_BASECONTENT.OldSetPos = VGUI_BASECONTENT.SetPos
	VGUI_BASECONTENT.SetPos = function( pnl, x, y )
		VGUI_BASECONTENT.OldSetPos( pnl, x, y )

		hook.Run("props_BaseContentPositionChanged", pnl, x, y )
	end
	hook.Add("Props_ClientConfigChanged", "ChangeBaseContentPositioning", function( id, value )
		VGUI_BASECONTENT:SetPos( PROPKILL.ClientConfig["props_BaseHUDX"].currentvalue, PROPKILL.ClientConfig["props_BaseHUDY"].currentvalue )
	end )
	--[[hook.Add("OnScreenSizeChanged", "ChangeBaseContentPositioning", function( oldw, oldh, neww,newh )
		if not PROPKILL.ClientConfig then return end

			-- If we changed resolution then temporarily set our positioning to default.
			-- Should we make it permanent?
		if neww < PROPKILL.ClientConfig["props_BaseHUDX"].currentvalue or newh < PROPKILL.ClientConfig["props_BaseHUDY"].currentvalue then
			print("yes")
			timer.Simple(0.1,function()
				VGUI_BASECONTENT:SetPos( PROPKILL.ClientConfig["props_BaseHUDX"].default, PROPKILL.ClientConfig["props_BaseHUDY"].default )
			end)
		else
			print("no")
		end
	end )]]
	--[[VGUI_BASECONTENT.Think = function( pnl )
		print("Change base content position")
		pnl:SetPos( PROPKILL.ClientConfig["props_BaseHUDX"].currentvalue, PROPKILL.ClientConfig["props_BaseHUDY"].currentvalue )
	end]]
	
	local basesizew, basesizeh = VGUI_BASECONTENT:GetSize()
	
	surface.SetFont( "props_HUDTextSmall" )
	local leader = props_GetLeader()
	local LeaderText = ""
	if IsValid( leader ) then
		LeaderText = "Leader: " .. leader:Nick() .. " ( " .. leader:GetKillstreak() .. " )"
	else
		LeaderText = "No Leader"
	end
	local textsizew, textsizeh = surface.GetTextSize( LeaderText )
	VGUI_LEADER = vgui.Create( "DLabel" )
	VGUI_LEADER:SetParent( VGUI_BASECONTENT )
	VGUI_LEADER:SetSize( basesizew, textsizeh )
	VGUI_LEADER:SetText( LeaderText )
	VGUI_LEADER:SetPos( VGUI_LEADER:GetWide()/2 - textsizew/2, 3 )
	VGUI_LEADER:SetFont( "props_HUDTextSmall" )
	VGUI_LEADER:SetTextColor( Color( 230, 230, 230, 255 ) )
	hook.Add( "OnNewLeaderFound", "ChangeLeaderText", function( leader )
		local textsizew, textsizeh = nil, nil
		local sizew, sizeh = VGUI_LEADER:GetSize()

		if IsValid( leader ) and leader:GetKillstreak() > 0 then
			local LeaderString = table.FastConcat(" ", "Leader:", FixLongName( leader:Nick(), 17 ), "(", leader:GetKillstreak(), ")" )
			textsizew, textsizeh = surface.GetTextSize( LeaderString )
			VGUI_LEADER:SetText( LeaderString )
		else
			textsizew, textsizeh = surface.GetTextSize( "No Leader" )
			VGUI_LEADER:SetText( "No Leader" )
		end
		VGUI_LEADER:SetPos( sizew/2 - textsizew/2, 3 )
	end )
	
	local previoussizew, previoussizeh = VGUI_LEADER:GetSize()
	local previousposx, previousposy = VGUI_LEADER:GetPos()
	
		-- i should automate these.

	VGUI_KILLSTREAK = vgui.Create( "props_horizontalbar" )
	VGUI_KILLSTREAK:SetParent( VGUI_BASECONTENT )
	VGUI_KILLSTREAK:SetPos( 5, 5 + previousposy + previoussizeh )
		-- ( (panel height - the previous dlabels + gap) - the gap amount times the amount of boxes) / amount of boxes
	VGUI_KILLSTREAK:SetSize( basesizew - 10, (basesizeh - (previousposy + previoussizeh + 5) - 15) / 2 )
	VGUI_KILLSTREAK:SetBackColor( Color( 25, 25, 25, 255 ) )
	VGUI_KILLSTREAK:SetFillColor( Color( 206, 61, 38, 255 ) )
	if propsPlayer.GetKillstreak then
		VGUI_KILLSTREAK:SetBarValue( propsPlayer:GetKillstreak() / propsPlayer:GetBestKillstreak() )
	else
		VGUI_KILLSTREAK:SetBarValue( 1 )
	end
	VGUI_KILLSTREAK.PaintOver = function( self, w, h )
		propsPlayer = IsValid(LocalPlayer():GetObserverTarget()) and LocalPlayer():GetObserverTarget() or LocalPlayer()
		if not propsPlayer.GetKillstreak then print("hmm") return end
		surface.SetFont( "props_HUDTextSmall" )

		local KillstreakString = table.FastConcat( " ", "Killstreak:", propsPlayer:GetKillstreak(), "/", propsPlayer:GetBestKillstreak() )
		local size_w, size_h = surface.GetTextSize( KillstreakString )

		draw.SimpleText( KillstreakString, "props_HUDTextSmall", w / 10, h/2 - size_h/2, Color( 230, 230, 230, 255 ) )
		self:SetBarValue( propsPlayer:GetKillstreak() / propsPlayer:GetBestKillstreak() )
	end
	
	local firstbarsizew, firstbarsizeh = VGUI_KILLSTREAK:GetSize()
	
	previoussizew, previoussizeh = VGUI_KILLSTREAK:GetSize()
	previousposx, previousposy = VGUI_KILLSTREAK:GetPos()
	
	VGUI_KD = vgui.Create( "props_horizontalbar" )
	VGUI_KD:SetParent( VGUI_BASECONTENT )
	VGUI_KD:SetPos( 5, previoussizeh + previousposy + 5 )
	VGUI_KD:SetSize( basesizew - 10, firstbarsizeh )
	VGUI_KD:SetBackColor( Color( 25, 25, 25, 255 ) )
	VGUI_KD:SetFillColor( Color( 59, 59, 167, 255 ) )
	if propsPlayer.GetKD then
		VGUI_KD:SetBarValue( propsPlayer:GetKD() )
	else
		VGUI_KD:SetBarValue( 1 )
	end
	VGUI_KD.PaintOver = function( self, w, h )
		propsPlayer = IsValid(LocalPlayer():GetObserverTarget()) and LocalPlayer():GetObserverTarget() or LocalPlayer()
		if not propsPlayer.GetKD then return end
		surface.SetFont( "props_HUDTextSmall" )

		local KDRatioString = table.FastConcat( " ", "KD Ratio:", propsPlayer:GetKD() )
		local size_w, size_h = surface.GetTextSize( KDRatioString )

		draw.SimpleText( KDRatioString, "props_HUDTextSmall", w / 10, h/2 - size_h/2, Color( 230, 230, 230, 255 ) )
		self:SetBarValue( propsPlayer:GetKD() )
	end
	
	
	if IsValid( VGUI_PROPPANEL ) then
		VGUI_PROPPANEL:Remove()
		VGUI_PROPPANEL = nil
	end
	
	VGUI_PROPPANEL = vgui.Create( "DPanel" )
	VGUI_PROPPANEL:SetWide( VGUI_BASECONTENT:GetWide() - 80 )
	VGUI_PROPPANEL:SetTall( 25 )
	local basecontentpos_x, basecontentpos_y = VGUI_BASECONTENT:GetPos()
	VGUI_PROPPANEL:SetPos( basecontentpos_x + 40, basecontentpos_y - VGUI_PROPPANEL:GetTall() + 1 )
	VGUI_PROPPANEL:SetKeyboardInputEnabled( true )
	VGUI_PROPPANEL:ParentToHUD()
	VGUI_PROPPANEL.Paint = function( self, w, h )
		if not PROPKILL.ClientConfig["props_HUDShowPropOwnerPopup"].currentvalue then return end
		if not propsPlayer.LookingAtProp or not IsValid( propsPlayer.LookingAtProp ) then
			return
		end
		draw.RoundedBox( 0, 0, 0, w, h, Color( 47, 46, 46, 235 ) )
	end
	hook.Add("props_BaseContentPositionChanged", "ChangePropPanelPositioning", function( basepnl, x, y )
		VGUI_PROPPANEL:SetPos( x + 40, y - VGUI_PROPPANEL:GetTall() + 1 )
	end )
	
	VGUI_PROPOWNER = vgui.Create( "DLabel" )
	VGUI_PROPOWNER:SetParent( VGUI_PROPPANEL )
	VGUI_PROPOWNER:SetText( "Owner: Shinycow" )
	VGUI_PROPOWNER:SetTextColor( Color( 230, 230, 230, 255 ) )
	VGUI_PROPOWNER:SetFont( "props_HUDTextSmall" )
	surface.SetFont( "props_HUDTextSmall" )
	local ownersize_w, ownersize_h = surface.GetTextSize( "Owner: Shinycow" )
	local PropPanelSizeW, PropPanelSizeH = VGUI_PROPPANEL:GetSize()
	VGUI_PROPOWNER:SetPos( PropPanelSizeW / 2 - ownersize_w / 2, PropPanelSizeH / 2 - ownersize_h / 2 )
	VGUI_PROPOWNER:SetSize( ownersize_w, ownersize_h )
	VGUI_PROPOWNER.Think = function( self )
		if not PROPKILL.ClientConfig["props_HUDShowPropOwnerPopup"].currentvalue then return end
			-- We update LookingAtProp with a trace every 0.2 seconds in sh_init.lua
		if not propsPlayer.LookingAtProp or not IsValid( propsPlayer.LookingAtProp ) then
			if self:GetText() != "" then
				self:SetText( "" )
			end
			return
		end

		surface.SetFont( "props_HUDTextSmall" )
		
		local owner_text = "Owner:"

		local owner = propsPlayer.LookingAtProp:GetNW2Entity( "Owner", NULL )
		if owner and IsValid(owner) then
			owner_text = FixLongName( "Owner: " .. owner:Nick(), 22 )
		end
		
		local ownersize_w, ownersize_h = surface.GetTextSize( owner_text )

		if self:GetText() != owner_text then
			self:SetText( owner_text )
			self:SetPos( PropPanelSizeW / 2 - ownersize_w / 2, PropPanelSizeH / 2 - ownersize_h / 2 )
			self:SetSize( ownersize_w, ownersize_h )
		end
	end
	hook.Add("Props_ClientConfigChanged", "ShowOrHidePropOwnerHUD", function( id, value )
		if id != "props_HUDShowPropOwnerPopup" then return end

		VGUI_PROPPANEL:SetVisible( tobool(value) )
		VGUI_PROPOWNER:SetVisible( tobool(value) )
	end )

end

local fullyLoaded = false
local function CreateIntroHUD()
	local timeToFade = 2
	local alphaCalc = 245
	local startFading = false
	local startFadeTime = 3.5
	
	local timetaken = 0
	local timetaken2 = 0
	timer.Create( "propsIntroHUDFade", startFadeTime, 1, function()
		startFading = true
		timetaken = SysTime()
	end )
	
	if IsValid( VGUI_BASECONTENT ) then
		VGUI_BASECONTENT:Remove()
		VGUI_BASECONTENT = nil
	end
	
	if IsValid( VGUI_introBackground ) then
		VGUI_introBackground:Remove()
		VGUI_introBackground = nil
	end

	VGUI_introBackground = vgui.Create( "DPanel" )
	VGUI_introBackground:SetPos( 0, 0 )
	VGUI_introBackground:SetSize( ScrW(), ScrH() )
	VGUI_introBackground:SetKeyboardInputEnabled( true )
	VGUI_introBackground:ParentToHUD()
	VGUI_introBackground.Paint = function( self, w, h )
		if startFading then 
			alphaCalc = math.Approach( alphaCalc, 0, (245 / timeToFade) * FrameTime())
		end
		
		draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, alphaCalc ) )
	end
	
	surface.SetFont( "props_HUDTextHuge" )
	local gmName_w, gmName_h = surface.GetTextSize( ( GM and GM.Name ) or GAMEMODE.Name )
	surface.SetFont( "props_HUDTextMedium" )
	local authorName_w, authorName_h = surface.GetTextSize( "Created by Shinycow" )

	VGUI_introGM = vgui.Create( "DLabel" )
	VGUI_introGM:SetParent( VGUI_introBackground )
	VGUI_introGM:SetPos( VGUI_introBackground:GetWide() / 2 - gmName_w / 2, ( VGUI_introBackground:GetTall() / 2 - (gmName_h - authorName_h) / 2 ) - (authorName_h + 20) )
	VGUI_introGM:SetFont( "props_HUDTextHuge" )
	VGUI_introGM:SetText( ( GM and GM.Name ) or GAMEMODE.Name )
	VGUI_introGM:SetTextColor( Color( 230, 230, 230, 255 ) )
	VGUI_introGM:SizeToContents()
	
	VGUI_introAuthor = vgui.Create( "DLabel" )
	VGUI_introAuthor:SetParent( VGUI_introBackground )
	VGUI_introAuthor:SetPos( VGUI_introBackground:GetWide() / 2 - authorName_w / 2, ( VGUI_introBackground:GetTall() / 2 - (gmName_h - authorName_h) / 2 ) + 10 )
	VGUI_introAuthor:SetFont( "props_HUDTextMedium" )
	VGUI_introAuthor:SetText( "Created by Shinycow" )
	VGUI_introAuthor:SetTextColor( Color( 230, 230, 230, 255 ) )
	VGUI_introAuthor:SizeToContents()
	
	local function CreatePropkillHUD()
		if alphaCalc == 0 and IsValid( VGUI_introBackground ) then
			CreateHUD()
			timer.Destroy( "CreatePropkillHUD" )
		end
	end
	timer.Create( "CreatePropkillHUD", 1, 0, function()
		CreatePropkillHUD()
	end )
end

function props_ShowBattlingHUD()
	local CondensedBattleHUD = PROPKILL.ClientConfig["props_BattleHUDCondensed"].currentvalue

	local BattleBackgroundWide = math.ceil( ScrW() * GetUniversalSize( 680, 1440 ) )
	VGUI_BattleBack = vgui.Create( "DPanel" )
	if not CondensedBattleHUD then
		VGUI_BattleBack:SetSize( BattleBackgroundWide, 60 )
	else
		VGUI_BattleBack:SetSize( BattleBackgroundWide, 34 )
	end
	VGUI_BattleBack:SetPos( ScrW() / 2 - VGUI_BattleBack:GetWide() / 2, 0 )
	VGUI_BattleBack:SetKeyboardInputEnabled( true )
	VGUI_BattleBack:ParentToHUD()
	VGUI_BattleBack.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 27, 26, 26, 235 ) )
	end

	local BattleVGUI = {}

		--
		-- Initialize the 3 subpanels we need
		--
	BattleVGUI["VGUI_InviterPanel"] = vgui.Create( "DPanel" )
	BattleVGUI["VGUI_InviterPanel"]:SetParent( VGUI_BattleBack )
	BattleVGUI["VGUI_InviterPanel"]:SetSize( (VGUI_BattleBack:GetWide() / 3) - 15, VGUI_BattleBack:GetTall() )
	BattleVGUI["VGUI_InviterPanel"]:Dock( LEFT )
	BattleVGUI["VGUI_InviterPanel"].Paint = function() end

	BattleVGUI["VGUI_InviteePanel"] = vgui.Create( "DPanel" )
	BattleVGUI["VGUI_InviteePanel"]:SetParent( VGUI_BattleBack )
	BattleVGUI["VGUI_InviteePanel"]:SetSize( (VGUI_BattleBack:GetWide() / 3) - 15, VGUI_BattleBack:GetTall() )
	BattleVGUI["VGUI_InviteePanel"]:Dock( RIGHT )
	BattleVGUI["VGUI_InviteePanel"].Paint = function() end

	BattleVGUI["VGUI_CountdownPanel"] = vgui.Create( "DPanel" )
	BattleVGUI["VGUI_CountdownPanel"]:SetParent( VGUI_BattleBack )
	BattleVGUI["VGUI_CountdownPanel"]:Dock( FILL )

		--
		-- Helper function to populate fighter information
		--
	local function createBattleLabels( battler_type )
			-- Reference information for later
		local MaxNameLength = 22
		local CondensedScoreOffset = 60
		local BattlePlayerName = PROPKILL.Battlers[ string.lower( battler_type ) ] and PROPKILL.Battlers[ string.lower( battler_type ) ]:Nick() or "N/A"
		BattlePlayerName = FixLongName( BattlePlayerName, MaxNameLength )
		local PreZero = "00"
		if PROPKILL.Battlers[ string.lower( battler_type ) ] then
			PreZero = PROPKILL.Battlers[ string.lower( battler_type ) ]:GetKillstreak() < 10
				and "0" .. PROPKILL.Battlers[ string.lower( battler_type ) ]:GetKillstreak()
				or PROPKILL.Battlers[ string.lower( battler_type ) ]:GetKillstreak()
		end
		local ScoreSizew, ScoreSizeh = surface.GetTextSize( PreZero )

			-- Battler Name information
		local VGUINameElement = BattleVGUI[ "VGUI_" .. battler_type .. "Name" ]

		surface.SetFont( "props_HUDTextSmall" )
		local ElementSizew, ElementSizeh = surface.GetTextSize( BattlePlayerName )
		VGUINameElement = vgui.Create( "DLabel" )
		VGUINameElement:SetFont( "props_HUDTextSmall" )
		VGUINameElement:SetParent( BattleVGUI[ "VGUI_" .. battler_type .. "Panel" ] )
		VGUINameElement:SetTextColor( color_white )
		VGUINameElement:SetText( BattlePlayerName )
		VGUINameElement:SetSize( ElementSizew, ElementSizeh  )
		VGUINameElement:SetPos( BattleVGUI[ "VGUI_" .. battler_type .. "Panel" ]:GetWide() / 2 - ElementSizew / 2, 5 )
		VGUINameElement.Think = function( pnl )
			if not CondensedBattleHUD then
				pnl:SetPos( BattleVGUI[ "VGUI_" .. battler_type .. "Panel" ]:GetWide() / 2 - ElementSizew / 2, 5 )
			else
				if PROPKILL.Battlers[ string.lower( battler_type ) ] then
					PreZero = PROPKILL.Battlers[ string.lower( battler_type ) ]:GetKillstreak() < 10
						and "0" .. PROPKILL.Battlers[ string.lower( battler_type ) ]:GetKillstreak()
						or PROPKILL.Battlers[ string.lower( battler_type ) ]:GetKillstreak()
				end
				surface.SetFont( "props_HUDTextSmall" )
				ScoreSizew, Scorewsizeh = surface.GetTextSize( PreZero )

				pnl:SetPos( BattleVGUI[ "VGUI_" .. battler_type .. "Panel" ]:GetWide() / 2 - (ElementSizew / 2 + (ScoreSizew + CondensedScoreOffset) / 2 ) , 5 )
			end
		end

			-- Score information
		local VGUIScoreElement = BattleVGUI[ "VGUI_" .. battler_type .. "Score" ]

		surface.SetFont( "props_HUDTextHuge" )
		ScoreSizew, Scorewsizeh = surface.GetTextSize( PreZero )
		VGUIScoreElement = vgui.Create( "DLabel" )
		VGUIScoreElement:SetParent( BattleVGUI[ "VGUI_" .. battler_type .. "Panel" ] )
		VGUIScoreElement:SetTextColor( color_white )
		VGUIScoreElement:SetFont( "props_HUDTextHuge" )
		VGUIScoreElement:SetSize( ScoreSizew, Scorewsizeh )
		if not CondensedBattleHUD then
			VGUIScoreElement:SetPos(
				BattleVGUI[ "VGUI_" .. battler_type .. "Panel" ]:GetWide() / 2 - ScoreSizew / 2,
				BattleVGUI[ "VGUI_" .. battler_type .. "Panel" ]:GetTall() - (Scorewsizeh + 1) + 3
			)
		else
			local NameElementX, NameElementY = VGUINameElement:GetPos()
			VGUIScoreElement:SetPos(
				NameElementX,
				NameElementY
			)
		end
		VGUIScoreElement.Think = function( pnl )
			if not PreZero then return end

			if PROPKILL.Battlers[ string.lower( battler_type ) ] then
				PreZero = PROPKILL.Battlers[ string.lower( battler_type ) ]:GetKillstreak() < 10
					and "0" .. PROPKILL.Battlers[ string.lower( battler_type ) ]:GetKillstreak()
					or PROPKILL.Battlers[ string.lower( battler_type ) ]:GetKillstreak()
			end
			pnl:SetText( PreZero )
			if not CondensedBattleHUD then
				surface.SetFont( "props_HUDTextHuge" )
				ScoreSizew, Scorewsizeh = surface.GetTextSize( PreZero )
				pnl:SetSize( ScoreSizew, Scorewsizeh )
				pnl:SetPos(
					BattleVGUI[ "VGUI_" .. battler_type .. "Panel" ]:GetWide() / 2 - ScoreSizew / 2,
					BattleVGUI[ "VGUI_" .. battler_type .. "Panel" ]:GetTall() - (Scorewsizeh + 1) + 3
				)
			else
				surface.SetFont( "props_HUDTextSmall" )
				ScoreSizew, Scorewsizeh = surface.GetTextSize( PreZero )
				pnl:SetSize( ScoreSizew, Scorewsizeh )
				pnl:SetFont("props_HUDTextSmall")
				local NameElementX, NameElementY = VGUINameElement:GetPos()

				pnl:SetPos(
					NameElementX + VGUINameElement:GetWide() + CondensedScoreOffset,
					NameElementY
				)
			end
		end
	end

	createBattleLabels( "Inviter" )
	createBattleLabels( "Invitee" )


	surface.SetFont( "props_HUDTextLarge" )
	if not CondensedBattleHUD then
		VGUI_CountdownText = vgui.Create( "DLabel" )
		VGUI_CountdownText.Sizew, VGUI_CountdownText.Sizeh = surface.GetTextSize( "Time Remaining" )
		VGUI_CountdownText:SetFont( "props_HUDTextLarge" )
		VGUI_CountdownText:SetParent( BattleVGUI["VGUI_CountdownPanel"] )
		VGUI_CountdownText:SetTextColor( Color( 90, 90, 90, 255 ) )
		VGUI_CountdownText:SetText( "Time Remaining" )
		VGUI_CountdownText:SetSize( VGUI_CountdownText.Sizew, VGUI_CountdownText.Sizeh )
		VGUI_CountdownText:SetPos( BattleVGUI["VGUI_CountdownPanel"]:GetWide() / 2 - VGUI_CountdownText.Sizew / 2 + 5, -2 )
		VGUI_CountdownText.PerformLayout = function( pnl )
			VGUI_CountdownText:SetPos( BattleVGUI["VGUI_CountdownPanel"]:GetWide() / 2 - VGUI_CountdownText.Sizew / 2 + 5, -2 )
		end
	end


	VGUI_CountdownTimer = vgui.Create( "DLabel" )
	VGUI_CountdownTimer.Sizew, VGUI_CountdownTimer.Sizeh = surface.GetTextSize( string.ToMinutesSeconds( PROPKILL.BattleTime ) )
	VGUI_CountdownTimer:SetFont( "props_HUDTextLarge" )
	VGUI_CountdownTimer:SetParent( BattleVGUI["VGUI_CountdownPanel"] )
	VGUI_CountdownTimer:SetTextColor( Color( 90, 90, 90, 255 ) )
	VGUI_CountdownTimer:SetText( string.ToMinutesSeconds( PROPKILL.Config[ "battle_time" ].default * 60 ) )
	VGUI_CountdownTimer:SetSize( VGUI_CountdownTimer.Sizew, VGUI_CountdownTimer.Sizeh )
	VGUI_CountdownTimer:SetPos( BattleVGUI["VGUI_CountdownPanel"]:GetWide() / 2- VGUI_CountdownTimer.Sizew / 2 + 5, BattleVGUI["VGUI_CountdownPanel"]:GetTall() - VGUI_CountdownTimer.Sizeh )
	VGUI_CountdownTimer.Think = function( pnl )
		surface.SetFont( "props_HUDTextLarge" )
		pnl.Sizew, pnl.Sizeh = surface.GetTextSize( string.ToMinutesSeconds( PROPKILL.BattleTime ) )
		pnl:SetText( string.ToMinutesSeconds( PROPKILL.BattleTime ) )
			-- Add random 4 pixel gibberish to help prevent text being cut off
		pnl:SetSize( pnl.Sizew + 4, pnl.Sizeh )
		if not CondensedBattleHUD then
			local CountdownTextPosX, CountdownTextPosY = VGUI_CountdownText:GetPos()
			pnl:SetPos(
				BattleVGUI["VGUI_CountdownPanel"]:GetWide() / 2 - (pnl.Sizew-4) / 2 + 5,
				BattleVGUI["VGUI_CountdownPanel"]:GetTall() - VGUI_CountdownTimer.Sizeh
			)
		else
			pnl:SetPos(
				BattleVGUI["VGUI_CountdownPanel"]:GetWide() / 2 - (pnl.Sizew-4) / 2 + 5,
				BattleVGUI["VGUI_CountdownPanel"]:GetTall() / 2 - pnl.Sizeh / 2
			)
		end
	end

end

function props_HideBattlingHUD()
	if not IsValid( VGUI_BattleBack ) then return end
	VGUI_BattleBack:Remove()
	VGUI_BattleBack = nil
end

hook.Add( "OnReloaded", "props_RedrawHUD", function()
	CreateHUD( true )
end )

hook.Add( "Initialize", "props_DrawHUD", function()
	timer.Simple( 1, function()
		CreateIntroHUD()
	end )
end )
