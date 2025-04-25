--[[
				  _________.__    .__                                  
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     / 
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/  
						\/      \/        \/\/         \/              

		Shared initialization file
]]--

PROPKILL = PROPKILL or {}
PROPKILL.Config = PROPKILL.Config or {}
PROPKILL.Colors = {}
PROPKILL.Colors["Blue"] = Color( 60,120,180,255 )

GM.Name = "Props"
GM.Author = "Shinycow"
GM.Version = "1.3.3"
-- You (the server owner) should be fine to just remove the variable entirely if you don't want sounds
GM.KillingSprees =
{
	[5] = {"%s is on a Killing Spree!", "https://www.myinstants.com/media/sounds/halo-reach-killing-spree.mp3"},
	[10] = {"%s is Exterminating", "https://www.myinstants.com/media/sounds/extermination_pqUnqB8.mp3"},
	[15] = {"%s IS UNSTOPPABLE", "https://www.myinstants.com/media/sounds/unstoppable_1.mp3"},
	[25] = {"%s is a God!", "https://www.myinstants.com//media/sounds/f_godlike.mp3"},
	[50] = {"%s is playing against retards", "https://www.myinstants.com//media/sounds/bad-to-the-bone-meme.mp3"},
}
DeriveGamemode( "sandbox" )

TEAM_SPECTATOR = 1
TEAM_DEATHMATCH = 2
TEAM_RED = 3
TEAM_BLUE = 4

for k,v in next, team.GetAllTeams() do
	team.GetAllTeams()[ k ] = nil
end

team.SetUp( TEAM_SPECTATOR, "Spectator", Color( 210, 190, 30, 255 ) )
team.SetUp( TEAM_DEATHMATCH, "Deathmatch", Color( 127, 0, 255, 255 ) )
team.SetUp( TEAM_RED, "Red Team", Color( 164, 50, 50, 255 ) ) --132, 62, 62, 255 ) )
team.SetUp( TEAM_BLUE, "Blue Team", Color( 22, 22, 225, 255 ) )--51, 51, 225, 255 ) )

	-- Keys are available options in case a player wants to join a team manually through chat/console.
PROPKILL.ValidTeams = {}
PROPKILL.ValidTeams[ "1" ] = TEAM_SPECTATOR
PROPKILL.ValidTeams[ "spectator" ] = TEAM_SPECTATOR
PROPKILL.ValidTeams[ "deathmatch" ] = TEAM_DEATHMATCH
PROPKILL.ValidTeams[ "2" ] = TEAM_DEATHMATCH
PROPKILL.ValidTeams[ "3" ] = TEAM_RED
PROPKILL.ValidTeams[ "red" ] = TEAM_RED
PROPKILL.ValidTeams[ "4" ] = TEAM_BLUE
PROPKILL.ValidTeams[ "blue" ] = TEAM_BLUE

local player = player
local util = util

function AddConfigItem( id, tbl ) --default, type, description )
	if not id then return end
	if not tbl then return end
	if not tbl.type then return end
	if PROPKILL.Config[ id ] then
		print( "PROPKILL CONFIG ID '" .. id .. "' ALREADY EXISTS!" )
		return
	end
	
	tbl.desc = tbl.desc or "No information available."
	
	if CLIENT and tbl.func then
		tbl.func = nil
	end
	
	tbl.Category = tbl.Category or "Unknown"
	
	PROPKILL.Config[ id ] = tbl
end

/*------------------------------------------------------------------------------------------------
    PROPKILL.ChatText([ Player ply,] Colour colour, string text, Colour colour, string text, ... )
    Returns: nil
    In Object: None
    Part of Library: chat
    Available On: Server
------------------------------------------------------------------------------------------------*/
	// Credits to Overv.
