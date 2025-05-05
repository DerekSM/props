--[[
				  _________.__    .__                                  
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     / 
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/  
						\/      \/        \/\/         \/              

		Clientside menu for changing gamemode configuration
]]--

local PANEL = {}

function PANEL:Init()
	self:SetPos( 15, 15 )
	self:SetSize( self:GetParent():GetWide() - 30, self:GetParent():GetTall() - 30 )

	self.configCategories = {}

	self.SearchPanel = self:Add("DPanel")
	self.SearchPanel:Dock( TOP )
	self.SearchPanel:DockMargin( 0, 0, 0, 5 )
	self.SearchPanel.Paint = function() end

	self.SearchBar = self.SearchPanel:Add("DTextEntry")
	self.SearchBar:SetWide( 100 )
	self.SearchBar:Dock( RIGHT )
	self.SearchBar:SetPlaceholderText( "Filter Items..." )
	self.SearchBar:SetUpdateOnType( true )
	self.SearchBar.OnValueChange = function( pnl, text )
		self:FilterGamemodeConfigEntries( string.lower(text) )
	end

	self:SetSkin( "Props" )

	self.CatList = self:Add("DCategoryList")
	self.CatList:Dock( FILL )

		-- This little hack will resize the individual settings panels based on whether scrollbar is visible
	self.CatList.OnScrollbarAppear = function( pnl )
		local VerticalScrollbar = pnl:GetVBar()
		for k,categories in next, self.AddedCategories do
			for k2, panels in next, categories.Contents:GetChildren() do
				if VerticalScrollbar:IsVisible() then
					--print("Scrollbar active. Changing position.")
					local ScrollbarWidth  = VerticalScrollbar:GetWide()
					panels.OldPanelWide = panels:GetWide()

					panels:SetWide(
						panels.OldPanelWide - math.floor(ScrollbarWidth / 2)
					)
				else
					--print("Scrollbar inactive. Resetting position.")
					panels:SetWide( panels.OldPanelWide )
				end
			end
		end
	end
	oldCatPerformLayout = self.CatList.PerformLayout
	self.CatList.PerformLayout = function( pnl )
		oldCatPerformLayout( pnl )

			-- This is because we need to set our sizes of our config item panels.
			-- Without this initial check we will get unreliable sizes being returned.
		if not pnl.FirstPerformLayoutDone then
			pnl.FirstPerformLayoutDone = true
			self:CreateConfigItems()
			return
		end
	end

	self.AddedCategories = {}
	self.ScrollPanels = {}
	self.Content = {}

	--local CategoryDownArrow = GWEN.CreateTextureNormal( 496, 272+32, 15, 15 )


	local ConfigCount = 0
	for k,v in SortedPairs( PROPKILL.Config ) do
		ConfigCount = ConfigCount + 1

		if not self.AddedCategories[v.Category] then
			local Category = self.CatList:Add( v.Category )
			Category:SetAnimTime( 0 )
			Category:SetSkin( "Props" )
			Category.Header:SetFont( "props_HUDTextSmall" )
			Category.Header:SetContentAlignment( 1 )
			Category.Header:SetTextInset( 8, 0 )
				-- Assume the default action is handling players
			if v.Category == "Player Management" then
				Category:SetExpanded( true )
			else
				Category:SetExpanded( false )
			end

			self.AddedCategories[v.Category] = Category

			self.Content[v.Category] = vgui.Create("DIconLayout", Category)
			self.Content[v.Category]:SetSpaceY( 2 )
			self.Content[v.Category]:SetSpaceX( 2 )
			self.Content[v.Category]:Dock( FILL )
			self.Content[v.Category]:DockMargin(1,0,0,0)
			oldPerformLayout = self.Content[v.Category].PerformLayout
			Category:SetContents(self.Content[v.Category])
		end

	end

	self.configPanelSaveButton = self:Add( "DButton" )
	self.configPanelSaveButton:Dock( BOTTOM )
	self.configPanelSaveButton:DockMargin( 0, 15, 0, 2 )
	self.configPanelSaveButton:SetText( "Save Settings To File")
	self.configPanelSaveButton.DoClick = function()
		RunConsoleCommand("props_savesettings")
	end

	hook.Add("props_UpdateConfig", self, function( pnl, setting, setting_type, newvalue )
		if not IsValid(pnl) then return end

		local PKConfig = PROPKILL.Config[setting]

		pnl.Content[ PKConfig.Category ][ setting ].Content:SetValue( newvalue )
	end)
end

