PROPKILL = PROPKILL or {}
PROPKILL.Config = PROPKILL.Config or {}
PROPKILL.Colors = {}
PROPKILL.Colors["Blue"] = Color( 60,120,180,255 )

GM.Name = "Props"
GM.Author = "Shinycow"
DeriveGamemode( "sandbox" )

	-- put in propkill.config ?
GM.SecondsBetweenTeamSwitches = 5

TEAM_SPECTATOR = 1
TEAM_DEATHMATCH = 2
TEAM_RED = 3
TEAM_BLUE = 4

for k,v in pairs( team.GetAllTeams() ) do
	team.GetAllTeams()[ k ] = nil
end

team.SetUp( TEAM_SPECTATOR, "Spectator", Color( 210, 190, 30, 255 ) )
team.SetUp( TEAM_DEATHMATCH, "Deathmatch", Color( 127, 0, 255, 255 ) )
team.SetUp( TEAM_RED, "Red Team", Color( 132, 62, 62, 255 ) )
team.SetUp( TEAM_BLUE, "Blue Team", Color( 51, 51, 225, 255 ) )

	-- add the "spectator", "deathmatch", "red", etc
PROPKILL.ValidTeams = {}
PROPKILL.ValidTeams[ "1" ] = TEAM_SPECTATOR
PROPKILL.ValidTeams[ "spectator" ] = TEAM_SPECTATOR
PROPKILL.ValidTeams[ "deathmatch" ] = TEAM_DEATHMATCH
PROPKILL.ValidTeams[ "2" ] = TEAM_DEATHMATCH
PROPKILL.ValidTeams[ "3" ] = TEAM_RED
PROPKILL.ValidTeams[ "red" ] = TEAM_RED
PROPKILL.ValidTeams[ "4" ] = TEAM_BLUE
PROPKILL.ValidTeams[ "blue" ] = TEAM_BLUE

function AddConfigItem( id, tbl ) --default, type, description )
	--if not id or not default or not type then return end
	if not id then return end
	if not tbl then return end
	if not tbl.type then return end
	
	tbl.desc = tbl.desc or "No information available."
	
	if CLIENT and tbl.func then
		tbl.func = nil
	end
	
	if not tbl.Category then
		tbl.Category = "Unknown"
	end
	
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
         
       --[[ umsg.Start( "AddText", ply )
            umsg.Short( #arg )
			for _, v in next, arg do
                if ( type( v ) == "string" ) then
                    umsg.String( v )
                elseif ( type ( v ) == "table" ) then
                    umsg.Short( v.r )
                    umsg.Short( v.g )
                    umsg.Short( v.b )
                    umsg.Short( v.a )
                end
            end
        umsg.End( )]]
		
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
   --[[usermessage.Hook( "AddText", function( um )
        local argc = um:ReadShort( )
        local args = { }
        for i = 1, argc / 2, 1 do
			args[ #args + 1 ] = Color( um:ReadShort( ), um:ReadShort( ), um:ReadShort( ), um:ReadShort( ) )
            args[ #args + 1 ] = um:ReadString( )
        end
         
        chat.AddText( unpack( args ) )
    end )]]
	
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
	timer.Create( "props_ShowPropOwner", 0.5, 0, function()
		for k,v in pairs( player.GetAll() ) do
			
			if v.IsBot and v:IsBot() then continue end
			
			v.SeenProps = v.SeenProps or {}
			
			local trace = util.TraceLine( util.GetPlayerTrace( v ) )
			if trace.HitNonWorld then
				if IsValid(trace.Entity) and not trace.Entity:IsPlayer() and not v.SeenProps[ trace.Entity ] then--and trace.Entity.PKOwner then
					umsg.Start( "propkill_ShowOwner", v )
						umsg.Bool( true )
						--umsg.Entity( trace.Entity )
						--if trace.Entity.Owner then
						--	umsg.Entity( trace.Entity.Owner )
						--else
							umsg.Entity( trace.Entity )
							umsg.Bool( true )
						--end
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
	--LocalPlayer().pk_owner = NULL
	LocalPlayer().noowner = false
	
	usermessage.Hook("propkill_ShowOwner", function( um )
		local looking = um:ReadBool()
		if looking then
			LocalPlayer().LookingAtProp = um:ReadEntity()
			--print(LocalPlayer().pk_owner)
		else
			LocalPlayer().LookingAtProp = NULL
		end
		LocalPlayer().noowner = um:ReadBool() or false
	end)
end


-- top props

if SERVER then
	timer.Create( "props_RefreshTopProps", 15/*45*/, 0, function()
			-- no props have been spawned
		if table.Count( PROPKILL.TopPropsCache ) == 0 or #player.GetAll() == 0 then
			return
		end
		
		local tbl_sort = {}
		local output = {}
		
		for k,v in pairs( PROPKILL.TopPropsCache ) do
			tbl_sort[ #tbl_sort + 1 ] = { Model = k, Count = v }
		end
		
		table.SortByMember( tbl_sort, "Count" )
		
		local tbl_sort_new = {}
		for i=1,#tbl_sort do
			if i > PROPKILL.Config[ "topprops" ].default then break end
			
			tbl_sort_new[ i ] = { Model = tbl_sort[ i ].Model, Count = tbl_sort[ i ].Count }
		end
		
		PROPKILL.TopProps = tbl_sort_new
		
		net.Start( "props_UpdateTopProps" )
			net.WriteUInt( #PROPKILL.TopProps, 8 )
			for i=1,#PROPKILL.TopProps do
				net.WriteString( PROPKILL.TopProps[ i ].Model )
				net.WriteUInt( PROPKILL.TopProps[ i ].Count, 16 )
			end
		net.Broadcast()
	end )
	
	net.Receive( "props_ClearTopProps", function( len, pl )
		if not pl:IsSuperAdmin() then
			pl:Notify( NOTIFY_ERROR, 4, "Access denied!" )
			return
		end
		
		PROPKILL.TopPropsCache, PROPKILL.TopProps = {}, {}
		
		net.Start( "props_UpdateTopProps" )
			net.WriteUInt( 0, 8 )
		net.Broadcast()
		
		for k,v in pairs( player.GetAll() ) do
			if v:IsSuperAdmin() then
				v:ChatPrint( pl:Nick() .. " cleared the top props list." )
			end
		end
	end )
end

if CLIENT then
	net.Receive( "props_UpdateTopProps", function()
		local amt = net.ReadUInt( 8 )
					
		PROPKILL.TopProps = {}
		
		if amt == 0 then
			return
		end
		
		for i=1,amt do
			PROPKILL.TopProps[ i ] = { Model = net.ReadString(), Count = net.ReadUInt( 16 ) }
		end
	end )
end