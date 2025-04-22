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
	
	--CreateClientConVar( "props_PlayChatSounds", "1", true, true )
	--local chatsounds = GetConVar( "props_PlayChatSounds" )
	AddClientConfigItem( "props_PlayChatSounds",
		{
		Name = "Play Chat Sounds",
		--Category = "Player Management",
		default = true,
		type = "boolean",
		desc = "Occasionally play trigger word chat sounds",
		}
	)

	-- Can find more here: https://wiki.facepunch.com/gmod/HL2_Sound_List
	local ChatSoundsList =
	{
	["hax"] =
		{
		["sounds"] = {"vo/npc/female01/hacks01.wav", "vo/npc/male01/hacks02.wav"},
		["delay"] = 3, -- in seconds
		},
	["gtfo"] =
		{
		["sounds"] = {"vo/npc/male01/gethellout.wav"},
		["delay"] = 7,
		},
	["wait"] =
		{
		["sounds"] = {"vo/trainyard/man_waitaminute.wav"},
		["delay"] = 4,
		},
	["rizz"] =
		{
		["sounds"] = {"https://www.myinstants.com//media/sounds/rizz-sound-effect.mp3"},	-- yes this even supports playing from URL
		["delay"] = 4,
		},
	["bruh"] =
		{
		["sounds"] = {"https://www.myinstants.com//media/sounds/movie_1.mp3"},
		["delay"] = 6,
		},
	}

	local BaseSoundDelay = 2.4 -- At least 2.4 seconds need to pass before we'll play another sound
	local sound_delay = CurTime()
	
	hook.Add( "OnPlayerChat", "fdsf", function( pl, txt, team )
		--if chatsounds:GetString() != "1" then return end
		if not PROPKILL.ClientConfig["props_PlayChatSounds"].currentvalue then return end
		if sound_delay > CurTime() then return end
		if math.random( 1, 4 ) == 2 or math.random( 1, 6 ) == 3 then return end
		if not ChatSoundsList[txt:lower()] then return end

		local Sounds = ChatSoundsList[txt:lower()]["sounds"]
		local ChosenSound = math.random(1, #Sounds)

		if string.find(Sounds[ChosenSound]:lower(), "http") then
			props_PlaySoundURL( Sounds[ChosenSound] )
		else
			surface.PlaySound( Sounds[ChosenSound] )
		end

		sound_delay = CurTime() + BaseSoundDelay + ChatSoundsList[txt:lower()]["delay"]
	end )
	
elseif SERVER then
	
	local function notifyChatSounds( pl )
		--pl:ChatPrint( "Turn off chatsounds by typing props_PlayChatSounds 0 in console" )
		pl:ChatPrint( "Turn off chatsounds by using the Client Config in the F4 menu" )
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
	
	
