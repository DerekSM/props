--[[
				  _________.__    .__                                  
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     / 
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/  
						\/      \/        \/\/         \/              

		Shared configuration file used throughout the gamemode.
]]--

	
--[[

*

* Configurables. These can all be modified in-game.

* Don't change here unless you want to break something.

*

--]]

AddConfigItem( "dead_spawnprops",
	{
	Name = "Dead Spawning",
	Category = "Player Management",
	default = false,
	type = "boolean",
	desc = "Toggle dead players spawning props.",
	tags = {"toggle"}
	}
)

AddConfigItem( "dead_removeprops",
	{
	Name = "Dead Removing",
	Category = "Player Management",
	default = true,
	type = "boolean",
	desc = "Toggle removing dead player's props.",
	tags = {"toggle"}
	}
)

AddConfigItem( "dead_removepropsdelay",
	{
	Name = "Dead Removing Delay",
	Category = "Player Management",
	default = 0,
	type = "integer",
	desc = "How long after a player's death until removal of their props.",
	}
)

AddConfigItem( "dead_respawndelay",
	{
	Name = "Respawn delay",
	Category = "Player Management",
	default = 0.1,
	min = 0,
	max = 60,
	decimals = 2,
	type = "integer",
	desc = "How long until dead players can respawn",
	}
)

AddConfigItem( "topplayers",
	{
	Name = "Top Players",
	Category = "Misc",
	default = 10,
	min = 0,
	max = 50,
	type = "integer",
	desc = "Limits the amount of top players there are.",
	}
)

AddConfigItem( "topprops",
	{
	Name = "Top Props",
	Category = "Misc",
	default = 15,
	min = 0,
	max = 50,
	type = "integer",
	desc = "Limits the amount of top props there are.",
	}
)

AddConfigItem( "toppropsdelay",
	{
	Name = "Top Props Session Delay",
	Category = "Misc",
	default = 25,
	min = 1,
	max = 300,
	type = "integer",
	desc = "How often (in seconds) the session's top spawned props should be refreshed"
	}
)

AddConfigItem( "toppropstotaldelay",
	{
	Name = "Top Props Total Delay",
	Category = "Misc",
	default = 240,
	min = 2,
	max = 600,
	type = "integer",
	desc = "How often (in seconds) the server's total top spawned props should be refreshed"
	}
)

AddConfigItem( "blockedmodels",
	{
	Name = "Block Blacklisted Models",
	Category = "Player Management",
	default = true,
	type = "boolean",
	desc = "Toggle spawning blocked models.",
	tags = {"toggle"}
	}
)

AddConfigItem( "battle_allowbattling",
	{
	Name = "Allow Player Battling",
	Category = "Battling",
	default = true,
	type = "boolean",
	desc = "Toggle allowing players to request battles",
	tags = {"fight"}
	}
)

AddConfigItem( "battle_defaultkills",
	{
	Name = "Battle Default Kills",
	Category = "Battling",
	default = 10,
	min = 1,
	max = 100,
	type = "integer",
	desc = "Default kills to end the fight if player doesn't supply chosen amount.",
	tags = {"fight"}
	}
)

AddConfigItem( "battle_minkills",
	{
	Name = "Battle Min Kills",
	Category = "Battling",
	default = 5,
	min = 3,
	max = 10,
	type = "integer",
	desc = "Minimum amount of kills a player can choose to fight.",
	tags = {"fight"}
	}
)

AddConfigItem( "battle_maxkills",
	{
	Name = "Battle Max Kills",
	Category = "Battling",
	default = 15,
	min = 10,
	max = 30,
	type = "integer",
	desc = "Maximum amount of kills a player can choose to fight.",
	tags = {"fight"}
	}
)

AddConfigItem( "battle_defaultprops",
	{
	Name = "Battle Default Prop Limit",
	Category = "Battling",
	default = 3,
	min = 1,
	max = 5,
	type = "integer",
	desc = "Default prop limit to use if player doesn't choose one.",
	tags = {"fight"}
	}
)

AddConfigItem( "battle_minprops",
	{
	Name = "Battle Min Props",
	Category = "Battling",
	default = 1,
	min = 1, 
	max = 3,
	type = "integer",
	desc = "Minimum prop limit a player can choose to fight with.",
	tags = {"fight"}
	}
)

AddConfigItem( "battle_maxprops",
	{
	Name = "Battle Max Props",
	Category = "Battling",
	default = 5,
	min = 3,
	max = 5,
	type = "integer",
	desc = "Maximum prop limit a player can choose to fight with.",
	tags = {"fight"}
	}
)

AddConfigItem( "battle_time",
	{
	Name = "Battle Time",
	Category = "Battling",
	default = 7.5,
	min = 2,
	max = 15,
	type = "integer",
	desc = "How long the battle should last in minutes",
	tags = {"fight"}
	}
)

AddConfigItem( "battle_pausetime",
	{
	Name = "Battle Pause Time",
	Category = "Battling",
	default = 20,
	min = 5,
	max = 120,
	type = "integer",
	desc = "How long a battle pause should last in seconds",
	tags = {"fight"}
	}
)

AddConfigItem( "battle_maxpauses",
	{
	Name = "Battle Max Pauses",
	Category = "Battling",
	default = 2,
	min = 0,
	max = 100,
	type = "integer",
	desc = "How many times a player can pause the fight",
	}
)

