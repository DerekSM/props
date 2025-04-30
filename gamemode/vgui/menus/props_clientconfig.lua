--[[
				  _________.__    .__
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     /
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/
						\/      \/        \/\/         \/

		Clientside menu for changing clientside gamemode-specific configurations
]]--

local PANEL = {}

function PANEL:Init()

	self:SetPos( 15, 15 )
	self:SetSize( self:GetParent():GetWide() - 30, self:GetParent():GetTall() - 30 )

	self.ScrollPanel = self:Add("DScrollPanel")
	self.ScrollPanel:Dock( FILL )

	self.Content = self.ScrollPanel:Add( "DIconLayout" )
	self.Content:Dock( FILL )

	for k,v in next, PROPKILL.ClientConfig do
        -- Add a secondary Layout so we can manually add labels and sliders/checkboxes and group them together
        self.Content[ k ] = self.Content:Add( "DIconLayout" )
        --self.Content[ k ]:Dock( FILL )
        --self.Content[ k ]:SetSize( self:GetWide(), self.Content:GetTall() )
        self.Content[ k ]:SetSize( self:GetWide(), 50 )

        -- Add a DPanel to the secondary Layout so we can freely position our labels
        self.Content[ k ].FreedomPanel = self.Content[ k ]:Add( "DPanel" )
        self.Content[ k ].FreedomPanel.OwnLine = true
        self.Content[ k ].FreedomPanel:SetSize( self.Content[ k ]:GetWide(), 50 )--self.Content[ k ]:GetTall() )
        self.Content[ k ].FreedomPanel.Paint = function() end

        surface.SetFont( "props_HUDTextTiny" )
		local panelTextSize_w, panelTextSize_h = surface.GetTextSize( v.desc )

		local LabelXPosition = 135

		self.Content[ k ].Text = self.Content[ k ].FreedomPanel:Add( "DLabel" )
		self.Content[ k ].Text:SetPos( LabelXPosition, 3 )
		self.Content[ k ].Text:SetFont( "props_HUDTextTiny" )
		self.Content[ k ].Text:SetText( v.desc )
		self.Content[ k ].Text:SetTextColor( Color( 230, 230, 230, 255 ) )
		self.Content[ k ].Text:SizeToContents()

        if v.type == "integer" then
            self.Content[ k ].Content = self.Content[ k ].FreedomPanel:Add( "DNumSlider" )
            --self.Content[ k ].Content:SetPos( 135 - self.Content[ k ].Content.Scratch:GetWide(), 15 )
            self.Content[ k ].Content:SetWide( 400 )
            self.Content[ k ].Content:SetMin( v.min or 1 )
            self.Content[ k ].Content:SetMax( v.max or 50 )
            self.Content[ k ].Content:SetDecimals( v.decimals or 0 )
            self.Content[ k ].Content.Scratch:SetDecimals( v.decimals or 0 )
            self.Content[ k ].Content:SetValue( v.currentvalue )
            self.Content[ k ].Content.Slider.OnMouseReleased = function( pnl )
                pnl:SetDragging( false )
                pnl:MouseCapture( false )
            end
            self.Content[ k ].Content.Slider.Knob.OnMouseReleased = function( pnl, mousecode )
                if not v.listening then
                    ChangeClientConfigValue( k, math.Round( self.Content[ k ].Content:GetValue(), v.decimals or 0 ) )
                end

                return DLabel.OnMouseReleased( pnl, mousecode )
            end
            self.Content[ k ].Content.TextArea.OnEnter = function( pnl )
                if not v.listening then
                    ChangeClientConfigValue( k, math.Round( self.Content[ k ].Content:GetValue(), v.decimals or 0 ) )
                end
            end
            self.Content[ k ].Content.OnValueChanged = function( pnl, val )
                if not v.listening then return end

               ChangeClientConfigValue( k, math.Round( self.Content[ k ].Content:GetValue(), v.decimals or 0 ) )
            end
            self.Content[ k ].Content.PerformLayout = function( pnl )
                -- This will align the slider to the same position of the label, accounting for the added width of the "scratch"
                self.Content[ k ].Content:SetPos( LabelXPosition - self.Content[ k ].Content.Scratch:GetWide(), 15 )
            end
        elseif v.type == "boolean" then
            self.Content[ k ].Content = self.Content[ k ].FreedomPanel:Add( "DCheckBoxLabel" )
            self.Content[ k ].Content:SetText( v.Name )
			self.Content[ k ].Content:SetValue( v.currentvalue )
			self.Content[ k ].Content.Label:SetFont( "props_HUDTextTiny" )
			self.Content[ k ].Content.Label:SetTextColor( Color( 45, 45, 45, 255 ) )
			self.Content[ k ].Content:SizeToContents()
			self.Content[ k ].Content:SetPos( LabelXPosition, 25 )
			self.Content[ k ].Content.Button.Toggle = function( pnl )
				if not pnl:GetChecked() then
					pnl:SetValue( true )
				else
					pnl:SetValue( false )
				end
				ChangeClientConfigValue( k, pnl:GetChecked() )
			end
        end
    end

    self.configPanelResetButton = self:Add( "DButton" )
	self.configPanelResetButton:Dock( BOTTOM )
	self.configPanelResetButton:SetText( "Reset Settings to Default")
	self.configPanelResetButton.DoClick = function()
		for k,v in next, PROPKILL.ClientConfig do
            if v.currentvalue != nil and v.default != nil then
                if v.type == "boolean" then
                    self.Content[ k ].Content:SetValue( v.default )
                elseif v.type == "integer" then
                    self.Content[ k ].Content:SetValue( v.default )
                end
                ChangeClientConfigValue( k, v.default )
            end
        end
	end



end

vgui.Register( "props_ClientConfigMenu", PANEL )
