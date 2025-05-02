--[[
				  _________.__    .__
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     /
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/
						\/      \/        \/\/         \/

		Clientside menu for viewing achievements
]]--

local PANEL = {}

function PANEL:Init()

		-- SortMode 1 = Sort by Title, SortMode 2 = Sort by Difficulty, SortMode 3 = Sort by Percentage of Players Completed
	self.SortMode = PROPKILL.ClientConfig["props_DefaultAchievementSorting"].currentvalue
	self:SetPos( 15, 15 )
	self:SetSize( self:GetParent():GetWide() - 30, self:GetParent():GetTall() - 30 )


    -- We don't include the TitlePanel in the DScrollPanel because we want this to be shown at all times
    self.TitlePanel = self:Add( "DPanel" )
    self.TitlePanel:Dock( TOP )
    self.TitlePanel:SetSize( self:GetWide(), 50 )--self.Content[ k ]:GetTall() )
    --self.TitlePanel.Paint = function() end

    self.TitlePanel.TextName = self.TitlePanel:Add( "DLabel" )
	self.TitlePanel.TextName:SetText( "Achievement Name" )
	self.TitlePanel.TextName:SetFont( "props_HUDTextSmall" )
	self.TitlePanel.TextName:SetTextColor( Color( 90, 90, 90, 255 ) )
	surface.SetFont( "props_HUDTextSmall" )
	local headertextsize_w, headertextsize_h = surface.GetTextSize( "Achievement Name" )
	self.TitlePanel.TextName:SetSize( headertextsize_w, headertextsize_h )
	self.TitlePanel.TextName:SetPos( 5, self.TitlePanel:GetTall() / 2 - headertextsize_h / 2 )
	self.TitlePanel.TextName:SetMouseInputEnabled( true )
	local function TitlePanelClickSort( pnl )
		local menu = DermaMenu( pnl )

		local SortTitle = menu:AddOption( "Sort by Title", function() self:SetSortMode( 1 ) end )
		local SortDifficulty = menu:AddOption( "Sort by Difficulty", function() self:SetSortMode( 2 ) end )
		local SortCompleted = menu:AddOption( "Sort by Completed", function() self:SetSortMode( 3 ) end )

		menu:AddSpacer()
		menu:AddOption( "Close" )

		menu:Open()

		menu.Think = function()
			if not IsValid( pnl ) then
				menu:Hide()
				if IsValid( menu ) then
					menu:Remove()
				end
			end
		end
	end
	self.TitlePanel.TextName.DoClick = function( pnl ) TitlePanelClickSort( pnl ) end
	self.TitlePanel.TextName.DoRightClick = function( pnl ) TitlePanelClickSort( pnl ) end

    self.TitlePanel.TextPercentage = self.TitlePanel:Add( "DLabel" )
	self.TitlePanel.TextPercentage:SetText( "Percentage of Players Completed" )
	self.TitlePanel.TextPercentage:SetFont( "props_HUDTextSmall" )
	self.TitlePanel.TextPercentage:SetTextColor( Color( 90, 90, 90, 255 ) )
	surface.SetFont( "props_HUDTextSmall" )
	local headertextsize_w, headertextsize_h = surface.GetTextSize( "Percentage of Players Completed" )
	self.TitlePanel.TextPercentage:SetSize( headertextsize_w, headertextsize_h )
	self.TitlePanel.TextPercentage:SetPos( self.TitlePanel:GetWide() + 5 - headertextsize_w, self.TitlePanel:GetTall() / 2 - headertextsize_h / 2 )

	self.ScrollPanel = self:Add("DScrollPanel")
	self.ScrollPanel:Dock( FILL )

	self.Content = self.ScrollPanel:Add( "DIconLayout" )
	self.Content:SetSpaceY( 2 )
	self.Content:Dock( FILL )

	self:CallUpdate()

end

function PANEL:SetSortMode( mode )
	self.SortMode = mode
	self:CallUpdate()
end

function PANEL:GetSortMode()
	return self.SortMode
end

