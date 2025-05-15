--[[
				  _________.__    .__
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     /
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/
						\/      \/        \/\/         \/

		Clientside menu for management of bot paths
]]--

--[[Color palette ideas
https://colormagic.app/palette/6815aa1585aa24c2b2b6475a
https://colorhunt.co/palette/222831393e46948979dfd0b8
]]

-- https://wiki.facepunch.com/gmod/Silkicons

local PANEL = {}

local RequestedFullUpdate = false
function PANEL:Init()

	self:SetPos( 15, 15 )
	self:SetSize( self:GetParent():GetWide() - 30, self:GetParent():GetTall() - 30 )
	self:SetSkin( 'Props' )

	--
	-- LEFT SIDE
	--
	self.CurrentPathsBackground = self:Add("DPanel")
	--self.CurrentPathsBackground:SetWide( 400 )
	self.CurrentPathsBackground:Dock( FILL )
		-- Left, Top, Right, Bottom
	self.CurrentPathsBackground:DockMargin( 20, 10, 20, 10 )

	self.CurrentPathsBackground.Header = self.CurrentPathsBackground:Add( "DPanel" )
	self.CurrentPathsBackground.Header:Dock( TOP )
	self.CurrentPathsBackground.Header:SetTall( 40 )
	self.CurrentPathsBackground.Header.Paint = function(pnl,w,h)
		draw.RoundedBox( 0, 0, 0, w, h, Color( 80, 90, 100, 255 ))
	end

	self.CurrentPathsBackground.HeaderLabel = self.CurrentPathsBackground.Header:Add( "DLabel" )
	self.CurrentPathsBackground.HeaderLabel:SetFont( "props_HUDTextLarge" )
	self.CurrentPathsBackground.HeaderLabel:Dock( TOP  )
		-- Wish I knew about this a long time ago. 5 = center
	self.CurrentPathsBackground.HeaderLabel:SetContentAlignment( 5 )
	self.CurrentPathsBackground.HeaderLabel:SetText( "EXISTING PATHS")
	self.CurrentPathsBackground.HeaderLabel:SizeToContents()

	self.ScrollPanel = self.CurrentPathsBackground:Add("DScrollPanel")
	self.ScrollPanel:Dock( FILL )

	self.Content = {}

		--DIconLayout is a bitch to work with lol
	--[[self.Content = self.ScrollPanel:Add( "DIconLayout" )
	self.Content:SetSpaceY( 2 )
	self.Content:Dock( FILL )]]


	--
	-- RIGHT SIDE
	--
	self.PathManagementBackground = self:Add("DPanel")
	self.PathManagementBackground:Dock( RIGHT )
		-- Left, Top, Right, Bottom
	self.PathManagementBackground:DockMargin( 0, 80, 20, 40 )
		-- Should we just make this a static number?
	self.PathManagementBackground:SetWide( self:GetWide() / 4 )
	self.PathManagementBackground.Paint = function() end

	self.PathManagementBackground.StartStopButton = self.PathManagementBackground:Add( "DButton" )
	self.PathManagementBackground.StartStopButton:Dock( TOP )
		-- Left, Top, Right, Bottom
	self.PathManagementBackground.StartStopButton:DockMargin( 0, 0, 0, 20 )
	self.PathManagementBackground.StartStopButton:SetText( "Start/Stop" )
	self.PathManagementBackground.StartStopButton:SetTooltip("Start or stop a bot recording. Stopping will create the path")
	self.PathManagementBackground.StartStopButton.DoClick = function( pnl )
		RunConsoleCommand("props_botpaths_startstop")
	end
	self.PathManagementBackground.StartStopButton.DoRightClick = function( pnl )
		Derma_StringRequest( "Customized Bot Pathing",
		"Input your custom bot path name",
		"custom_" .. string.lower(os.date("%Y%b%d-%H%M", os.time())),
		function( text ) RunConsoleCommand( "props_botpaths_startstop", text ) end,
		function() end
		)
	end


		-- Todo: Make it disabled if we aren't currently running anything!
	self.PathManagementBackground.CancelButton = self.PathManagementBackground:Add( "DButton" )
	self.PathManagementBackground.CancelButton:Dock( TOP )
	self.PathManagementBackground.CancelButton:DockMargin( 0, 0, 0, 20 )
	self.PathManagementBackground.CancelButton:SetText( "Cancel Recording" )
	self.PathManagementBackground.CancelButton:SetDisabled( not BOTPATHS_ISPLAYERRECORDING )
	self.PathManagementBackground.CancelButton.DoClick = function( pnl )
		RunConsoleCommand("props_botpaths_cancel")
	end

		-- Todo: Make it disabled if we don't have any paths saved
	self.PathManagementBackground.DeleteLocalPathsButton = self.PathManagementBackground:Add( "DButton" )
	self.PathManagementBackground.DeleteLocalPathsButton:Dock( TOP )
	self.PathManagementBackground.DeleteLocalPathsButton:DockMargin( 0, 0, 0, 20 )
	self.PathManagementBackground.DeleteLocalPathsButton:SetText( "Delete My Paths" )
	self.PathManagementBackground.DeleteLocalPathsButton:SetTooltip("(FUTURE UPDATE) Deletes all the paths you have created")
	self.PathManagementBackground.DeleteLocalPathsButton:SetDisabled( true )

	self.PathManagementBackground.ResetPathsButton = self.PathManagementBackground:Add( "DButton" )
	self.PathManagementBackground.ResetPathsButton:Dock( TOP )
	self.PathManagementBackground.ResetPathsButton:DockMargin( 0, 0, 0, 20 )
	self.PathManagementBackground.ResetPathsButton:SetText( "Reset All Paths" )
	if not LocalPlayer():IsSuperAdmin() then
		self.PathManagementBackground.ResetPathsButton:SetDisabled( true )
	end
	self.PathManagementBackground.ResetPathsButton.DoClick = function( pnl )
		Derma_Query(
			"This will delete ALL recorded paths.",
			"Confirmation",
			"Yes",
			function() RunConsoleCommand("props_botpaths_reset", "yes") end,
			"No"
		)
	end

	self.PathManagementBackground.SavePathsButton = self.PathManagementBackground:Add( "DButton" )
	self.PathManagementBackground.SavePathsButton:Dock( TOP )
	self.PathManagementBackground.SavePathsButton:DockMargin( 0, 0, 0, 20 )
	self.PathManagementBackground.SavePathsButton:SetText( "Save Paths to File" )
	if not LocalPlayer():IsSuperAdmin() then
		self.PathManagementBackground.SavePathsButton:SetDisabled( true )
	end
	self.PathManagementBackground.SavePathsButton.DoClick = function( pnl )
		RunConsoleCommand("props_botpaths_save2")
	end

		-- Todo: Make it disabled if we don't meet the adminonly / allowspawning checks.
		-- Also make it disabled if there's no existing paths.
	self.PathManagementBackground.SpawnBotButton = self.PathManagementBackground:Add( "DButton" )
	self.PathManagementBackground.SpawnBotButton:Dock( TOP )
	self.PathManagementBackground.SpawnBotButton:DockMargin( 0, 0, 0, 20 )
	self.PathManagementBackground.SpawnBotButton:SetText( "Add Bot" )
	self.PathManagementBackground.SpawnBotButton:SetTooltip("Spawns a bot into the server")
	if not PROPKILL.Config["bots_allowspawning"].default then
		self.PathManagementBackground.SpawnBotButton:SetDisabled( true )
	elseif PROPKILL.Config["bots_adminonly"].default and not LocalPlayer():IsAdmin() then
		self.PathManagementBackground.SpawnBotButton:SetDisabled( true )
	end
	self.PathManagementBackground.SpawnBotButton.DoClick = function( pnl )
		RunConsoleCommand("props_botpaths_spawnbot")
	end


	hook.Add( "props_BotPaths_PathInfoChanged", self, function( pathid )
		self:InvalidateLayout()
	end )

	hook.Add( "props_BotPaths_NetworkRecording", self, function( pnl, pathid, active )
		pnl.PathManagementBackground.CancelButton:SetDisabled( not active )
	end)

	if not RequestedFullUpdate then
		net.Start( "props_BotPaths_RequestFullUpdate" )
		net.SendToServer()

		RequestedFullUpdate = true
	end

	--[[self.TestPaths =
	{
	["first"] = {enabled = false, Creator = LocalPlayer():SteamID64()},
	["second"] = {enabled = false, Creator = LocalPlayer():SteamID64()},
	}
	for i=1,5 do
		self.TestPaths["fagfdasfasdfasfdsafasdfasdfasdasdfasdf"..i] = {enabled=true, Creator=LocalPlayer():SteamID64()}
	end]]

