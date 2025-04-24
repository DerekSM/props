--[[
				  _________.__    .__
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     /
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/
						\/      \/        \/\/         \/

		Alternative scoreboard with a singular panel
]]--

local PANEL = {}

local draw = draw
local math = math

function PANEL:Init()
	self:SetSize( math.ceil( ScrW() * 0.8027 ), math.ceil( ScrH() * 0.9111 ) )
	self:SetPos( (ScrW() - math.ceil( ScrW() * 0.8027 )) / 2, 30 )
	self:MakePopup()
	self.Paint = function( pnl, w, h ) end

	self.MainHeader = self:Add( "DPanel" )
	--self.MainHeader:SetWide( 1300 )
	self.MainHeader:SetWide( math.ceil( ScrW() * 0.8027 ) )
	--self.MainHeader:SetTall( 60 )
	self.MainHeader:SetTall( math.ceil( ScrH() * 0.0666 ) )
	self.MainHeader:Dock( TOP )
	self.MainHeader.Paint = function( pnl, w, h ) end

	self.MainHeader.Text = self.MainHeader:Add( "DLabel" )
	self.MainHeader.Text:SetText( GetHostName() )
	self.MainHeader.Text:SetFont( "ScoreboardLarge" )
	self.MainHeader.Text:Dock( FILL )
	self.MainHeader.Text:SetTextColor( color_white )
	self.MainHeader.Text:SetContentAlignment( 5 )

		-- This is where the scores will parent to
	self.Content = self:Add( "DPanel" )
	--self.Content:SetWide( 1300 )
	self.Content:SetWide( math.ceil( ScrW() * 0.8027 ) )
	--self.Content:SetTall( 740 )
	self.Content:SetTall( math.ceil( ScrH() *0.8222 ) )
	self.Content:Dock( TOP )
	self.Content.Paint = function( pnl ) end

	self:Update()

end

function PANEL:Update()

	self.Content:Remove()

		-- This is where the scores will parent to
	self.Content = self:Add( "DPanel" )
	--self.Content:SetWide( 1300 )
	self.Content:SetWide( math.ceil( ScrW() * 0.8027 ) )
	--self.Content:SetTall( 740 )
	self.Content:SetTall( math.ceil( ScrH() *0.8222 ) )
	self.Content:Dock( TOP )
	self.Content.Paint = function( pnl )
        draw.RoundedBox( 0, 0, 0, pnl:GetWide(), pnl:GetTall(), Color( 31, 31, 31, 220 ) )
    end

	if PROPKILL.Battling then
		self.MainHeader.Text:SetTextColor( Color( 255, 255, 255, 0 ) )
	else
		self.MainHeader.Text:SetTextColor( color_white )
	end

    self.Content.ContentHeader = self.Content:Add( "DPanel" )
    self.Content.ContentHeader:SetWide( self.Content:GetWide() )
    self.Content.ContentHeader:SetTall( math.ceil( ScrH() * 0.0333 ) )
    self.Content.ContentHeader:Dock( TOP )
    self.Content.ContentHeader.Paint = function( pnl )
        draw.RoundedBox( 0, 0, 0, pnl:GetWide(), pnl:GetTall(), Color( 51, 51, 51, 255 ) )
    end

    local width = self.Content:GetWide()
        -- Found in cl_scoreboard.lua
	for k,v in next, InfoScoreboard do
        local id = v.id[ 1 ]

        surface.SetFont( "ScoreboardSmall" )
        if k == 1 then
            id = "Players (" .. #player.GetAll() .. ")"
            local scoresizew,scoresizeh = surface.GetTextSize( id )

            self.Content.ContentHeader[ k ] = self.Content.ContentHeader:Add( "DLabel" )
            self.Content.ContentHeader[ k ]:SetText( id )
            self.Content.ContentHeader[ k ]:SetFont( "ScoreboardSmall" )
            self.Content.ContentHeader[ k ]:SetTextColor( Color( 230, 230, 230, 255 ) )
            self.Content.ContentHeader[ k ]:SetPos( 5, self.Content.ContentHeader:GetTall() / 4 )
            self.Content.ContentHeader[ k ]:SetSize( width * v.space, scoresizeh )
        else
            local scoresizew,scoresizeh = surface.GetTextSize( id )
            local previousposx, previousposy = self.Content.ContentHeader[ k - 1 ]:GetPos()
            local previoussizew, previoussizeh = self.Content.ContentHeader[ k - 1 ]:GetSize()

            self.Content.ContentHeader[ k ] = self.Content.ContentHeader:Add( "DLabel" )
            self.Content.ContentHeader[ k ]:SetText( id )
            self.Content.ContentHeader[ k ]:SetFont( "ScoreboardSmall" )
            self.Content.ContentHeader[ k ]:SetTextColor( Color( 230, 230, 230, 255 ) )
            self.Content.ContentHeader[ k ]:SetPos( previoussizew + previousposx, self.Content.ContentHeader:GetTall() / 4 )
            self.Content.ContentHeader[ k ]:SetSize( width * v.space, scoresizeh )

                -- text wasn't centered below columns - now they will be.
            InfoScoreboard[ k ].text_sizew = scoresizew
            InfoScoreboard[ k ].text_posw = self.Content.ContentHeader[ k ]:GetPos()
        end
    end

    -- Content (player rows)
    self.Content.TeamContent = self.Content:Add( "DPanelList" )
    self.Content.TeamContent:EnableVerticalScrollbar()
    self.Content.TeamContent:SetWide( self.Content:GetWide() )
    self.Content.TeamContent:SetTall( self.Content:GetTall() )
    self.Content.TeamContent:Dock( TOP )
    self.Content.TeamContent.Paint = function() end

    for k,v in next, player.GetAll() do
        self.Content.TeamContent.PlayerRow = self.Content.TeamContent:Add( "props_playerrow_alt" )
        self.Content.TeamContent.PlayerRow:Setup( v )
        self.Content.TeamContent.PlayerRow:SetWide( self.Content:GetWide() )
        self.Content.TeamContent.PlayerRow:SetTall( math.ceil( ScrH() * 0.04111 ) )
        self.Content.TeamContent:AddItem( self.Content.TeamContent.PlayerRow )
    end

end


function PANEL:Think()

end

vgui.Register( "props_scoreboard_alt", PANEL )