AddConfigItem("player_teamswitchdelay",
	{
	Name = "Team Switch Delay",
	Category = "Player Management",
	default = 5,
	min = 0,
	max = 300,
	type = "integer",
	desc = "How long before a player can switch teams again",
	}
)

AddConfigItem("player_canspawnragdolls",
	{
	Name = "Allow spawning ragdolls",
	Category = "Player Management",
	default = false,
	type = "boolean",
	desc = "Allow all players to spawn ragdolls",
	tags = {"toggle"}
	}
)


	-- There's still a game built-in chat delay. Nothing we can really do about that.
AddConfigItem("player_chatdelay",
	{
	Name = "Player Chat Delay",
	Category = "Player Management",
		-- Old versions of gamemode used to be 1.25 seconds
	default = 1,
	min = 0,
	max = 60,
	type = "integer",
	desc = "How long before a player can send another message",
	tags = {"msg"}
	}
)

AddConfigItem("player_chatratelimit",
	{
	Name = "Player Chat Anti-spam",
	Category = "Player Management",
	default = true,
	type = "boolean",
	desc = "Turn on rate limiting for players that spam the chat",
	tags = {"mute", "toggle"}
	}
)

AddConfigItem("player_chatratelimit_time",
	{
	Name = "Player Chat Spam Mute Time",
	Category = "Player Management",
		-- This is the base mute time. We actually add a random variable to this.
	default = 10,
	min = 0,
	max = 60,
	type = "integer",
	desc = "How long should a player be temporarily muted for after chat spam",
	}
)

AddConfigItem("sounds_playkillingsprees",
	{
	Name = "Play killing spree sounds",
	Category = "Misc",
	default = true,
	type = "boolean",
	desc = "Play killing spree sounds found in sh_init",
	tags = {"toggle"}
	}
)

--[[AddConfigItem( "battle_timespecified",
	{
	Name = "Battle Time Specifiable",
	Category = "Battling",
	default = true,
	type = "boolean",
	desc = "Allow players to select a time limit.",
	}
)

AddConfigItem( "battle_timespecifiedmin",
	{
	Name = "Battle Time Specifiable Max Time",
	Category = "Battling",
	default = 15,
	min = 5,
	max = 20,
	type = "integer",
	desc = "How long players can select the battle to last for at maximum",
	}
)]]

AddConfigItem( "battle_cooldown",
	{
	Name = "Battle Cooldown",
	Category = "Battling", 
	default = 2 * 60,
	min = 10,
	max = 15 * 60,
	type = "integer",
	desc = "How long after a battle until a player can start a new one (in seconds)",
	tags = {"fight"}
	}
)

AddConfigItem( "battle_invitecooldown",
	{
	Name = "Battle Invite Cooldown",
	Category = "Battling",
	default = 30,
	min = 5,
	max = 5 * 60,
	type = "integer",
	desc = "How long after a player sent a battle request can he send another (in seconds)",
	tags = {"fight"}
	}
)

AddConfigItem( "achievements_enabled",
	{
	Name = "Enable Player Achievements",
	Category = "Achievements",
	default = true,
	type = "boolean",
	desc = "Player achievements will be enabled. A map change may be required.",
	tags = {"toggle"}
	}
)


AddConfigItem( "achievements_save",
	{
	Name = "Save Player Achievements",
	Category = "Achievements",
	default = true,
	type = "boolean",
	desc = "Player achievements will persist across server restarts",
	tags = {"toggle"}
	}
)

AddConfigItem( "achievements_announce",
	{
	Name = "Announce Player Achievements",
	Category = "Achievements",
	default = true,
	type = "boolean",
	desc = "Player achievements will be announced in the chatbox upon completion",
	tags = {"toggle"}
	}
)

AddConfigItem( "achievements_playsound",
	{
	Name = "Play Player Achievements Sound",
	Category = "Achievements",
	default = true,
	type = "boolean",
	desc = "Players will emit a sound from themselves whenever they complete an achievement",
	tags = {"toggle"}
	}
)


AddConfigItem( "removedoors",
	{
	Name = "Remove Doors",
	Category = "Misc",
	default = nil,
	type = "button",
	desc = "Removes all doors on the map.",
	func = function( pl )
		if not SERVER then return end
			-- Because of the way we save and load doors, trying to do it again *does* appear to work but throws out a shit load of errors
		if REMOVEDDOORSALREADY then pl:Notify( NOTIFY_ERROR, 4, "Doors can only be removed once per map" ) return end
		
		for k,v in pairs( ents.GetAll() ) do
		
			local class = v:GetClass()
			
			if class == "func_door"
			or class == "prop_door_rotating" 
			or class == "func_door_rotating" then
				
				v:Remove()
				
			end
			
		end

		REMOVEDDOORSALREADY = true
	end,
	tags = {"button"}
	}
)

AddConfigItem( "respawndoors",
	{
	Name = "Respawn Doors",
	Category = "Misc",
	default = nil,
	type = "button",
	desc = "Respawns all doors on the map.",
	func = function( pl )
		if not SERVER then return end

		for k,v in next, PROPKILL.StoredDoorEntities or {} do
			local ent = ents.Create( v.Class )
			for key,value in next, v.KeyValues do
				ent:SetKeyValue( key, value )
			end
			ent:Spawn()
			ent:Activate()
			ent:Fire("unlock", "", 0)
		end

		PROPKILL.StoredEntities = {}
	end,
	tags = {"button"}
	}
)
