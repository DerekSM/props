concommand.Add( "props_menu", function()
	if IsValid( props_Menu ) then
		props_Menu:Remove()
		props_Menu = nil
		--gui.EnableScreenClicker( false )
	else
		props_Menu = vgui.Create( "props_MainMenu" )
	end
end )

hook.Add( "Move", "props_MenuDetectKeys", function()
	if IsValid( props_Menu ) then
		if input.WasKeyPressed( KEY_F2 ) or input.WasKeyPressed( KEY_F4 ) then	
			RunConsoleCommand( "props_menu" )
		end
	end
end )