end

function PANEL:PerformLayout()

		-- Remove all contents children
	self.ScrollPanel:Clear()

	--for k,v in next, self.TestPaths do
	for k,v in next, BOTPATHS_RECORDINGS or {} do
			-- The individual bars. This will hold text and buttons for each bot path
		self.Content[ k ] = self.ScrollPanel:Add("DPanel")
		self.Content[ k ]:Dock( TOP )
		self.Content[ k ]:DockMargin( 0, 2, 0, 0)
		self.Content[ k ]:SetSize( self.CurrentPathsBackground:GetWide(), 39 )
		self.Content[ k ].Paint = function( pnl, w, h)
			--draw.RoundedBox( 0, 0, 0, w, h, Color( 180, 180, 180, 255 ) )
		end

		self.Content[ k ].ToggleButton = self.Content[ k ]:Add( "DCheckBox" )
		self.Content[ k ].ToggleButton:Dock( LEFT )
			-- Default CheckBox is 15x15. If our parent panel's height is 39 then we need to offset by 12x12
		self.Content[ k ].ToggleButton:DockMargin( 35, 12, 0, 12 )
		self.Content[ k ].ToggleButton:SetTooltip("Toggle the path for bots to use")
		self.Content[ k ].ToggleButton.ParentPathID = k
		self.Content[ k ].ToggleButton:SetChecked( v.ActivePath )
		self.Content[ k ].ToggleButton.OnChange = function( pnl, bVal )
			RunConsoleCommand( "props_botpaths_togglepath", pnl.ParentPathID )
		end


		self.Content[ k ].PathingName = self.Content[ k ]:Add( "DLabel" )
		self.Content[ k ].PathingName:SetText( k )
		self.Content[ k ].PathingName:SetTextColor( Color( 90, 90, 90, 255 ) )
			-- We'll just cut off the text if it's longer than this
		self.Content[ k ].PathingName:SetFont( "props_HUDTextSmall" )
		self.Content[ k ].PathingName:SetWide( 300 )
		self.Content[ k ].PathingName:Dock( LEFT )
		self.Content[ k ].PathingName:DockMargin( 25, 0, 0, 0)
		self.Content[ k ].PathingName:SetMouseInputEnabled( true )
		self.Content[ k ].PathingName:SetTooltip("Created by " .. util.SteamIDFrom64(v.Creator))

		self.Content[ k ].DeleteButton = self.Content[ k ]:Add( "DImageButton" )
		self.Content[ k ].DeleteButton:SetImage( "icon16/cross.png" )
		self.Content[ k ].DeleteButton.ParentPathID = k
		self.Content[ k ].DeleteButton:Dock( RIGHT )
			-- Default CheckBox is 16x16. If our parent panel's height is 39 then we need to offset by 11x11
			-- Since we are docked right, dock margin 35 in right argument actually goes INWARD (as in, to the left). Cool!
		self.Content[ k ].DeleteButton:DockMargin( 0, 11, 35, 11 )
		self.Content[ k ].DeleteButton:SetSize( 16, 16 )
		self.Content[ k ].DeleteButton:SetTooltip("Delete path")
		self.Content[ k ].DeleteButton.DoClick = function( pnl )
			RunConsoleCommand( "props_botpaths_deletepath", pnl.ParentPathID )
			--self.TestPaths[ pnl.ParentPathID ] = nil
			self:InvalidateLayout()
		end


	end
end

vgui.Register( "props_BotsMenu", PANEL )
