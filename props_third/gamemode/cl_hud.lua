local _R = debug.getregistry()

	-- CREDITS: blackawps
local matBlurScreen = Material( "pp/blurscreen" )

function _R.Panel:DrawBackgroundBlur( blurAmnt )
	blurAmnt = blurAmnt or 5
	surface.SetMaterial( matBlurScreen )    
	surface.SetDrawColor( 255, 255, 255, 255 )
	
	local x, y = self:LocalToScreen( 0, 0 )
		
	for i=0.33, 1, 0.33 do
		matBlurScreen:SetFloat( "$blur", blurAmnt * i )
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect( x * -1, y * -1, ScrW(), ScrH() )
	end
end

surface.CreateFont("props_HUDTextTiny",
				{
				font = "TargetID",
				size = 16,
				weight = 600,
				})
surface.CreateFont("props_HUDTextSmall",
				{
				font = "TargetID",
				size = 20,
				weight = 600,
				})
surface.CreateFont("props_HUDTextMedium",
				{
				font = "TargetID",
				size = 30,
				weight = 700,
				})
surface.CreateFont( "props_HUDTextLarge",
	{
	font = "TargetID",
	size = 36,
	weight = 700,
	}
)
surface.CreateFont("props_HUDTextHuge",
				{
				font = "TargetID",
				size = 46,
				weight = 700,
				})

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
	if not b_noMotd and ULib and GetConVarString( "ulx_showMotd" ) == "1" then
		RunConsoleCommand( "ulx", "motd" )
	end
	
	local propsPlayer = LocalPlayer():GetObserverTarget() or LocalPlayer() --LocalPlayer():GetViewEntity()
	
	VGUI_BASECONTENT = vgui.Create( "DPanel" )
		-- for if there's 3 bars
	-------------VGUI_BASECONTENT:SetPos( 15, ScrH() - 135 )
	-------------VGUI_BASECONTENT:SetSize( 350, 120 )
	VGUI_BASECONTENT:SetPos( 15, ScrH() - 110 ) 
	VGUI_BASECONTENT:SetSize( 350, 95 )
	VGUI_BASECONTENT:SetKeyboardInputEnabled( true )
	VGUI_BASECONTENT:ParentToHUD()
	VGUI_BASECONTENT.Paint = function( self, w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, Color( 31, 31, 31, 235  ) )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 27, 26, 26, 235 ) )
		self:DrawBackgroundBlur( 4 )
	end
	
	local basesizew, basesizeh = VGUI_BASECONTENT:GetSize()
	
	surface.SetFont( "props_HUDTextSmall" )
	local textsizew, textsizeh = surface.GetTextSize( "Leader: Shinycow ( 6 )" )
	VGUI_LEADER = vgui.Create( "DLabel" )
	VGUI_LEADER:SetParent( VGUI_BASECONTENT )
	VGUI_LEADER:SetPos( 40, 3 )
	VGUI_LEADER:SetSize( basesizew, textsizeh )
	local leader = props_GetLeader()
	if IsValid( leader ) then
		VGUI_LEADER:SetText( "Leader: " .. leader:Nick() .. " ( " .. leader:GetKillstreak() .. " )" )
	else
		VGUI_LEADER:SetText( "Leader: ( 0 ) " )
	end
	VGUI_LEADER:SetFont( "props_HUDTextSmall" )
	--VGUI_LEADER:SetTextColor( Color( 200, 200, 200, 255 ) )
	--VGUI_LEADER:SetTextColor( Color( 127, 125, 125, 255 ) )
	VGUI_LEADER:SetTextColor( Color( 230, 230, 230, 255 ) )
	VGUI_LEADER.Think = function( self )
		local sizew, sizeh = self:GetSize()
		
		local leader = props_GetLeader()
		if IsValid( leader ) then
			VGUI_LEADER:SetText( "Leader: " .. leader:Nick() .. " ( " .. leader:GetKillstreak() .. " )" )
		else
			VGUI_LEADER:SetText( "Leader: ( 0 ) " )
		end
		self:SetPos( sizew/2 - textsizew/2, 3 )
	end
	
	local previoussizew, previoussizeh = VGUI_LEADER:GetSize()
	local previousposx, previousposy = VGUI_LEADER:GetPos()
	
		-- i should automate these.

	VGUI_KILLSTREAK = vgui.Create( "props_horizontalbar" )
	VGUI_KILLSTREAK:SetParent( VGUI_BASECONTENT )
	VGUI_KILLSTREAK:SetPos( 5, 5 + previousposy + previoussizeh )
		-- ( (panel height - the previous dlabels + gap) - the gap amount times the amount of boxes) / amount of boxes
	VGUI_KILLSTREAK:SetSize( basesizew - 10, (basesizeh - (previousposy + previoussizeh + 5) - 15) / 2 )
	VGUI_KILLSTREAK:SetBackColor( Color( 25, 25, 25, 255 ) )
		-- when theres 3 of them use this
	---------VGUI_KILLSTREAK:SetFillColor( Color( 76, 84, 255, 255 ) )
	VGUI_KILLSTREAK:SetFillColor( Color( 206, 61, 38, 255 ) )
	VGUI_KILLSTREAK:SetBarValue( propsPlayer:GetKillstreak() / propsPlayer:GetBestKillstreak() )
	VGUI_KILLSTREAK.PaintOver = function( self, w, h )
		surface.SetFont( "props_HUDTextSmall" )
		propsPlayer = LocalPlayer():GetObserverTarget() or LocalPlayer()
		local size_w, size_h = surface.GetTextSize( "Killstreak: " .. propsPlayer:GetKillstreak() .. " / " .. propsPlayer:GetBestKillstreak() )

		draw.SimpleText( "Killstreak: " .. propsPlayer:GetKillstreak() .. " / " .. propsPlayer:GetBestKillstreak(), "props_HUDTextSmall", w / 10, h/2 - size_h/2, Color( 230, 230, 230, 255 ) )
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
		-- when there's 3 of them use this
	-----------------VGUI_KD:SetFillColor( Color( 60, 166, 255, 255 ) )
	VGUI_KD:SetFillColor( Color( 59, 59, 167, 255 ) )
	VGUI_KD:SetBarValue( propsPlayer:GetKD() )
	VGUI_KD.PaintOver = function( self, w, h )
		surface.SetFont( "props_HUDTextSmall" )
		local size_w, size_h = surface.GetTextSize( "KD Ratio: " .. propsPlayer:GetKD() )

		draw.SimpleText( "KD Ratio: " .. propsPlayer:GetKD(), "props_HUDTextSmall", w / 10, h/2 - size_h/2, Color( 230, 230, 230, 255 ) )
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
		--draw.RoundedBox( 0, 0, 0, w, h, Color( 31, 31, 31, 235  ) )
		if not propsPlayer.LookingAtProp or not IsValid( propsPlayer.LookingAtProp ) then
			return
		end
		draw.RoundedBox( 0, 0, 0, w, h, Color( 47, 46, 46, 235 ) )
	end
	
	VGUI_PROPOWNER = vgui.Create( "DLabel" )
	VGUI_PROPOWNER:SetParent( VGUI_PROPPANEL )
	VGUI_PROPOWNER:SetText( "Owner: Shinycow" )
	VGUI_PROPOWNER:SetTextColor( Color( 230, 230, 230, 255 ) )
	VGUI_PROPOWNER:SetFont( "props_HUDTextSmall" )
	surface.SetFont( "props_HUDTextSmall" )
	local ownersize_w, ownersize_h = surface.GetTextSize( "Owner: Shinycow" )
	VGUI_PROPOWNER:SetPos( VGUI_PROPPANEL:GetWide() / 2 - ownersize_w / 2, VGUI_PROPPANEL:GetTall() / 2 - ownersize_h / 2 )
	VGUI_PROPOWNER:SetSize( ownersize_w, ownersize_h )
	VGUI_PROPOWNER.Think = function( self )
		if not propsPlayer.LookingAtProp or not IsValid( propsPlayer.LookingAtProp ) then
			self:SetText( "" )
			return
		end

		surface.SetFont( "props_HUDTextSmall" )
		
		local owner_text = "Owner:"
		
		--print( propsPlayer.LookingAtProp )
		local owner = propsPlayer.LookingAtProp:GetNetRequest( "Owner" )
		if not owner then
			propsPlayer.LookingAtProp:SendNetRequest( "Owner" )
		else
			owner_text = "Owner: " .. owner:Nick()
		end
		
		local ownersize_w, ownersize_h = surface.GetTextSize( owner_text )
		
		self:SetText( owner_text )
		self:SetPos( VGUI_PROPPANEL:GetWide() / 2 - ownersize_w / 2, VGUI_PROPPANEL:GetTall() / 2 - ownersize_h / 2 ) 
		self:SetSize( ownersize_w, ownersize_h )
	end
	
	
	--[[previoussizew, previoussizeh = VGUI_KD:GetSize()
	previousposx, previousposy = VGUI_KD:GetPos()
	
	VGUI_ACC = vgui.Create( "props_horizontalbar" )
	VGUI_ACC:SetParent( VGUI_BASECONTENT )
	VGUI_ACC:SetPos( 5, 5 + previoussizeh + previousposy )
	VGUI_ACC:SetSize( basesizew - 10, firstbarsizeh )
	--VGUI_ACC:SetBackColor( Color( 115, 24, 24, 255 ) )
	--VGUI_ACC:SetFillColor( Color( 182, 52, 52, 255 ) )
	VGUI_ACC:SetBackColor( Color( 25, 25, 25, 255 ) )
	--VGUI_ACC:SetFillColor( Color( 74, 73, 73, 255 ) )
	--VGUI_ACC:SetFillColor( Color( 94, 32, 131, 255 ) )
	VGUI_ACC:SetFillColor( Color( 143, 42, 255, 255 ) )
	VGUI_ACC:SetBarValue( propsPlayer:Accuracy() / 100 )
	VGUI_ACC.PaintOver = function( self, w, h )
		surface.SetFont( "props_HUDTextSmall" )
		local size_w, size_h = surface.GetTextSize( "Accuracy: " .. propsPlayer:Accuracy() .. "%" )
		
		draw.SimpleText( "Accuracy: " .. propsPlayer:Accuracy() .. "%", "props_HUDTextSmall", w / 10, h/2 - size_h/2, Color( 230, 230, 230, 255 ) )
		self:SetBarValue( propsPlayer:Accuracy() / 100 )
	end]]
	
	
	
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
				-- i cant do maths
			--alphaCalc = math.Approach( alphaCalc, 0, Lerp( (240 / timeToFade ) * FrameTime(), 1, 0 ) )
			--print( alphaCalc )
		end
		
		draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, alphaCalc ) )

		--[[if alphaCalc == 0 and timetaken2 == 0 then
			timetaken2 = SysTime()
			
			LocalPlayer():ChatPrint( "took " .. timetaken2 - timetaken .. " seconds" )
		end	]]
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
	--[[timer.Create( "CreatePropkillHUD", timeToFade + startFadeTime + 0.2 , 3, function()
		if alphaCalc == 0 and IsValid( VGUI_introBackground ) then
			CreateHUD()
			timer.Destroy( "CreatePropkillHUD" )
		end
	end )]]
end

hook.Add( "OnReloaded", "props_RedrawHUD", function()
	--CreateIntroHUD()
	CreateHUD( true )
end )

hook.Add( "Initialize", "props_DrawHUD", function()
	timer.Simple( 1, function()
		CreateIntroHUD()
	
		--CreateHUD()
	end )
end )