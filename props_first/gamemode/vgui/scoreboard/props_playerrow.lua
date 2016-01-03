--
-- This defines a new panel type for the player row. The player row is given a player
-- and then from that point on it pretty much looks after itself. It updates player info
-- in the think function, and removes itself when the player leaves the server.
--
local PANEL = {}

function PANEL:Init()
	
	self.AvatarButton = self:Add( "DButton" )
	self.AvatarButton:SetPos( 5, 5 )
	--self.AvatarButton:Dock( LEFT )
	self.AvatarButton:SetSize( 32, 32 )
	self.AvatarButton.DoClick = function()
		self.Player:ShowProfile()
	end
	
	self.Avatar	= vgui.Create( "AvatarImage", self.AvatarButton )
	self.Avatar:SetSize( 32, 32 )
	self.Avatar:SetMouseInputEnabled( false )	
	
	self.InfoButton = self:Add( "DButton" )
	self.InfoButton:SetPos( 37, 0 )
	self.InfoButton:SetWide( self:GetParent():GetWide() )
	self.InfoButton:SetTall( self:GetParent():GetTall() )
	self.InfoButton.Paint = function() end
	self.InfoButton.DoClick = function()
		local dmenu = DermaMenu()
		
		if self.Player:IsMuted() then
			local unmute = dmenu:AddOption( "Unmute Player", function()
				if not IsValid( self.Player ) then
					return
				end
				self.Player:SetMuted( true )
			end )
			
			unmute:SetIcon( "icon16/telephone_add.png" )
		else
			local mute = dmenu:AddOption( "Mute Player", function()
				if not IsValid( self.Player ) then
					return
				end
				self.Player:SetMuted( false )
			end )
			
			mute:SetIcon( "icon16/telephone_delete.png" )
		end
		
			-- check ulx permissions?
		if LocalPlayer():IsSuperAdmin() then
			local grabip = dmenu:AddOption( "Grab IP", function()
				if not IsValid( self.Player ) then
					return
				end
				RunConsoleCommand( "ulx", "grabip", self.Player:Nick() )
			end )
			
			grabip:SetIcon( "icon16/eye.png" )
		end
			
		
		dmenu:AddSpacer()
		dmenu:AddOption( "Close", function()
			dmenu:Hide()
		end )
		
		dmenu:Open()
	end
		
	self.Content = {}
	
	local width = self:GetParent():GetWide()
	for x=1, #InfoScoreboard do
		local y = InfoScoreboard[ x ]
		
		surface.SetFont( "ScoreboardSmall" )
		if x == 1 then
			local contentsizew,contentsizeh = surface.GetTextSize( y.id[ 2 ]( LocalPlayer() ) )
			
			local contentplus = #self.Content + 1
			
			self.Content[ contentplus ] = self:Add( "DLabel" )
			self.Content[ contentplus ]:SetText( y.id[ 2 ]( LocalPlayer() ) )
			self.Content[ contentplus ]:SetFont( "ScoreboardSmall" )
			self.Content[ contentplus ]:SetTextColor( Color( 230, 230, 230, 255 ) )
			self.Content[ contentplus ]:SetPos( 40, self:GetTall() / 2 )
			--self.Content[ contentplus ]:SetSize( width * y.space, contentsizeh )
		else				
			local contentplus = #self.Content + 1
			
			local contentsizew,contentsizeh = surface.GetTextSize( y.id[ 2 ]( LocalPlayer() ) )
			local previousposx, previousposy = self.Content[ contentplus - 1 ]:GetPos()
			local previoussizew, previoussizeh = self.Content[ contentplus - 1 ]:GetSize()
			
			self.Content[ contentplus ] = self:Add( "DLabel" )
			self.Content[ contentplus ]:SetText( y.id[ 2 ]( LocalPlayer() ) )
			self.Content[ contentplus ]:SetFont( "ScoreboardSmall" )
			self.Content[ contentplus ]:SetTextColor( Color( 230, 230, 230, 255 ) )
			--self.Content[ contentplus ]:SetPos( previoussizew + previousposx - (contentsizew * 0.6), self:GetTall() / 2 )
			
			--self.Content[ contentplus ]:SetPos( previoussizew + previousposx - 20, self:GetTall() / 2)
			--self.Content[ contentplus ]:SetSize( width * y.space, contentsizeh2 )
			
				-- centers content.
			self.Content[ contentplus ]:SetPos( y.text_posw + (y.text_sizew/2 - contentsizew/2), self:GetTall() / 2 )
				-- if you want it all on left side:
			--self.Content[ contentplus ]:SetPos( y.text_posw, self:GetTall() / 2 )
		end
	end
	
	self.updatescores = CurTime()
	
