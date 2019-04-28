--[[
				  _________.__    .__                                  
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     / 
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/  
						\/      \/        \/\/         \/              

		Plays annoying sounds
]]--

if CLIENT then
	
	-- could i instead write a table so players don't have to request a url each time they send a message?
	-- yes.
	-- will i?
	-- no.
	
	CreateClientConVar( "props_PlayChatSounds", "1", true, true )
	local chatsounds = GetConVar( "props_PlayChatSounds" )
	
	local sound_delay = CurTime()
	
	hook.Add( "OnPlayerChat", "fdsf", function( pl, txt, team )
		if chatsounds:GetString() != "1" then return end
		if sound_delay > CurTime() then return end
		if math.random( 1, 5 ) == 2 or math.random( 1, 7 ) == 3 then return end

		txt = txt:lower()
		txt = txt:gsub( " ", "_" )
		
		http.Fetch( "http://shinycowservers.site.nfoservers.com/sounds/chat/" .. txt .. "/exists.html", 
			function( body, len )
				local explode = string.Explode( "\n", body )
				
				if len < 24 then
					
					num = explode[ 1 ]
					
					local url = "http://shinycowservers.site.nfoservers.com/sounds/chat/" .. txt .. "/" .. math.random( 1, tonumber(num) ) .. ".wav"
					--print( url )
					--sound.PlayURL( url, "noblock", function( station ) end )
					props_PlaySoundURL( url )
					
					sound_delay = CurTime() + 2.4 + ( explode[ 2 ] and tonumber( explode[ 2 ] ) or 0 )

				end
			end
		)
	end )
	
elseif SERVER then
	
	local function notifyChatSounds( pl )
		pl:ChatPrint( "Turn off chatsounds by typing props_PlayChatSounds 0 in console" )
	end
	
	timer.Create( "props_AnnounceChatSoundToggle", 240, 0, function()
		for k,v in pairs( player.GetAll() ) do
			notifyChatSounds( v )
		end
	end )
	
	hook.Add( "PlayerInitialSpawn", "props_NotifyChatSounds", function( pl )
		timer.CreatePlayer( pl, "props_chatsounds", 3, 1, function()
			if not IsValid( pl ) then return end
			
			notifyChatSounds( pl )
		end )
	end )
	
end
	
	