function PANEL:CreateConfigItems()
	for k,v in SortedPairs( PROPKILL.Config ) do
			-- Will hold our individual labels with buttons/numslider/checkboxes
		self.Content[v.Category][ k ] = self.Content[v.Category]:Add("DPanel")
		self.Content[v.Category][ k ]:SetSize( self.CatList:GetWide() / 2 - 4, 65 )

		local LabelXPosition = 5
		local LabelWrappedAround = false
		local LabelFontName = "props_HUDTextTiny"
		local LabelOverallTextWidth = self.CatList:GetWide() / 2 - 8 - LabelXPosition
		surface.SetFont( LabelFontName )

		local LabelTextSizeWidth = surface.GetTextSize( v.desc )

		self.Content[v.Category][ k ].Description = self.Content[v.Category][ k ]:Add( "DLabel" )
		self.Content[v.Category][ k ].Description:SetPos( LabelXPosition, 3 )
		self.Content[v.Category][ k ].Description:SetFont( LabelFontName )
		self.Content[v.Category][ k ].Description:SetText( v.desc )
		self.Content[v.Category][ k ].Description:SetWrap( true )
		self.Content[v.Category][ k ].Description:SetTextColor( Color( 90, 90, 90, 255 ) )
		self.Content[v.Category][ k ].Description:SetWide( LabelOverallTextWidth )
		self.Content[v.Category][ k ].Description:SetAutoStretchVertical( true )
		self.Content[v.Category][ k ].Description.PerformLayout = function( pnl )
			self.Content[v.Category][ k ].Description:SetPos( LabelXPosition, 3 )
		end

		if v.type == "boolean" then
			self.Content[v.Category][ k ].Content = self.Content[v.Category][ k ]:Add( "DCheckBoxLabel" )
			self.Content[v.Category][ k ].Content:SetText( v.Name )
			self.Content[v.Category][ k ].Content:SetValue( v.default )
			if v.tags then self.Content[v.Category][ k ].Content.Tags = v.tags end
			self.Content[v.Category][ k ].Content.Label:SetFont( LabelFontName )
			self.Content[v.Category][ k ].Content.Label:SetTextColor( Color( 45, 45, 45, 255 ) )
			self.Content[v.Category][ k ].Content:SizeToContents()
				-- If our text is wrapping around (assume its only ONE wrap), and reposition our next item
			if LabelTextSizeWidth > LabelOverallTextWidth then
				self.Content[v.Category][ k ].Content:SetPos( LabelXPosition, 40 )--(400 / 2) + 3, 25 )
			else
				self.Content[v.Category][ k ].Content:SetPos( LabelXPosition, 25 )--(400 / 2) + 3, 25 )
			end
			self.Content[v.Category][ k ].Content.Button.Toggle = function( pnl )
				if not pnl:GetChecked() then
					pnl:SetValue( true )
				else
					pnl:SetValue( false )
				end
				RunConsoleCommand( "props_changesetting", k, tostring( pnl:GetChecked() ) )
				PROPKILL.Config[ k ].default = pnl:GetChecked()
			end
		elseif v.type == "integer" then
			self.Content[v.Category][ k ].Content = self.Content[v.Category][ k ]:Add( "DNumSlider" )
				-- If our text is wrapping around (assume its only ONE wrap), and reposition our next item
			if LabelTextSizeWidth > LabelOverallTextWidth then
				self.Content[v.Category][ k ].Content:SetPos( LabelXPosition, 30 )--(400 / 2) + 3, 25 )
			else
				self.Content[v.Category][ k ].Content:SetPos( LabelXPosition, 15 )--(400 / 2) + 3, 25 )
			end
			self.Content[v.Category][ k ].Content:SetWide( 400 )
			self.Content[v.Category][ k ].Content:SetDark( true )
			self.Content[v.Category][ k ].Content:SetMin( v.min or 1 )
			self.Content[v.Category][ k ].Content:SetMax( v.max or 50 )
			self.Content[v.Category][ k ].Content:SetDecimals( v.decimals or 0 )
			self.Content[v.Category][ k ].Content.Scratch:SetDecimals( v.decimals or 0 )
			if v.tags then self.Content[v.Category][ k ].Content.Tags = v.tags end
			--print("notch color ", self:GetSkin().colNumSliderNotch)
			--self.Content[v.Category][ k ].Content.Slider:SetNotchColor( Color( 255, 0, 0, 255 ) )
			self.Content[v.Category][ k ].Content:SetValue( v.default )
				-- Why was this here? It just fucks up if the min is 1
			--self.Content[v.Category][ k ].Content.Slider:SetSlideX( v.default / ( v.max or 50 ) )
			self.Content[v.Category][ k ].Content.Slider.OnMouseReleased = function( pnl )
				pnl:SetDragging( false )
				pnl:MouseCapture( false )

				RunConsoleCommand( "props_changesetting", k, math.Round( self.Content[v.Category][ k ].Content:GetValue(), v.decimals or 0 ) )
				PROPKILL.Config[ k ].default = math.Round( self.Content[v.Category][ k ].Content:GetValue(), v.decimals or 0 )
			end
			self.Content[v.Category][ k ].Content.Slider.Knob.OnMouseReleased = function( pnl, mousecode )
				RunConsoleCommand( "props_changesetting", k, math.Round( self.Content[v.Category][ k ].Content:GetValue(), v.decimals or 0 ) )
				PROPKILL.Config[ k ].default = math.Round( self.Content[v.Category][ k ].Content:GetValue(), v.decimals or 0 )

				return DLabel.OnMouseReleased( pnl, mousecode )
			end
			self.Content[v.Category][ k ].Content.TextArea.OnEnter = function( pnl )
				RunConsoleCommand( "props_changesetting", k, math.Round( pnl:GetValue(), v.decimals or 0 ) )
				PROPKILL.Config[ k ].default = math.Round( self.Content[v.Category][ k ].Content:GetValue(), v.decimals or 0 )
			end
			self.Content[v.Category][ k ].Content.PerformLayout = function( pnl )
                -- This will align the slider to the same position of the label, accounting for the added width of the "scratch"
				if LabelTextSizeWidth > LabelOverallTextWidth then
					pnl:SetPos( LabelXPosition - pnl.Scratch:GetWide(), 30 )
				else
					pnl:SetPos( LabelXPosition - pnl.Scratch:GetWide(), 15 )
				end
            end

		elseif v.type == "button" then
			self.Content[v.Category][ k ].Content = self.Content[v.Category][ k ]:Add( "DButton" )
				-- If our text is wrapping around (assume its only ONE wrap), and reposition our next item
			if LabelTextSizeWidth > LabelOverallTextWidth then
				self.Content[v.Category][ k ].Content:SetPos( LabelXPosition, 40 )
			else
				self.Content[v.Category][ k ].Content:SetPos( LabelXPosition, 25 )
			end
			self.Content[v.Category][ k ].Content:SetWide( 300 )
			self.Content[v.Category][ k ].Content:SetTall( 20 )
			self.Content[v.Category][ k ].Content:SetText( v.Name )
			if v.tags then self.Content[v.Category][ k ].Content.Tags = v.tags end
			self.Content[v.Category][ k ].Content.DoClick = function( pnl )
				RunConsoleCommand( "props_changesetting", k )
			end

		end

		--print(self.CatList:GetChild(0):GetChild(0).Header:GetText())
	end