end

function PANEL:Setup( pl )
	
	self.Player = pl
	
	self.Avatar:SetPlayer( pl )
	--self.Name:SetText( )
	
	for k,v in pairs( self.Content ) do
		
		v:SetText( InfoScoreboard[ k ].id[ 2 ]( pl ) )
		
	end
	
	--self.Content_1:SetText( pl:Nick() )
	
	self:Think()

end

function PANEL:Think()
	if not self.updatescores or self.updatescores > CurTime() then
		return
	end
	
	if not IsValid( self.Player ) then
		self:Remove()
		return
	end
	
	local width = self:GetWide()
	for x=1, #InfoScoreboard do
		local y = InfoScoreboard[ x ]
		
		surface.SetFont( "ScoreboardSmall" )
		if x == 1 then
			local contentsizew,contentsizeh = surface.GetTextSize( y.id[ 2 ]( self.Player ) )
			
			local previousposx, previousposy = self.Content[ x ]:GetPos()
			
			self.Content[ x ]:SetText( y.id[ 2 ]( self.Player ) )
			self.Content[ x ]:SetPos( 40, previousposy )
			self.Content[ x ]:SizeToContents()
			--self.Content[ x ]:SetSize( width * y.space, contentsizeh )
		else		
			local contentplus = #self.Content + 1
			
			local contentsizew,contentsizeh = surface.GetTextSize( y.id[ 2 ]( self.Player ) )
			local previousposx, previousposy = self.Content[ x ]:GetPos()
	
			self.Content[ x ]:SetText( y.id[ 2 ]( self.Player ) )
			self.Content[ x ]:SetPos( y.text_posw + (y.text_sizew/2 - contentsizew/2), previousposy )
		end
	end
	
	self.updatescores = CurTime() + 0.7
end


function PANEL:Paint( w, h )
	
	if ( !IsValid( self.Player ) ) then
		return
	end

	--
	-- We draw our background a different colour based on the status of the player
	--

	if ( self.Player:Team() == TEAM_CONNECTING ) then
		draw.RoundedBox( 0, 0, 0, w, h, Color( 200, 200, 200, 215 ) )
		return
	end

	if not self.Player:Alive() then
		for k,v in pairs( self.Content ) do
		
			v:SetTextColor( Color( 198, 38, 38, 255 ) )
		
		end
	else
		for k,v in pairs( self.Content ) do
		
			v:SetTextColor( Color( 255, 255, 255, 255 ) )
		
		end
	end

		
	if self.Player == LocalPlayer() then
		draw.RoundedBox( 0, 0, 0, w, h, Color( 51, 51, 51, 255 ) )
	end
	
		-- 2nd is 32 - avatar
	draw.RoundedBox( 0, 32, h - 2, w - 32, 2, Color( 51, 51, 51, 255 ) )
		
end

vgui.Register( "props_playerrow", PANEL, "Panel" )