if ( SERVER ) then
	util.AddNetworkString( "PK_AddText" )
    function PROPKILL.ChatText( ... )
		local arg = { ... }
        if ( type( arg[1] ) == "Player" ) then
			ply = arg[1] 
		end
		
		net.Start( "PK_AddText" )
			net.WriteUInt( #arg, 8 )
			for _, v in next, arg do
				if type( v ) == "string" then
					net.WriteString( v )
				elseif type( v ) == "table" then
					net.WriteUInt( v.r, 8 )
					net.WriteUInt( v.g, 8 )
					net.WriteUInt( v.b, 8 )
					net.WriteUInt( v.a, 8 )
				end
			end
		net.Send( ply )
    end
else
	net.Receive( "PK_AddText", function()
		local argc = net.ReadUInt( 8 )
		local args = {}
		for i = 1, argc / 2, 1 do
			args[ #args + 1 ] = Color( net.ReadUInt( 8 ), net.ReadUInt( 8 ), net.ReadUInt( 8 ), net.ReadUInt( 8 ) )
			args[ #args + 1 ] = net.ReadString()
		end
		
		chat.AddText( unpack( args ) )
	end )
end

	-- networking prop owner
	-- copypasted from old gamemode
if SERVER then
	timer.Create( "props_ShowPropOwner", 0.4, 0, function()
		for k,v in next, player.GetHumans() do

			v.SeenProps = v.SeenProps or {}

			local trace = util.TraceLine( util.GetPlayerTrace( v ) )
			if trace.HitNonWorld then
				if IsValid(trace.Entity) and not trace.Entity:IsPlayer() and not v.SeenProps[ trace.Entity ] then
					umsg.Start( "propkill_ShowOwner", v )
						umsg.Bool( true )
							umsg.Entity( trace.Entity )
							umsg.Bool( true )
					umsg.End()

					v.SeenProps[ trace.Entity ] = true
					v.SeenProps[ "prop_physics" ] = true
				end
			else
				if v.SeenProps[ "prop_physics" ] then
					umsg.Start( "propkill_ShowOwner", v )
						umsg.Bool( false )
					umsg.End()

					v.SeenProps = {}
				end
			end

		end
	end )
end

if CLIENT then
	LocalPlayer().LookingAtProp = NULL
	LocalPlayer().noowner = false
	
	usermessage.Hook("propkill_ShowOwner", function( um )
		local looking = um:ReadBool()
		if looking then
			LocalPlayer().LookingAtProp = um:ReadEntity()
		else
			LocalPlayer().LookingAtProp = NULL
		end
		LocalPlayer().noowner = um:ReadBool() or false
	end)
end


-- top props

if SERVER then
	-- Hack to let the new config option work
	timer.Simple(1, function()
		timer.Create( "props_RefreshTopPropsSession", PROPKILL.Config["toppropsdelay"].default, 0, function()
				-- no props have been spawned
			if table.IsEmpty( PROPKILL.TopPropsCache ) or #player.GetAll() == 0 then
				return
			end

			local sorted = {}
			local SortedCount = 0
			local output = {}

			for k,v in next, PROPKILL.TopPropsCache do
				SortedCount = SortedCount + 1
				sorted[ SortedCount] = { Model = k, Count = v }
			end

			table.SortByMember( sorted, "Count" )

			for i=1,SortedCount do
				if i > PROPKILL.Config[ "topprops" ].default then
					SortedCount = i - 1
					break
				end

				output[ i ] = { Model = sorted[ i ].Model, Count = sorted[ i ].Count }
			end

			PROPKILL.TopPropsSession = output

			net.Start( "props_UpdateTopPropsSession" )
				net.WriteUInt( SortedCount, 6 )
				for i=1,SortedCount do
					net.WriteString( PROPKILL.TopPropsSession[ i ].Model )
					net.WriteUInt( PROPKILL.TopPropsSession[ i ].Count, 14 )
				end
			net.Broadcast()
		end )
	end )
	hook.Add("OnSettingChanged", "ListenForTopPropsSetting", function( pl, setting )
		if setting == "toppropsdelay" then
			timer.Adjust("props_RefreshTopPropsSession", PROPKILL.Config["toppropsdelay"].default)
		end
	end)
	
		-- Refactored code is 30-50% faster than before.
	function props_RefreshTopPropsTotal()
		local TotalCopy = {}
		local SessionCopy = {}
		local Output = {}

			-- Convert the numeric table into a dictionary for easy comparison
		for k,v in next, PROPKILL.TopPropsSession do
			SessionCopy[v.Model] = v.Count
		end

			-- Convert the numeric table into a dictionary for easy comparison
		for k,v in next, PROPKILL.TopPropsTotal do
			TotalCopy[v.Model] = v.Count
		end

			-- If we have the same model we can just add them together
			-- If not, don't worry about it.
		for k,v in next, TotalCopy do
			if SessionCopy[ k ] != nil then
				TotalCopy[ k ] = TotalCopy[k] + SessionCopy[k]
			end
		end

			-- Convert the dictionary back to a numerical table, and we'll reuse SessionCopy table
		SessionCopy = {}
		local SessionCopyCount = 0
		for k,v in next, TotalCopy do
			SessionCopyCount = SessionCopyCount + 1
			SessionCopy[SessionCopyCount] = {Model = k, Count = v}
		end
		table.SortByMember(SessionCopy, "Count")
		
		for i=1,SessionCopyCount do
				-- Ideally no more than 50
			if i > math.max( 50, PROPKILL.Config[ "topprops" ].default ) then break end
			
			Output[ i ] = { Model = SessionCopy[ i ].Model, Count = SessionCopy[ i ].Count }
		end
		
		PROPKILL.TopPropsTotal = Output
		file.Write( "props/topprops.txt", pon.encode( PROPKILL.TopPropsTotal ) )
		
		net.Start( "props_UpdateTopPropsTotal" )
			net.WriteUInt( math.Clamp( #PROPKILL.TopPropsTotal, 0, PROPKILL.Config[ "topprops" ].default ), 6 )

			for i=1,math.Clamp( #PROPKILL.TopPropsTotal, 0, PROPKILL.Config[ "topprops" ].default ) do
				net.WriteString( PROPKILL.TopPropsTotal[ i ].Model )
				net.WriteUInt( PROPKILL.TopPropsTotal[ i ].Count, 18 )
			end
		net.Broadcast()
	end
	timer.Create( "props_RefreshTopPropsTotal", 240, 0, function() props_RefreshTopPropsTotal() end )
	
	function props_SendTopPropsTotal( pl )
		if #PROPKILL.TopPropsTotal == 0 then return end

		net.Start( "props_UpdateTopPropsTotal" )
			net.WriteUInt( math.Clamp( #PROPKILL.TopPropsTotal, 0, PROPKILL.Config[ "topprops" ].default ), 6 )
			for i=1,math.Clamp( #PROPKILL.TopPropsTotal, 0, PROPKILL.Config[ "topprops" ].default ) do
				net.WriteString( PROPKILL.TopPropsTotal[ i ].Model )
				net.WriteUInt( PROPKILL.TopPropsTotal[ i ].Count, 18 )
			end
		net.Send( pl or player.GetHumans() )
	end

end

if CLIENT then
	net.Receive( "props_UpdateTopPropsSession", function()
		local amt = net.ReadUInt( 6 )
					
		PROPKILL.TopPropsSession = {}
		
		if amt == 0 then
			return
		end
		
		for i=1,amt do
			PROPKILL.TopPropsSession[ i ] = { Model = net.ReadString(), Count = net.ReadUInt( 14 ) }
		end
		
		hook.Call( "props_UpdateTopPropsSession", GAMEMODE )
	end )
	
	net.Receive( "props_UpdateTopPropsTotal", function()
		local amt = net.ReadUInt( 6 )
		
		PROPKILL.TopPropsTotal = {}
		
		if amt == 0 then return end
		
		for i=1,amt do
			PROPKILL.TopPropsTotal[ i ] = { Model = net.ReadString(), Count = net.ReadUInt( 18 ) }
		end
		
		hook.Call( "props_UpdateTopPropsTotal", GAMEMODE )
	end )
end
