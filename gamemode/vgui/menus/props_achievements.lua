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

    for k,v in next, PROPKILL.GetCombatAchievements() do
            -- The individual bars. This will hold our text and also button to serve as a dropdown for more info.
        self.Content[ k ] = self.Content:Add( "DPanel" )
        self.Content[ k ]:SetSize( self:GetWide(), 50 )--self.Content[ k ]:GetTall() )
        self.Content[ k ].Paint = function( pnl, w, h)
            if PROPKILL.GetCombatAchievement( k ):GetProgression( LocalPlayer() ) then
                    -- light greenish color
                draw.RoundedBox( 0, 0, 0, w, h, Color( 110, 255, 110, 255 ) )
            else
                draw.RoundedBox( 0, 0, 0, w, h, Color( 180, 180, 180, 255 ) )
            end
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
		self.Content[ k ].ContentPercentage:SetText( v:GetCompletionRate() )
		self.Content[ k ].ContentPercentage:SetFont( "props_HUDTextTiny" )
		self.Content[ k ].ContentPercentage:SetTextColor( Color( 90, 90, 90, 255 ) )
		surface.SetFont( "props_HUDTextTiny" )
		local contentnamesize_w, contentnamesize_h = surface.GetTextSize( v:GetCompletionRate() )
		self.Content[ k ].ContentPercentage:SetSize( contentnamesize_w, contentnamesize_h )
		self.Content[ k ].ContentPercentage:SetPos( self.Content[ k ]:GetWide() - contentnamesize_w - 15, self.Content[ k ]:GetTall() / 2 - contentnamesize_h / 2 )
        self.Content[ k ].ContentPercentage.PerformLayout = function( pnl )
            self.Content[ k ].ContentPercentage:SetText( table.FastConcat("", v:GetCompletionRate() / (PROPKILL.Statistics["totaluniquejoins"] or 1) * 100, "%") )
            surface.SetFont( "props_HUDTextTiny" )
            local contentnamesize_w, contentnamesize_h = surface.GetTextSize( table.FastConcat("", v:GetCompletionRate() / (PROPKILL.Statistics["totaluniquejoins"] or 1) * 100, "%") )
            self.Content[ k ].ContentPercentage:SetSize( contentnamesize_w, contentnamesize_h )
            self.Content[ k ].ContentPercentage:SetPos(
                self.Content[ k ]:GetWide() - contentnamesize_w - 15,
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
		self.Content[ k ].ButtonForDropdown.DoClick = function( self2 )
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
				self.Content[ k ].ButtonForDropdown.ContentInfo.DescriptionThings:SetText( v:GetDescription() )
				self.Content[ k ].ButtonForDropdown.ContentInfo.DescriptionThings:SetTextColor( Color( 240, 240, 240, 255 ) )
				self.Content[ k ].ButtonForDropdown.ContentInfo.DescriptionThings:SetFont( "props_HUDTextSmall" )
				self.Content[ k ].ButtonForDropdown.ContentInfo.DescriptionThings:SetPos( 10, 2 )
				self.Content[ k ].ButtonForDropdown.ContentInfo.DescriptionThings:SizeToContents()

                    -- Positions this new panel (aka the dropdown info) to right underneath our Achievement Title panel
                    -- Gives the illusion if a dropdown
				self.Content[ k ].ButtonForDropdown.ContentInfo:MoveToAfter( self.Content[ k ] )
			end
		end

    end

    hook.Add("props_NetworkPlayerAchievementsCompleted", "propsPanelAchievements_UpdateInformation", function()
        if not IsValid(self) then return end
        self:InvalidateLayout()
    end )

end

vgui.Register( "props_AchievementsMenu", PANEL )
