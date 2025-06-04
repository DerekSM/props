props_HasOpenedMenuBefore = false
concommand.Add( "props_menu", function()
	if IsValid( props_Menu ) then
		props_Menu:Remove()
		props_Menu = nil
		--gui.EnableScreenClicker( false )
	else
		props_Menu = vgui.Create( "props_MainMenu" )
		props_HasOpenedMenuBefore = true
	end
end )

concommand.Add( "props_debug_fightinvite", function()
	LocalPlayer().fightInvites = LocalPlayer().fightInvites or {}

	local invite = vgui.Create( "props_BattleInvitation" )

	LocalPlayer().fightInvites[ #LocalPlayer().fightInvites + 1 ] = invite

	local oldinvite = LocalPlayer().fightInvites[ #LocalPlayer().fightInvites - 1 ]
	if not oldinvite then /*print("aw")*/ return end

	local oldpos_x, oldpos_y = oldinvite:GetPos()

	invite:SetPos( 3, invite:GetTall() + oldpos_y + 3 )
end )

concommand.Add("props_debug_showfight", function()
	if PROPKILL.Battling then return end

	props_HideBattlingHUD()
	props_ShowBattlingHUD()
end)
concommand.Add("props_debug_endfight", function()
	PROPKILL.Battling = false
	PROPKILL.BattlePaused = false
	PROPKILL.BattleTime = 0
	timer.Destroy( "props_Battlecountdown" )
	timer.Destroy( "destroypausetimer" )
	props_HideBattlingHUD()
end)

concommand.Add( "props_debug_fightresults", function()
	if SHOWRESULTS then
		SHOWRESULTS:Remove()
		SHOWRESULTS = nil
	else
		SHOWRESULTS = vgui.Create( "props_BattleResults" )
	end
end )

	-- those without falco's small scripts
concommand.Add( "falco_180", function()
	local a = LocalPlayer():EyeAngles()
	LocalPlayer():SetEyeAngles( Angle( a.p, a.y - 180, a.r ) )
end )

concommand.Add( "falco_180up", function()
	local a = LocalPlayer():EyeAngles()
	LocalPlayer():SetEyeAngles( Angle( a.p - a.p - a.p, a.y - 180, a.r ) )
	RunConsoleCommand( "+jump" )
	timer.Simple( 0.2, function() RunConsoleCommand("-jump") end )
end )