end


function PANEL:FilterGamemodeConfigEntries( text )
	print("filtering...")

	for k, category in ipairs( self.CatList.pnlCanvas:GetChildren() ) do
			-- "item" is each DPanel found inside of the singular (per category) DIconLayout
		local FoundItem = false
		for id, item in ipairs( category:GetChild(1):GetChildren() ) do
			if string.find(string.lower(item.Description:GetText()), text, nil, true) then
				item:SetVisible( true )
				FoundItem = true
			elseif item.Content and item.Content.GetText and string.find(string.lower(item.Content:GetText()), text, nil, true) then
				item:SetVisible( true )
				FoundItem = true
				-- Tags are specifically for the menu to allow added searchability
				-- They're really only used for dnumsliders and buttons
			elseif item.Content and item.Content.Tags then
				local FoundTag = false
				for k,v in next, item.Content.Tags do
					if string.find(v, text, nil, true) then
						item:SetVisible( true )
						FoundItem = true
						FoundTag = true
						break
					end
				end
				if not FoundTag then
					item:SetVisible( false )
				end
			else
				item:SetVisible( false )
			end
			item:InvalidateLayout()
		end

			-- If we found any entry, open our DcategoryCollapsible even if it's collapsed
		if FoundItem then
			category:SetExpanded( true )
		end


		category:InvalidateLayout()
		category:GetChild(1):Layout()
	end
	self.CatList.pnlCanvas:InvalidateLayout()
	self.CatList:InvalidateLayout()
end

vgui.Register( "props_ConfigMenu", PANEL )