function PANEL:CallUpdate()
		-- Remove all contents children
	self.Content:Clear()

	local GetCombatAchievements = PROPKILL.GetCombatAchievements()
	local OrganizedAchievements1 = {}
	local OrganizedAchievementsFinal = {}

		-- This uses GetCombatAchievementByFancyTitle which is slower, so we only use it for the first sort mode.
	if self:GetSortMode() == 1 then
		for k,v in next, GetCombatAchievements do
			OrganizedAchievements1[ #OrganizedAchievements1 + 1 ] = v:GetFancyTitle()
		end

		table.sort(OrganizedAchievements1, function( a, b) return tostring(a) < tostring(b) end)

		for i=1,#OrganizedAchievements1 do
			local v = OrganizedAchievements1[i]

			OrganizedAchievementsFinal[i] = PROPKILL.GetCombatAchievementByFancyTitle( v )
		end
	elseif self:GetSortMode() == 2 or self:GetSortMode() == 3 then
		for k,v in next, GetCombatAchievements do
			OrganizedAchievements1[ #OrganizedAchievements1 + 1 ] = k
		end

		table.sort(OrganizedAchievements1, function( a, b) return tostring(a) < tostring(b) end)

		for i=1,#OrganizedAchievements1 do
			local v = OrganizedAchievements1[i]

			OrganizedAchievementsFinal[i] = PROPKILL.GetCombatAchievementByUniqueID( v )
		end

		if self:GetSortMode() == 2 then
				-- In ascending order i.e easiest on top
			table.SortByMember(OrganizedAchievementsFinal, "difficulty", true)
		else
			table.SortByMember(OrganizedAchievementsFinal, "numCompletions")
		end
	end

    for k=1,#OrganizedAchievementsFinal do
		local v = OrganizedAchievementsFinal[k]

            -- The individual bars. This will hold our text and also button to serve as a dropdown for more info.
        self.Content[ k ] = self.Content:Add( "DPanel" )
        self.Content[ k ]:SetSize( self:GetWide(), 50 )--self.Content[ k ]:GetTall() )
        self.Content[ k ].Paint = function( pnl, w, h)
            if PROPKILL.GetCombatAchievement( v:GetUniqueID() ):GetProgression( LocalPlayer() ) then
                    -- light greenish color
                draw.RoundedBox( 0, 0, 0, w, h, Color( 110, 255, 110, 255 ) )
            else
                draw.RoundedBox( 0, 0, 0, w, h, Color( 180, 180, 180, 255 ) )
            end
        end
        if PROPKILL.GetCombatAchievement( v:GetUniqueID() ):GetProgression( LocalPlayer() ) then
			self.Content[ k ].LocalPlayerAccomplished = true
		end

            -- Achievement title
        self.Content[ k ].ContentTitle = self.Content[ k ]:Add( "DLabel" )
		self.Content[ k ].ContentTitle:SetText( v:GetFancyTitle() )
		self.Content[ k ].ContentTitle:SetFont( "props_HUDTextTiny" )
		self.Content[ k ].ContentTitle:SetTextColor( Color( 90, 90, 90, 255 ) )
		surface.SetFont( "props_HUDTextTiny" )
		local contentnamesize_w, contentnamesize_h = surface.GetTextSize( v:GetFancyTitle() )
		self.Content[ k ].ContentTitle:SetSize( contentnamesize_w, contentnamesize_h )
		self.Content[ k ].ContentTitle:SetPos( 15, self.Content[ k ]:GetTall() / 2 - contentnamesize_h / 2 )

            -- Percentage of Players Completed for each achievement
        self.Content[ k ].ContentPercentage = self.Content[ k ]:Add( "DLabel" )
		self.Content[ k ].ContentPercentage:SetText( table.FastConcat("", v:GetCompletionRate() / (PROPKILL.Statistics["totaluniquejoins"] or 1) * 100, "%") )
		self.Content[ k ].ContentPercentage:SetFont( "props_HUDTextTiny" )
		self.Content[ k ].ContentPercentage:SetTextColor( Color( 90, 90, 90, 255 ) )
		surface.SetFont( "props_HUDTextTiny" )
		local contentnamesize_w, contentnamesize_h = surface.GetTextSize( table.FastConcat("", v:GetCompletionRate() / (PROPKILL.Statistics["totaluniquejoins"] or 1) * 100, "%") )
		self.Content[ k ].ContentPercentage:SetSize( contentnamesize_w, contentnamesize_h )
		self.Content[ k ].ContentPercentage:SetPos(
			self.Content:GetWide() - contentnamesize_w - 15,
			self.Content[ k ]:GetTall() / 2 - contentnamesize_h / 2
		)
        self.Content[ k ].ContentPercentage.PerformLayout = function( pnl )
            surface.SetFont( "props_HUDTextTiny" )
            local contentnamesize_w, contentnamesize_h = surface.GetTextSize( table.FastConcat("", v:GetCompletionRate() / (PROPKILL.Statistics["totaluniquejoins"] or 1) * 100, "%") )
            self.Content[ k ].ContentPercentage:SetSize( contentnamesize_w, contentnamesize_h )
            self.Content[ k ].ContentPercentage:SetPos(
                self.Content:GetWide() - contentnamesize_w - 15,
                self.Content[ k ]:GetTall() / 2 - contentnamesize_h / 2
            )
        end


            -- Dropdown for Achievement description and more info later on
        self.Content[ k ].ButtonForDropdown = self.Content[ k ]:Add( "DButton" )
		self.Content[ k ].ButtonForDropdown:SetPos( 0, 0 )
		self.Content[ k ].ButtonForDropdown:SetWide( self.Content[ k ]:GetWide() )
		self.Content[ k ].ButtonForDropdown:SetTall( self.Content[ k ]:GetTall() )
		self.Content[ k ].ButtonForDropdown:SetText( "" )
		self.Content[ k ].ButtonForDropdown.Paint = function( self, w, h )
			--draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 80, 80, 0 ) )
		end
		self.Content[ k ].ButtonForDropdown.DoClick = function( pnl )
			if IsValid( self.Content[ k ].ButtonForDropdown.ContentInfo ) then
				--self.RightPanel.RecentContentPanel:RemoveItem( self.Content[ k ].ButtonForDropdown.ContentInfo )
				self.Content[ k ].ButtonForDropdown.ContentInfo:Remove()
			else
				self.Content[ k ].ButtonForDropdown.ContentInfo = self.Content:Add( "DPanel" )
				--self.Content[ k ].ButtonForDropdown.ContentInfo:SetPos( 40, 0 )
				self.Content[ k ].ButtonForDropdown.ContentInfo:SetWide( self.Content[ k ]:GetWide() )
				self.Content[ k ].ButtonForDropdown.ContentInfo:SetTall( 70 )
				self.Content[ k ].ButtonForDropdown.ContentInfo.Paint = function( self, w, h )
					draw.RoundedBox( 0, 0, 0, w, h, Color( 110, 110, 110, 255 ) )
				end

				self.Content[ k ].ButtonForDropdown.ContentInfo.DescriptionThings = self.Content[ k ].ButtonForDropdown.ContentInfo:Add( "DLabel" )
				self.Content[ k ].ButtonForDropdown.ContentInfo.DescriptionThings:SetText( v:GetDescription() .. "\nDifficulty: " .. v.difficulty )
				self.Content[ k ].ButtonForDropdown.ContentInfo.DescriptionThings:SetTextColor( Color( 240, 240, 240, 255 ) )
				self.Content[ k ].ButtonForDropdown.ContentInfo.DescriptionThings:SetFont( "props_HUDTextSmall" )
				self.Content[ k ].ButtonForDropdown.ContentInfo.DescriptionThings:SetPos( 10, 2 )
				self.Content[ k ].ButtonForDropdown.ContentInfo.DescriptionThings:SizeToContents()


				self.Content[ k ].ButtonForDropdown.ContentInfo.AnnounceCompletion = self.Content[ k ].ButtonForDropdown.ContentInfo:Add( "DButton" )
				self.Content[ k ].ButtonForDropdown.ContentInfo.AnnounceCompletion:SetText( "Announce Completion" )
				--self.Content[ k ].ButtonForDropdown.ContentInfo.DescriptionThings:SetTextColor( Color( 240, 240, 240, 255 ) )
				self.Content[ k ].ButtonForDropdown.ContentInfo.AnnounceCompletion:SetFont( "props_HUDTextTiny" )
				self.Content[ k ].ButtonForDropdown.ContentInfo.AnnounceCompletion:SizeToContents()
				self.Content[ k ].ButtonForDropdown.ContentInfo.AnnounceCompletion:SetPos(
					self.Content[ k ].ButtonForDropdown.ContentInfo:GetWide() - self.Content[ k ].ButtonForDropdown.ContentInfo.AnnounceCompletion:GetWide() - 10,
					self.Content[ k ].ButtonForDropdown.ContentInfo:GetTall() - self.Content[ k ].ButtonForDropdown.ContentInfo.AnnounceCompletion:GetTall() - 5
				)
				self.Content[ k ].ButtonForDropdown.ContentInfo.AnnounceCompletion:SetVisible( self.Content[ k ].LocalPlayerAccomplished )
				self.Content[ k ].ButtonForDropdown.ContentInfo.AnnounceCompletion.DoClick = function( pnl )
					RunConsoleCommand("props_achievements", self.Content[ k ].ContentTitle:GetText())
				end

                    -- Positions this new panel (aka the dropdown info) to right underneath our Achievement Title panel
                    -- Gives the illusion if a dropdown
				self.Content[ k ].ButtonForDropdown.ContentInfo:MoveToAfter( self.Content[ k ] )
			end
		end
			-- Opted instead for a button in the dropdown panel
		--[[self.Content[ k ].ButtonForDropdown.DoRightClick = function( pnl )
			if not self.Content[ k ].LocalPlayerAccomplished then return end

			local menu = DermaMenu( pnl )

			local AnnounceCompletion = menu:AddOption( "Announce completion", function() RunConsoleCommand("props_achievements", self.Content[ k ].ContentTitle:GetText()) end )

			menu:AddSpacer()
			menu:AddOption( "Close" )

			menu:Open()

			menu.Think = function()
				if not IsValid( pnl ) then
					menu:Hide()
					if IsValid( menu ) then
						menu:Remove()
					end
				end
			end
		end]]

    end

    hook.Add("props_NetworkPlayerAchievementsCompleted", self, function( pnl )
        if not IsValid(pnl) then return end

        --self:InvalidateLayout()
        pnl:CallUpdate()
    end )
end

vgui.Register( "props_AchievementsMenu", PANEL )
