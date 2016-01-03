local PANEL = {}

function PANEL:Init()
	
	self:SetSize( 130, 80 )
	self:SetPos( 3, 3 )
	self:MakePopup()
		-- later
	--self:SetKeyboardInputEnabled( true )
	--gui.EnableScreenClicker( true )
	
	self:SetTitle( "Battle Invitation" )
	
end

function PANEL:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, Color( 31, 31, 31, 230 ) )
end

vgui.Register( "props_BattleInvitation", PANEL, "DFrame" )