--[[function PANEL:Init()

	self.AvatarButton = self:Add( "DButton" )
	self.AvatarButton:Dock( LEFT )
	self.AvatarButton:SetSize( 32, 32 )
	self.AvatarButton.DoClick = function() self.Player:ShowProfile() end

	self.Avatar		= vgui.Create( "AvatarImage", self.AvatarButton )
	self.Avatar:SetSize( 32, 32 )
	self.Avatar:SetMouseInputEnabled( false )		

	self.Name		= self:Add( "DLabel" )
	self.Name:Dock( FILL )
	self.Name:SetFont( "ScoreboardDefault" )
	self.Name:DockMargin( 8, 0, 0, 0 )
		
	self.KickPlayer = self:Add( "DButton" )
	self.KickPlayer:SetPos( 325, 3 )
	self.KickPlayer:SetSize( 42, 32 )
	--self.KickPlayer:SetText( "Kick" )
	self.KickPlayer:SetText( "Options" )
	self.KickPlayer.DoClick = function()
		--LocalPlayer():ChatPrint(self.Player:Nick())
		--RunConsoleCommand("say", "!pkkick " .. self.Player:Nick())
		local Menu = DermaMenu()
			
		if LocalPlayer():IsAdmin() then
			local PlayerType = self.Player:SteamID()
			if self.Player:IsBot() then PlayerType = self.Player:Nick() end
				
			--local KickType = self.Player:SteamID()
			--if self.Player:IsBot() then KickType = self.Player:Nick() end
			local KickMenu = Menu:AddOption( "Kick", function() RunConsoleCommand("say", "!pkkick " .. PlayerType) end )
			KickMenu:SetIcon( "icon16/exclamation.png" )
				
			--local SlayType = self.Player:SteamID()
			--if self.Player:IsBot() then SlayType = self.Player:Nick() end
			local SlayMenu = Menu:AddOption( "Slay", function() RunConsoleCommand("say", "!pkslay " .. PlayerType .. " Quick slay.") end )
			SlayMenu:SetIcon( "icon16/heart_delete.png" )

			local TeamMenu = Menu:AddSubMenu( "Set Team" )
			TeamMenu:AddOption( "Spectator", function() RunConsoleCommand("say", "!pksetteam " .. PlayerType .. " 1") end )
			TeamMenu:AddOption( "Deathmatch", function() RunConsoleCommand("say", "!pksetteam " .. PlayerType .. " 2") end )
			TeamMenu:AddOption( "Red Team", function() RunConsoleCommand("say", "!pksetteam " .. PlayerType .. " 3") end )
			TeamMenu:AddOption( "Blue Team", function() RunConsoleCommand("say", "!pksetteam " .. PlayerType .. " 4") end )
		end
				
		local InfoMenu = Menu:AddOption( "More info", function() self.Player:OpenPlayerInfo() end )
		InfoMenu:SetIcon( "icon16/layout_add.png" )
			
		Menu:AddSpacer()
				
		Menu:AddOption( "Close", function() Menu:Hide() end )
				
		Menu:Open()
					
	end
		

	self.Gag		= self:Add( "DImageButton" )
	--self.Mute:SetSize( 32, 32 )
	self.Gag:SetSize( 16, 16 )
	self.Gag:Dock( RIGHT )
		
	self.Mute = self:Add( "DImageButton" )
	self.Mute:SetSize( 16, 16 )
	self.Mute:Dock( RIGHT )

	self.Ping		= self:Add( "DLabel" )
	self.Ping:Dock( RIGHT )
	self.Ping:SetWidth( 50 )
	self.Ping:SetFont( "ScoreboardDefault" )
	self.Ping:SetContentAlignment( 5 )

	self.Deaths		= self:Add( "DLabel" )
	self.Deaths:Dock( RIGHT )
	self.Deaths:SetWidth( 85 )
	self.Deaths:SetFont( "ScoreboardDefault" )
	self.Deaths:SetContentAlignment( 5 )

	self.Kills		= self:Add( "DLabel" )
	self.Kills:Dock( RIGHT )
	self.Kills:SetWidth( 80 )
	self.Kills:SetFont( "ScoreboardDefault" )
	self.Kills:SetContentAlignment( 5 )

	self.KD			= self:Add( "DLabel" )
	self.KD:Dock( RIGHT )
	self.KD:SetWidth( 90 )
	self.KD:SetFont( "ScoreboardDefault" )
	self.KD:SetContentAlignment( 5 )
		
	self:Dock( TOP )
	self:DockPadding( 3, 3, 3, 3 )
	self:SetHeight( 32 + 3*2 )
	self:DockMargin( 2, 0, 2, 2 )

end

function PANEL:Setup( pl )
	
	self.Player = pl
	
	self.Avatar:SetPlayer( pl )
	self.Name:SetText( pl:Nick() )
	
	self:Think()

end

function PANEL:Think()
	
	if ( !IsValid( self.Player ) ) then
		self:Remove()
		return
	end

	if ( self.PlName == nil or self.PlName != self.Player:Nick() ) then
		self.PlName = self.Player:Nick()
		self.Name:SetText( self.PlName )
	end
		
	if ( self.NumKD == nil or self.NumKD != 0 ) then--self.Player:GetKD() ) then
		self.NumKD = 0--self.Player:GetKD()
		self.KD:SetText( self.NumKD )
	end
		
	if ( self.NumKills == nil || self.NumKills != self.Player:Frags() ) then
		self.NumKills	=	self.Player:Frags()
		self.Kills:SetText( self.NumKills )
	end

	if ( self.NumDeaths == nil || self.NumDeaths != self.Player:Deaths() ) then
		self.NumDeaths	=	self.Player:Deaths()
		self.Deaths:SetText( self.NumDeaths )
	end

	if ( self.NumPing == nil || self.NumPing != self.Player:Ping() ) then
		self.NumPing	=	self.Player:Ping()
		self.Ping:SetText( self.NumPing )
	end

	--
	-- Change the icon of the mute button based on state
	--
	if ( self.Gagged == nil || self.Gagged != self.Player:IsMuted() ) then

		self.Gagged = self.Player:IsMuted()
		if ( self.Gagged ) then
			--self.Mute:SetImage( "icon32/muted.png" )
			self.Gag:SetImage( "icon16/telephone_delete.png" )
			--self.Gag:SetImage( "windowicons/delete-26.png" )
		else
			--self.Mute:SetImage( "icon32/unmuted.png" )
			self.Gag:SetImage( "icon16/telephone_add.png" )
		end

		self.Gag.DoClick = function() self.Player:SetMuted( !self.Gagged ) end

	end
		
	self.Player.PlayerMute = self.Player.PlayerMute or false
	if ( self.Muted == nil or self.Muted != self.Player.PlayerMute ) then
		
		self.Muted = self.Player.PlayerMute
		if self.Muted then
			self.Mute:SetImage( "icon16/pencil_delete.png" )
		else
			self.Mute:SetImage( "icon16/pencil_add.png" )
		end
			
		self.Mute.DoClick = function() self.Player.PlayerMute = not self.Muted end
			
	end

	--
	-- Connecting players go at the very bottom
	--
	if ( self.Player:Team() == TEAM_CONNECTING ) then
		self:SetZPos( 2000 )
	end

	--
	-- This is what sorts the list. The panels are docked in the z order, 
	-- so if we set the z order according to kills they'll be ordered that way!
	-- Careful though, it's a signed short internally, so needs to range between -32,768k and +32,767
	--
	self:SetZPos( (self.NumKills * -50) + self.NumDeaths )
	
end

function PANEL:Paint( w, h )
	
	if ( !IsValid( self.Player ) ) then
			return
		end

		--
		-- We draw our background a different colour based on the status of the player
		--

		if ( self.Player:Team() == TEAM_CONNECTING ) then
			draw.RoundedBox( 4, 0, 0, w, h, Color( 200, 200, 200, 215 ) )
			return
		end

		if  ( !self.Player:Alive() ) then
				-- light red.
			--draw.RoundedBox( 4, 0, 0, w, h, Color( 230, 200, 200, 255 ) )
				-- grey.
			--draw.RoundedBox( 4, 0, 0, w, h, Color( 125, 125, 125, 255 ) )
			local team_color = team.GetColor(self.Player:Team())
			draw.RoundedBox( 4, 0, 0, w, h, Color( team_color.r, team_color.g, team_color.b, 190 ) )
			self.Name:SetTextColor( Color( 198, 38, 38, 255 ) )
			return
		else
			self.Name:SetTextColor( Color( 255, 255, 255, 255 ) )
		end

		/*if ( self.Player:IsAdmin() ) then
			draw.RoundedBox( 4, 0, 0, w, h, Color( 230, 255, 230, 255 ) )
			return
		end*/

		//draw.RoundedBox( 4, 0, 0, w, h, Color( 230, 230, 230, 255 ) )

		
		draw.RoundedBox( 4, 0, 0, w, h, team.GetColor(self.Player:Team()) )

end
	

vgui.Register( "props_playerrow", PANEL, "Panel" )]]