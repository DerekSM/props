--[[
				  _________.__    .__
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     /
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/
						\/      \/        \/\/         \/

		Combat Achievements
]]--

--[[Add Combat Achievements
    - Announce to players when someone achieves one
    - Add chat command to display to everyone how many achievements you've personally done.
    - Have F4 menu tab with each achievement, along with percentage of players that have gotten it
    - Example achievements
        -D "Fly Swatter" - Headsmash 5 players in one session.
        -D "You spin me right round" - Kill a player with a prop doing a fast rotation
        -D "360 noscope" - Kill a player after turning 360+ degrees after releasing a prop
        -D "Slow is smooth, smooth is.." - Kill a player while your wheelspeed <=30
        -D "Toy maker" - Kill a player with a small object. Think like a hula doll model.
        -D "No life" - Be on the server for two consecutive hours.
        - "I'll be a good boy" - Kill ten players consecutively without triggering the antinoob system.
        -D "Smurf" - Reset your stats at least once
        -D "Killing spree" - Kill five players without dying yourself.
        -D "Midget Mania" - Kill three players while crouching.
        -D "I think I can fly" - Stay actively moving and airborne for 20 seconds
        -D "Nerfed" - Kill three players in a row without freezing any props and while not dying yourself.
        -D "I'll take the low ground" - Kill five players while on the ground.
        -D "Stand your ground" - Kill two players from the same spot.
        -D "Two players, one prop" - Kill two players with the same prop.
        -D "What was that?!" - Kill a player by a flyby.
        - "Spawncamper" - Kill a player right outside antinoob's perimeter
        -D "The recluse" - Play 10 minutes without sending any messages
        -D "The Leader" - Become the leader at least once
        - "Follow Me" - Maintain being the leader for five minutes
        - "Vengeance" - Kill the player that killed you.
        - "Domination" - Kill the same player five times without them killing you
        -D "First Blood" - Be the first to kill a player for the current server's session
        - "Baby(god) Killer" - Kill a player while your babygod is still active
        -D "See you tomorrow" - Join the server two days in a row
        -D "The Completionist" - Unlock every achievement (that were made at the time of unlocking)
        -D "I know I can fly" - Stay actively moving and airborne for 60 seconds
        -D "Stomped" - Jump onto a player's head from at least a 2 story height
        -D "Cancel my fall" - "Land in the middle of a frozen prop thats touching the ground while falling fast"
        -D "Repetition is key" - "Using only one model, kill five players"
        -D "Double Whammy" - "Kill a player with the kill being registered as BOTH a longshot AND a headsmash"
        -D "Cool guys don't look at prop kills" - "Kill a player while being turned away from them"
        - "Quit hitting yourself" - "Kill a player with their own prop"
        -D "I Love Longshots" - "Perform 20 longshots (not required to be in one session)"
        -D "720 noscope" - Kill a player after turning 720+ degrees after releasing a prop
        -D "Go clip yourself" - "Push yourself through a wall"
        - "15 in 15" - "Perform 15 flybys in 15 minutes"
        - "Random" - "Complete a random number of combined achievements during a single session."
            - E.g "14 kills and all of them have to be crouching flybys" or "7 kills they all have to qualify for 'Toy Maker'"
            - Or "Kill 5 players without dying and while looking away from them"
            - This random achievement would be ranked 5/5 because the only way to find out is by bruteforce or pure luck.
            - Players can already unlock the other achievements. This is an entirely different achievement.
        -D "The Regular" - "Join the server five times"
]]
PROPKILL.CombatAchievements = PROPKILL.CombatAchievements or {}
PROPKILL.CombatAchievementsCount = 0

LISTENER_SERVER = 0
LISTENER_CLIENT = 1
LISTENER_SHARED = 2

--http://lua-users.org/wiki/MetatableEvents
local AchievementMeta = {}
AchievementMeta.__index = AchievementMeta

function PROPKILL.RegisterCombatAchievement( tblAchievements, ... )
    if not tblAchievements.id then print("reeeeeee") return end
    tblAchievements.datatable = {}

    setmetatable(tblAchievements, AchievementMeta)

        -- If autorefresh, make sure we reset our values that shouldn't change
    if PROPKILL.CombatAchievements[ tblAchievements.id ] then
        tblAchievements:SetCompletionRate( PROPKILL.CombatAchievements[tblAchievements.id]:GetCompletionRate() )
        if CLIENT and PROPKILL.CombatAchievements[ tblAchievements.id ].localplayerProgress then
            tblAchievements.localplayerProgress = PROPKILL.CombatAchievements[ tblAchievements.id ].localplayerProgress
        end
    end

        -- Be able to reference our new tables
    PROPKILL.CombatAchievements[ tblAchievements.id ] = tblAchievements
    PROPKILL.CombatAchievementsCount = PROPKILL.CombatAchievementsCount + 1
    return tblAchievements
end

function PROPKILL.GetCombatAchievements()
    return PROPKILL.CombatAchievements
end

function PROPKILL.GetCombatAchievement( id )
    return PROPKILL.CombatAchievements[ id ]
end

function PROPKILL.GetCombatAchievementByUniqueID( str_identifier )
    if not str_identifier then return nil, nil end

    return PROPKILL.CombatAchievements[ str_identifier ]
end
PROPKILL.GetAchievementByUniqueID = PROPKILL.GetCombatAchievementByUniqueID

function PROPKILL.GetCombatAchievementByFancyTitle( str_identifier )
    if not str_identifier then return nil, nil end

    for k,v in next, PROPKILL.GetCombatAchievements() do
        if v:GetFancyTitle() == str_identifier then
            return v
        end
    end
end
PROPKILL.GetAchievementByFancyTitle = PROPKILL.GetCombatAchievementByFancyTitle

function PROPKILL.DebugUnlockAchievement( pl )
    for k,v in next, PROPKILL.GetCombatAchievements() do
        if k != "completionist" and k != "crouching" then
            v:UnlockAchievement( pl )
        end
    end
end

function AchievementMeta:GetUniqueID()
    return self.id
end

function AchievementMeta:GetFancyTitle()
    return self.title
end

-- These two functions, GetData and SetData are for holding data that we want to store for the session
-- We can use it for say, keeping track of semi-unique events.

function AchievementMeta:GetData( keyname )
    return self.datatable[keyname]
end

function AchievementMeta:SetData( keyname, data )
    self.datatable[keyname] = data
end


function AchievementMeta:GetAllPlayerData( pl )
    return pl.AchievementData[ self:GetUniqueID() ].datatable
end

function AchievementMeta:GetPlayerData( pl, keyname, defaultvalue)
    return pl.AchievementData[ self:GetUniqueID() ].datatable[keyname] or defaultvalue
end

-- Do not save the datatable to file.
function AchievementMeta:SetPlayerData( pl, keyname, data )
    pl.AchievementData[ self:GetUniqueID() ].datatable[keyname] = data
end

function AchievementMeta:AddListener( hook_listener, listening_type, callback )
    if (listening_type == LISTENER_SERVER or listening_type == LISTENER_SHARED) and SERVER then
       -- print("who am i", self, hook_listener )
        --print(self:GetUniqueID())
        hook.Add( hook_listener, "propsCA_" .. self:GetUniqueID(), function( ... )
            if not PROPKILL.Config["achievements_enabled"].default then return end

            callback( self, ... )
        end )
    end

    if (listening_type == LISTENER_CLIENT or listening_type == LISTENER_SHARED) and CLIENT then
        --print("client or shared hook")
        hook.Add( hook_listener, "propsCA_" .. self:GetUniqueID(), function( ... )
            if not PROPKILL.Config["achievements_enabled"].default then return end

            callback( self, ... )
        end )
    end
end


function AchievementMeta:GetGoal()
    return self.goal or 1
end

function AchievementMeta:SetGoal( goalnumber )
    self.goal = goalnumber
end

function AchievementMeta:GetDescription()
    return self.description or "No entry"
end

function AchievementMeta:GetCompletionRate()
    return self.numCompletions or 0
end

function AchievementMeta:SetCompletionRate( num )
    self.numCompletions = num
    if PROPKILL.CombatAchievements[ self:GetUniqueID() ]:GetCompletionRate() != num then
            -- Added because just the above only affects the AchievementMeta table, while the below affects referencing outside this file
            -- Seems to only be an issue with autorefresh (and those with :AddProgress)
        PROPKILL.CombatAchievements[ self:GetUniqueID() ]:SetCompletionRate( num )
    end
end

function AchievementMeta:UnlockAchievement( pl, b_clientinitialJoin )
    if not PROPKILL.Config["achievements_enabled"].default then return end
    local HasUnlocked, Progress = self:GetProgression( pl )
    if HasUnlocked then
        if SERVER then
            --pl:ChatPrint("Can't unlock: Already unlocked " .. self:GetFancyTitle())
        end
        return
    end

    pl.AchievementData[ self:GetUniqueID() ].Unlocked = true
    pl.AchievementData[ self:GetUniqueID() ].UnlockedTime = os.time()
        -- This bool is only set in cl_achievements.lua when we get our initial data
    if not b_clientinitialJoin then
        self:SetCompletionRate( self:GetCompletionRate() + 1 )
    end
    hook.Run("OnAchievementUnlocked", pl, self:GetUniqueID(), self:GetFancyTitle())
end

    -- This is just for debugging
function AchievementMeta:LockAchievement( pl )
    pl.AchievementData = pl.AchievementData or {}
    pl.AchievementData[ self:GetUniqueID() ] = {Unlocked=false,Progress=0,datatable={}}

    if not SERVER then return end

    self:SetCompletionRate( math.max(self:GetCompletionRate() - 1, 0) )
    local AchievementID = self:GetUniqueID()

    Props_SendPlayerAllAchievementsCompleted( pl )
        -- Broadcast to the rest of the players the percentage of players completed
        -- If we want to get really tricky we
    Props_SendPlayerAchievementPercentages( player.GetHumans(), AchievementID )
    pl:SaveCombatAchievements()
    props_SaveCombatAchievements()

    if self.type == "Counter" then
        Props_UpdatePlayerAchievementProgress( pl, self:GetUniqueID(), 0 )
    end

        -- Still announce it, but only to the player.
    pl:ChatPrint("You've re-locked achievement " .. self:GetFancyTitle())
end

function AchievementMeta:GetProgression( pl )
    pl.AchievementData = pl.AchievementData or {}
    pl.AchievementData[ self:GetUniqueID() ] = pl.AchievementData[ self:GetUniqueID() ] or {Unlocked=false,Progress=0,datatable={}}

    --print("printing achievement data tbl")
    --PrintTable(pl.AchievementData)
    return pl.AchievementData[ self:GetUniqueID() ].Unlocked, pl.AchievementData[ self:GetUniqueID() ].Progress
end

function AchievementMeta:AddProgression( pl )
    if not PROPKILL.Config["achievements_enabled"].default then return end
    local HasUnlocked, Progress = self:GetProgression( pl )
    if HasUnlocked then
       -- pl:ChatPrint("You've already unlocked " .. self:GetFancyTitle())
        return
    end
    if not self:GetGoal() then
        print("No goal provided: You should be using UnlockAchievement")
        self:UnlockAchievement( pl )
        return
    end

    --pl:ChatPrint("We're adding to your progression - " .. self:GetFancyTitle() .. ". Current:" .. Progress + 1)

    local NewProgress = pl.AchievementData[ self:GetUniqueID() ].Progress + 1
    pl.AchievementData[ self:GetUniqueID() ].Progress = NewProgress
    pl.AchievementData[ self:GetUniqueID() ].LastProgressed = os.time()

    if NewProgress >= self:GetGoal() then
        self:UnlockAchievement( pl )
    else
        if self.type == "Counter" then
            Props_UpdatePlayerAchievementProgress( pl, self:GetUniqueID(), NewProgress )
        end
    end

    hook.Run("OnAchievementProgressed", pl, self:GetUniqueID(), self:GetFancyTitle(), NewProgress)
end

function AchievementMeta:ResetProgression( pl )
    local HasUnlocked, Progress = self:GetProgression( pl )
    if HasUnlocked then
        --pl:ChatPrint("Can't reset, already unlocked " .. self:GetFancyTitle())
        return
    end

    pl.AchievementData[ self:GetUniqueID() ].Progress = 0
    pl.AchievementData[ self:GetUniqueID() ].LastProgressed = nil
    pl.AchievementData[ self:GetUniqueID() ].datatable = {}

    if self.type == "Counter" then
        Props_UpdatePlayerAchievementProgress( pl, self:GetUniqueID(), 0 )
    end

    hook.Run("OnAchievementProgressReset", pl, self:GetUniqueID(), self:GetFancyTitle())
end

function AchievementMeta:GetPlayerLastProgression( pl )
    local HasUnlocked, Progress = self:GetProgression( pl )
    if HasUnlocked then
        --pl:ChatPrint("Can't reset, already unlocked " .. self:GetFancyTitle())
        return nil
    end

    if self.type != "Counter" then return nil end
    if not pl.AchievementData or not pl.AchievementData[ self:GetUniqueID() ] then return nil end

    return pl.AchievementData[ self:GetUniqueID() ].LastProgressed
end











-- To consider how we want to format the creation of CA's...
-- We need a way to reference them both in code and in storage
-- We need to consider modular CA's that may be removed/added when base gamemode modules are removed/added

local CA_SWATTER = PROPKILL.RegisterCombatAchievement(
    {
        id = "headsmash_5", -- Don't change
        title = "Fly Swatter",
        description = "Headsmash 5 players in one session.",
        type = "Counter",
        save_progression = false,   -- Should we save their progress over restarts? Defaults to not saving.
        difficulty = 2,  -- Still working out if I want to even include a difficulty paramater. 1 thru 5?
    }
)
CA_SWATTER:SetGoal( 5 )
CA_SWATTER:AddListener( "props_PlayerHeadsmashChanged", LISTENER_SERVER, function( achievement, pl, oldsmash, newsmash )
    if newsmash > oldsmash then
        achievement:AddProgression( pl )
    end
end )
    -- Since headsmashes are recorded to the player's file and this is a session based achievement
CA_SWATTER:AddListener( "props_PlayerDataLoaded", LISTENER_SERVER, function( achievement, pl )
    achievement:ResetProgression( pl )
end )


local CA_SPINNER = PROPKILL.RegisterCombatAchievement(
    {
        id = "rotationalprop",
        title = "You spin me right round",
        description = "Kill a player with a prop doing a fast rotation",
        type = "Trigger",
        difficulty = 1
    }
)
CA_SPINNER:AddListener( "props_PropKilled", LISTENER_SERVER, function( achievement, pl, prop )
    if prop:GetClass() != "prop_physics" or not prop.Owner then return end
    if prop.Owner == pl then return end

        -- RPM of the prop. Shamelessly borrowed from the wiki.
    if math.abs(prop:GetPhysicsObject():GetAngleVelocity():Dot( Vector(0, 0, 1) ) / 6) > 95 then
        achievement:UnlockAchievement( prop.Owner )
    end
end )


CA_AIRBORNE = PROPKILL.RegisterCombatAchievement(
    {
        id = "airborne",
        title = "I think I can fly",
        description = "Stay actively moving and airborne for 20 seconds",
        type = "Time",
        difficulty = 3
    }
)
CA_AIRBORNE:SetGoal( 20 )
CA_AIRBORNE:AddListener( "FinishMove", LISTENER_SERVER, function( achievement, pl, movedata )
    if achievement:GetProgression( pl ) then return end

    achievement:SetPlayerData( pl, "MovementVelocity", movedata:GetVelocity() )
    timer.CreatePlayerIfNotExists( pl, "props_CombatAchievementFlyer", 1, 0, function()
        if pl:GetGroundEntity() == Entity(0) or pl:WaterLevel() > 0
        or not pl:Alive() or pl:Team() == TEAM_SPECTATOR then
            achievement:ResetProgression( pl )
            return
        end

            -- We WOULD use :Velocity but that returns 0,0,0 when we are walking on props
            -- Edit: Entity:Veloicty returns 0,0,0 on props, but movedata:Velocity doesn't.
            -- Still, we already made this so we'll keep it mostly the same.
        local OldFlyerPos = achievement:GetPlayerData(pl, "OldFlyerPos", pl:GetPos())

            -- Pos = 180*180
            -- Velocity = 520*520 (Slightly higher than anyone is able to run)
        if (OldFlyerPos:DistToSqr( pl:GetPos() ) < 32400) or (achievement:GetPlayerData( pl, "MovementVelocity", pl:GetVelocity() ):LengthSqr() < 270400) then
            achievement:ResetProgression( pl )
        else
            achievement:AddProgression( pl )
        end
        achievement:SetPlayerData( pl, "OldFlyerPos", pl:GetPos() )
    end )
end )
CA_AIRBORNE:AddListener( "OnAchievementUnlocked", LISTENER_SERVER, function( achievement, pl, uniqueid, fancytitle )
    if achievement:GetUniqueID() == uniqueid then
        timer.DestroyPlayer( pl, "props_CombatAchievementFlyer" )
    end
end )
CA_AIRBORNE:AddListener( "OnPlayerJump", LISTENER_SERVER, function( achievement, pl, speed )
    achievement:ResetProgression( pl )
end )


    -- This is purposefully made doable by walking on props.
    -- Maybe make a "I think I can fly 2"? "Frequent Flyer" ?
    -- That would be way harder for the player; essentially you have to do a bunch of back and forth prop surfing
local CA_AIRBORNE2 = PROPKILL.RegisterCombatAchievement(
    {
        id = "airborne2",
        title = "I know I can fly",
        description = "Stay actively moving and airborne for 60 seconds",
        type = "Time",
        difficulty = 5
    }
)
CA_AIRBORNE2:SetGoal( 60 )
CA_AIRBORNE2:AddListener( "FinishMove", LISTENER_SERVER, function( achievement, pl, movedata )
    if achievement:GetProgression( pl ) then return end

    achievement:SetPlayerData( pl, "MovementVelocity", movedata:GetVelocity() )
    timer.CreatePlayerIfNotExists( pl, "props_CombatAchievementFlyer2", 1, 0, function()
        if pl:GetGroundEntity() == Entity(0) or pl:WaterLevel() > 0
        or not pl:Alive() or pl:Team() == TEAM_SPECTATOR then
            achievement:ResetProgression( pl )
            return
        end
            -- We WOULD use :Velocity but that returns 0,0,0 when we are walking on props
            -- Edit: Entity:Veloicty returns 0,0,0 on props, but movedata:Velocity doesn't.
            -- Still, we already made this so we'll keep it mostly the same.
        local OldFlyerPos = achievement:GetPlayerData(pl, "OldFlyerPos", pl:GetPos())

            -- Pos = 180*180
            -- Velocity = 520*520 (Slightly higher than anyone is able to run)
        if (OldFlyerPos:DistToSqr( pl:GetPos() ) < 32400) or (achievement:GetPlayerData( pl, "MovementVelocity", pl:GetVelocity() ):LengthSqr() < 270400) then
            achievement:ResetProgression( pl )
        else
            achievement:AddProgression( pl )
        end
        achievement:SetPlayerData( pl, "OldFlyerPos", pl:GetPos() )
    end )
end )
CA_AIRBORNE2:AddListener( "OnAchievementUnlocked", LISTENER_SERVER, function( achievement, pl, uniqueid, fancytitle )
    if achievement:GetUniqueID() == uniqueid then
        timer.DestroyPlayer( pl, "props_CombatAchievementFlyer2" )
    end
end )
CA_AIRBORNE2:AddListener( "OnPlayerJump", LISTENER_SERVER, function( achievement, pl, speed )
    achievement:ResetProgression( pl )
end )


local CA_FIRSTBLOOD = PROPKILL.RegisterCombatAchievement(
    {
        id = "firstblood",
        title = "First Blood",
        description = "Be the first to kill a player for the current server's session",
        type = "Trigger",
        difficulty = 4
    }
)
CA_FIRSTBLOOD:AddListener( "props_PlayerKillstreakChanged", LISTENER_SERVER, function( achievement, killer, oldkillstreak, newkillstreak )
    if achievement:GetData("HasFirstBlood") then return end
    achievement:UnlockAchievement( killer )
    achievement:SetData("HasFirstBlood", true)
end )


local CA_WHEELSPEED = PROPKILL.RegisterCombatAchievement(
    {
        id = "wheelspeed1",
        title = "Slow is smooth, smooth is..",
        description = "Kill a player while your wheelspeed <=30",
        type = "Trigger",
        difficulty = 1
    }
)
CA_WHEELSPEED:AddListener( "props_PropKilled", LISTENER_SERVER, function( achievement, pl, prop )
    if prop:GetClass() != "prop_physics" or not prop.Owner then return end
    if prop.Owner == pl then return end
    if achievement:GetProgression( prop.Owner ) then return end

    if prop.Owner:GetInfoNum("physgun_wheelspeed", 1000) <= 30 then
        achievement:UnlockAchievement( prop.Owner )
    end
end )


    -- This ~should~ actually auto give you it when you first join, assuming you've had a flyby recorded in your data file
local CA_FLYBY = PROPKILL.RegisterCombatAchievement(
    {
        id = "flyby1", -- Don't change
        title = "What was that?!",
        description = "Kill a player by a flyby.",
        type = "Trigger",
        difficulty = 1,  -- Still working out if I want to even include a difficulty paramater. 1 thru 5?
    }
)
CA_FLYBY:AddListener( "props_PlayerFlybyChanged", LISTENER_SERVER, function( achievement, pl, oldflyby, newflyby )
    if newflyby > oldflyby then
        achievement:UnlockAchievement( pl )
    end
end )


local CA_TOYMAKER = PROPKILL.RegisterCombatAchievement(
    {
        id = "toymaker",
        title = "Toy maker",
        description = "Kill a player with a very small object",
        type = "Trigger",
        difficulty = 1
    }
)
CA_TOYMAKER:AddListener( "props_PropKilled", LISTENER_SERVER, function( achievement, pl, prop )
    if prop:GetClass() != "prop_physics" or not prop.Owner then return end
    if prop.Owner == pl then return end
    if achievement:GetProgression( prop.Owner ) then return end

    local PropVolume = prop:GetPhysicsObject():GetVolume()
        --[[
        Examples that work:
            models/props_junk/Shoe001a.mdl
            models/props_c17/computer01_keyboard.mdl
            models/props_junk/Shovel01a.mdl
            models/props_lab/desklamp01.mdl
            models/props_lab/reciever01c.mdl
        ]]

    if PropVolume <= 504 then
        achievement:UnlockAchievement( prop.Owner )
    end
end )


local CA_DOUBLEKILL = PROPKILL.RegisterCombatAchievement(
    {
        id = "doublekill",
        title = "Two players, one prop",
        description = "Kill two players with the same prop.",
        type = "Counter",
        difficulty = 2
    }
)
CA_DOUBLEKILL:SetGoal( 2 )
CA_DOUBLEKILL:AddListener( "props_PropKilled", LISTENER_SERVER, function( achievement, pl, prop )
    if prop:GetClass() != "prop_physics" or not prop.Owner then return end
    if prop.Owner == pl then return end
    if achievement:GetProgression( prop.Owner ) then return end

    if prop.DoubleKillCheck then
        achievement:UnlockAchievement( prop.Owner )
    else
        prop.DoubleKillCheck = true
    end
end )


local CA_SMURF = PROPKILL.RegisterCombatAchievement(
    {
        id = "smurf",
        title = "Smurf",
        description = "Reset your stats at least once",
        type = "Trigger",
        difficulty = 2
    }
)
CA_SMURF:AddListener( "props_PlayerResetStats", LISTENER_SERVER, function( achievement, pl )
    if achievement:GetProgression( pl ) then return end

    achievement:UnlockAchievement( pl )
end )


local CA_LEADER = PROPKILL.RegisterCombatAchievement(
    {
        id = "theleader",
        title = "The Leader",
        description = "Become the leader at least once",
        type = "Trigger",
        difficulty = 2
    }
)
CA_LEADER:AddListener( "props_RefreshedLeader", LISTENER_SERVER, function( achievement, leader, isNewLeader )
    if not IsValid(leader) then return end
    if achievement:GetProgression( leader ) then return end

    if isNewLeader then
        achievement:UnlockAchievement( leader )
    end
end )


local CA_STANDYOURGROUND = PROPKILL.RegisterCombatAchievement(
    {
        id = "standyourground",
        title = "Stand your ground",
        description = "Kill two players from the same spot",
        type = "Counter",
        difficulty = 1
    }
)
CA_STANDYOURGROUND:SetGoal( 2 )
CA_STANDYOURGROUND:AddListener( "props_PropKilled", LISTENER_SERVER, function( achievement, pl, prop )
    if prop:GetClass() != "prop_physics" or not prop.Owner then return end

    local Killer = prop.Owner

    if Killer == pl then return end
    if achievement:GetProgression( Killer ) then return end
    if not achievement:GetPlayerData(Killer, "PlayerPosition") then
        achievement:SetPlayerData( Killer, "PlayerPosition", Killer:GetPos() )
        return
    end

    if achievement:GetPlayerData(Killer, "PlayerPosition") == Killer:GetPos() then
        achievement:UnlockAchievement( Killer )
    else
        achievement:SetPlayerData(Killer, "PlayerPosition", Killer:GetPos())
    end
end )


local CA_MIDGET = PROPKILL.RegisterCombatAchievement(
    {
        id = "crouching",
        title = "Midget Mania",
        description = "Kill three players while crouching.",
        type = "Counter",
        difficulty = 1
    }
)
CA_MIDGET:SetGoal( 3 )
CA_MIDGET:AddListener( "props_PropKilled", LISTENER_SERVER, function( achievement, pl, prop )
    if prop:GetClass() != "prop_physics" or not prop.Owner then return end

    local Killer = prop.Owner

    if Killer == pl then return end
    if achievement:GetProgression( Killer ) then return end

    if Killer:Crouching() then
        achievement:AddProgression( Killer )
    end
end )


local CA_KILLINGSPREE = PROPKILL.RegisterCombatAchievement(
    {
        id = "killingspree",
        title = "Killing spree",
        description = "Kill five players without dying yourself.",
        type = "Counter",
        difficulty = 3
    }
)
CA_KILLINGSPREE:SetGoal( 5 )
CA_KILLINGSPREE:AddListener( "props_PlayerKillstreakChanged", LISTENER_SERVER, function( achievement, killer, oldkillstreak, newkillstreak )
    if achievement:GetProgression( killer ) then return end
    if newkillstreak == 5 then
        achievement:UnlockAchievement( killer )
    end
end )


local CA_NERFED = PROPKILL.RegisterCombatAchievement(
    {
        id = "nerfed",
        title = "Nerfed",
        description = "Kill three players in a row without freezing any props and while not dying yourself.",
        type = "Counter",
        difficulty = 3
    }
)
CA_NERFED:SetGoal( 3 )
CA_NERFED:AddListener( "props_PropKilled", LISTENER_SERVER, function( achievement, pl, prop )
    if prop:GetClass() != "prop_physics" or not prop.Owner then return end
    if achievement:GetProgression( pl ) then return end

    local Killer = prop.Owner

    achievement:AddProgression( Killer )
end )
CA_NERFED:AddListener( "OnPhysgunFreeze", LISTENER_SERVER, function( achievement, weapon, physobj, ent, pl )
    if ent:GetClass() != "prop_physics" then return end
    if achievement:GetProgression( pl ) then return end

    achievement:ResetProgression( pl )

end )
CA_NERFED:AddListener( "PlayerDeath", LISTENER_SERVER, function( achievement, pl )
    if achievement:GetProgression( pl ) then return end

    achievement:ResetProgression( pl )
end )


local CA_LOWGROUND = PROPKILL.RegisterCombatAchievement(
    {
        id = "groundkill",
        title = "I'll take the low ground",
        description = "Kill five players in a row while on the ground.",
        type = "Counter",
        difficulty = 1
    }
)
CA_LOWGROUND:SetGoal( 5 )
CA_LOWGROUND:AddListener( "props_PropKilled", LISTENER_SERVER, function( achievement, pl, prop )
    if prop:GetClass() != "prop_physics" or not prop.Owner then return end

    local Killer = prop.Owner

    if achievement:GetProgression( Killer ) then return end

    if Killer:GetGroundEntity() == Entity(0) then
        achievement:AddProgression( Killer )
    else
        achievement:ResetProgression( Killer )
    end
end )


local CA_COMPLETIONIST = PROPKILL.RegisterCombatAchievement(
    {
        id = "completionist",
        title = "The Completionist",
        description = "Unlock every achievement (that existed at the time of unlocking)",
        type = "Trigger",
        difficulty = 5
    }
)
CA_COMPLETIONIST:AddListener( "OnAchievementUnlocked", LISTENER_SERVER, function( achievement, pl )
    if achievement:GetProgression( pl ) then return end

    local CountAchievements = 0
	for k,v in next, pl.AchievementData or {} do
		if v.Unlocked then
			CountAchievements = CountAchievements + 1
		end
	end
	if CountAchievements == PROPKILL.CombatAchievementsCount - 1 then
        achievement:UnlockAchievement( pl )
    end
end )


local CA_STOMPED = PROPKILL.RegisterCombatAchievement(
    {
        id = "stomped",
        title = "Stomped",
        description = "Jump onto a player's head from at least a 2 story height",
        type = "Trigger",
        difficulty = 1
    }
)
CA_STOMPED:AddListener( "OnPlayerJump", LISTENER_SERVER, function( achievement, pl, speed )
    if achievement:GetProgression( pl ) then return end
    achievement:SetPlayerData( pl, "JumpHeight", pl:GetPos().z )
    achievement:SetPlayerData( pl, "JumpTime", CurTime() )
end )
CA_STOMPED:AddListener( "OnPlayerHitGround", LISTENER_SERVER, function( achievement, pl, b_water, b_floater, i_speed )
    if achievement:GetProgression( pl ) then return end
    if pl:IsBot() then return end
        -- This includes bots
    if not pl:GetGroundEntity():IsPlayer() then return end

    if (achievement:GetPlayerData( pl, "JumpHeight", pl:GetPos().z ) - pl:GetPos().z > 130)
        and achievement:GetPlayerData( pl, "JumpTime", CurTime() ) - CurTime() < 7 then

        achievement:UnlockAchievement( pl )
    end
end )

local CA_CAUGHT = PROPKILL.RegisterCombatAchievement(
    {
        id = "cancelmyfall",
        title = "Cancel my fall",
        description = "Land in the middle of a frozen prop thats touching the ground while falling fast",
        type = "Trigger",
        difficulty = 2
    }
)
CA_CAUGHT:AddListener( "FinishMove", LISTENER_SERVER, function( achievement, pl, movedata )
    if achievement:GetProgression( pl ) then return end
    if pl:IsBot() then return end
    achievement:SetPlayerData( pl, "MovementVelocity", movedata:GetVelocity():LengthSqr() )

    if not timer.HasPlayer( pl, "props_CombatAchievementCancelMyFall" ) then

        timer.CreatePlayer( pl, "props_CombatAchievementCancelMyFall", 1, 0, function()
            if not pl:Alive() or pl:Team() == TEAM_SPECTATOR then return end
            if IsValid( pl:GetGroundEntity() ) or pl:GetGroundEntity() == Entity(0) then
                achievement:SetPlayerData( pl, "LastVelocity", nil )
                return
            end

                -- Interestingly, if we land in a frozen prop our velocity drops massively (but above zero) and then stays (mostly) stagnant!
           -- print(pl:GetVelocity():LengthSqr())

            local GetCurVelocity = pl:GetVelocity():LengthSqr()
            local GetLastVelocity = achievement:GetPlayerData( pl, "LastVelocity", pl:GetVelocity() )--GetCurVelocity )
            local GetMoveDataVelocity = achievement:GetPlayerData( pl, "MovementVelocity", GetCurVelocity )

            --print("division", GetLastVelocity / GetCurVelocity)
            --print("mv vel", achievement:GetPlayerData( pl, "MovementVelocity"), 0 )

                -- Weird mechanic with getting stuck in props
            if GetLastVelocity:LengthSqr() / GetCurVelocity > 7
            and GetMoveDataVelocity > 0 and GetMoveDataVelocity < 100
            and pl:GetVelocity().z - GetLastVelocity.z > 240 then
                --print(GetLastVelocity:LengthSqr(), GetCurVelocity, pl:GetVelocity().z, pl:GetVelocity().z - GetLastVelocity.z)
                achievement:UnlockAchievement( pl )

            end

            achievement:SetPlayerData( pl, "LastVelocity", pl:GetVelocity() )--:LengthSqr() )
        end )

    end
end )
CA_CAUGHT:AddListener( "OnAchievementUnlocked", LISTENER_SERVER, function( achievement, pl, uniqueid, fancytitle )
    if achievement:GetUniqueID() == uniqueid then
        timer.DestroyPlayer( pl, "props_CombatAchievementCancelMyFall" )
    end
end )


local CA_REPETITION = PROPKILL.RegisterCombatAchievement(
    {
        id = "repetition",
        title = "Repetition is key",
        description = "Using only one model, kill five players",
        type = "Counter",
        difficulty = 3
    }
)
CA_REPETITION:SetGoal( 5 )
CA_REPETITION:AddListener( "props_PropKilled", LISTENER_SERVER, function( achievement, pl, prop )
    if prop:GetClass() != "prop_physics" or not prop.Owner then return end

    local Killer = prop.Owner
    if achievement:GetProgression( Killer ) then return end

    achievement:AddProgression( Killer )

end )
CA_REPETITION:AddListener( "PlayerSpawnedProp", LISTENER_SERVER, function( achievement, pl, model, ent )
    if achievement:GetProgression( pl ) then return end

    if achievement:GetPlayerData( pl, "SpawnedModel" ) then
        if achievement:GetPlayerData( pl, "SpawnedModel" ) != model then
            achievement:ResetProgression( pl )
            return
        end
    end

    achievement:SetPlayerData( pl, "SpawnedModel", model )
end )


local CA_WHAMMY = PROPKILL.RegisterCombatAchievement(
    {
        id = "doublywhammy",
        title = "Double Whammy",
        description = "Kill a player with the kill being registered as BOTH a longshot AND a headsmash",
        type = "Trigger",
        difficulty = 5
    }
)
CA_WHAMMY:AddListener( "props_DoubleWhammyLongshotHeadsmash", LISTENER_SERVER, function( achievement, killer, deadplayer )
    if achievement:GetProgression( killer ) then return end

    achievement:UnlockAchievement( killer )
end )


local CA_LOOKAWAY = PROPKILL.RegisterCombatAchievement(
    {
        id = "lookaway",
        title = "Cool guys don't look at prop kills",
        description = "Kill a player while being turned away from them",
        type = "Trigger",
        difficulty = 3
    }
)
CA_LOOKAWAY:AddListener( "props_PropKilled", LISTENER_SERVER, function( achievement, deadplayer, prop )
    if prop:GetClass() != "prop_physics" or not prop.Owner then return end

    local Killer = prop.Owner
    if achievement:GetProgression( Killer ) then return end
    if Killer == deadplayer then return end

    local Dist = prop:GetPos() - Killer:GetShootPos()
    local Product = Killer:GetAimVector():Dot(Dist) / Dist:Length()

    if Product <= -0.2 then
        achievement:UnlockAchievement( Killer )
    end
end )


local CA_NOLIFE = PROPKILL.RegisterCombatAchievement(
    {
        id = "nolife",
        title = "No life",
        description = "Be on the server for two consecutive hours",
        type = "Trigger",
        difficulty = 4
    }
)
CA_NOLIFE:AddListener( "props_PlayerDataLoaded", LISTENER_SERVER, function( achievement, pl )
    if achievement:GetProgression( pl ) then return end

    timer.CreatePlayer( pl, "props_CombatAchievementNoLife", 2*60*60, 1, function()
        achievement:UnlockAchievement( pl )
    end )
end )

    -- This ~may~ actually auto give you it when you first join, assuming you've had enough longshots recorded in your data file
local CA_LOVELONGSHOT = PROPKILL.RegisterCombatAchievement(
    {
        id = "lovelongshots", -- Don't change
        title = "I Love Longshots",
        description = "Perform 20 longshots (not required to be in one session)",
        type = "Counter",
        difficulty = 3,  -- Still working out if I want to even include a difficulty paramater. 1 thru 5?
    }
)
CA_LOVELONGSHOT:SetGoal( 20 )
CA_LOVELONGSHOT:AddListener( "props_PlayerLongshotChanged", LISTENER_SERVER, function( achievement, pl, oldflyby, newflyby )
    if newflyby >= achievement:GetGoal() then
        achievement:UnlockAchievement( pl )
    end
end )


local CA_NOSCOPE = PROPKILL.RegisterCombatAchievement(
    {
        id = "noscope",
        title = "360 noscope",
        description = "Kill a player after turning 360+ degrees after releasing a prop",
        type = "Trigger",
        difficulty = 3
    }
)
CA_NOSCOPE:AddListener( "PhysgunDrop", LISTENER_SERVER, function( achievement, pl, ent )
    if ent:GetClass() != "prop_physics" then return end
    if achievement:GetProgression( pl ) then return end

    achievement:SetPlayerData( pl, "TotalRotation", 0 )
    achievement:SetPlayerData( pl, "DroppedProp", ent)
        -- This is specifically to check if too much time has elapsed since dropping of the prop and killing a player.
    achievement:SetPlayerData( pl, "DroppedPropTime", CurTime() )
end )
CA_NOSCOPE:AddListener( "Move", LISTENER_SERVER, function( achievement, pl, mv )
    if pl:IsBot() then return end
    if achievement:GetProgression( pl ) then return end
    if pl != Entity(1) then return end -- TEMPORARY. REMOVE.
        -- If the player either has never dropped a prop OR the prop was removed
    if not IsValid(achievement:GetPlayerData( pl, "DroppedProp", NULL )) then return end
        -- If 4 seconds have passed after the player dropped a prop then quit tracking
    if (CurTime() - achievement:GetPlayerData( pl, "DroppedPropTime", 0 )) > 4 then return end

    local MoveAngleY = mv:GetAngles().y
    local LastMoveAngleY = achievement:GetPlayerData( pl, "OldMoveAngleY", mv:GetAngles().y )
    local ChangeInMoveAngle = math.DeltaAngle(LastMoveAngleY, MoveAngleY)

    achievement:SetPlayerData( pl, "TotalRotation", achievement:GetPlayerData( pl, "TotalRotation", 0 ) + math.abs(ChangeInMoveAngle) )
    achievement:SetPlayerData( pl, "OldMoveAngleY", MoveAngleY )
end )
CA_NOSCOPE:AddListener( "props_PropKilled", LISTENER_SERVER, function( achievement, deadplayer, prop )
    if prop:GetClass() != "prop_physics" or not prop.Owner then return end

    local Killer = prop.Owner
    if achievement:GetProgression( Killer ) then return end


    if achievement:GetPlayerData( Killer, "TotalRotation", 0 ) <= 360 then
            -- Reset their rotation in case they kill a SECOND player with the same prop within the timeframe.
        achievement:ResetProgression( Killer )
    else
        achievement:UnlockAchievement( Killer )
    end
end )
CA_NOSCOPE:AddListener("OnReloaded", LISTENER_SERVER, function( achievement )
    for k,v in next, player.GetHumans() do
        achievement:ResetProgression( v )
    end
end )


local CA_NOSCOPE720 = PROPKILL.RegisterCombatAchievement(
    {
        id = "noscope720",
        title = "720 noscope",
        description = "Kill a player after turning 720+ degrees after releasing a prop",
        type = "Trigger",
        difficulty = 4
    }
)
CA_NOSCOPE720:AddListener( "PhysgunDrop", LISTENER_SERVER, function( achievement, pl, ent )
    if ent:GetClass() != "prop_physics" then return end
    if achievement:GetProgression( pl ) then return end

    achievement:SetPlayerData( pl, "TotalRotation", 0 )
    achievement:SetPlayerData( pl, "DroppedProp", ent)
        -- This is specifically to check if too much time has elapsed since dropping of the prop and killing a player.
    achievement:SetPlayerData( pl, "DroppedPropTime", CurTime() )
end )
CA_NOSCOPE720:AddListener( "Move", LISTENER_SERVER, function( achievement, pl, mv )
    if pl:IsBot() then return end
    if achievement:GetProgression( pl ) then return end
    if pl != Entity(1) then return end -- TEMPORARY. REMOVE.
        -- If the player either has never dropped a prop OR the prop was removed
    if not IsValid(achievement:GetPlayerData( pl, "DroppedProp", NULL )) then return end
        -- If 4 seconds have passed after the player dropped a prop then quit tracking
    if (CurTime() - achievement:GetPlayerData( pl, "DroppedPropTime", 0 )) > 4 then return end

    local MoveAngleY = mv:GetAngles().y
    local LastMoveAngleY = achievement:GetPlayerData( pl, "OldMoveAngleY", mv:GetAngles().y )
    local ChangeInMoveAngle = math.DeltaAngle(LastMoveAngleY, MoveAngleY)

    achievement:SetPlayerData( pl, "TotalRotation", achievement:GetPlayerData( pl, "TotalRotation", 0 ) + math.abs(ChangeInMoveAngle) )
    achievement:SetPlayerData( pl, "OldMoveAngleY", MoveAngleY )
end )
CA_NOSCOPE720:AddListener( "props_PropKilled", LISTENER_SERVER, function( achievement, deadplayer, prop )
    if prop:GetClass() != "prop_physics" or not prop.Owner then return end

    local Killer = prop.Owner
    if achievement:GetProgression( Killer ) then return end


    if achievement:GetPlayerData( Killer, "TotalRotation", 0 ) <= 720 then
            -- Reset their rotation in case they kill a SECOND player with the same prop within the timeframe.
        achievement:ResetProgression( Killer )
    else
        achievement:UnlockAchievement( Killer )
    end
end )
CA_NOSCOPE720:AddListener("OnReloaded", LISTENER_SERVER, function( achievement )
    for k,v in next, player.GetHumans() do
        achievement:ResetProgression( v )
    end
end )


local CA_RECLUSE = PROPKILL.RegisterCombatAchievement(
    {
        id = "recluse",
        title = "The recluse",
        description = "Play 10 minutes without sending any messages",
        type = "Time",
        difficulty = 1
    }
)
CA_RECLUSE:SetGoal( 10 )
CA_RECLUSE:AddListener( "props_PlayerDataLoaded", LISTENER_SERVER, function( achievement, pl )
    if achievement:GetProgression( pl ) then return end

    timer.CreatePlayer( pl, "props_CombatAchievementRecluse", 60, 0, function()
        achievement:AddProgression( pl )
    end )
end )
    -- I don't care if the message didn't show up. They tried to send a message.
CA_RECLUSE:AddListener( "PlayerSay", LISTENER_SERVER, function( achievement, pl )
    if achievement:GetProgression( pl ) then return end

    achievement:ResetProgression( pl )
end )
    -- Apparently Player:IsSpeaking ~DOES~ work on server after all.
CA_RECLUSE:AddListener( "PlayerTick", LISTENER_SERVER, function( achievement, pl, mv )
    if achievement:GetProgression( pl ) then return end

    if pl:IsSpeaking() then
        achievement:ResetProgression( pl )
    end
end )
CA_RECLUSE:AddListener( "OnAchievementUnlocked", LISTENER_SERVER, function( achievement, pl, uniqueid, fancytitle )
    if achievement:GetUniqueID() == uniqueid then
        timer.DestroyPlayer( pl, "props_CombatAchievementRecluse" )
    end
end )

    -- Clipping confirmed to work for <=32 units in width. Unsure about anything more.
    -- does the prop ever follow through props/walls? Or do we always travel alone?
local CA_WALLCLIP = PROPKILL.RegisterCombatAchievement(
    {
        id = "clipyourself",
        title = "Go clip yourself",
        description = "Push yourself through a wall",
        type = "Trigger",
        difficulty = 4
    }
)
CA_WALLCLIP:AddListener( "PhysgunPickup", LISTENER_SERVER, function( achievement, pl, mv )
    if achievement:GetProgression( pl ) then return end

    achievement:SetPlayerData( pl, "HoldingProp", true )
end )
CA_WALLCLIP:AddListener( "PhysgunDrop", LISTENER_SERVER, function( achievement, pl, mv )
    if achievement:GetProgression( pl ) then return end

    achievement:SetPlayerData( pl, "HoldingProp", false )
end )
CA_WALLCLIP:AddListener( "PlayerTick", LISTENER_SERVER, function( achievement, pl )
    if achievement:GetProgression( pl ) then return end
    if not pl:Alive() or pl:Team() == TEAM_SPECTATOR then return end
    if not achievement:GetPlayerData( pl, "HoldingProp", false ) then return end

        -- Still looking for alternative methods btw. If anyone has any ideas...
    local contents = util.PointContents(pl:GetPos())
    if contents != 256 and contents != 0 then
        if bit.band(contents, CONTENTS_SOLID) then
            achievement:UnlockAchievement( pl )
        end
    end


        -- chatgpt. not a fan of running traces every tick that a player is holding a prop.
    --[[ local curPos = pl:GetPos()
    local lastPos = pl.LastSafePos or curPos

    local trace = util.TraceLine({
        start = lastPos,
        endpos = curPos,
        filter = pl,
        mask = MASK_SOLID_BRUSHONLY -- Only checks the world geometry
    })

    if trace.Hit and trace.HitWorld then
       achievement:UnlockAchievement( pl )
    end

    pl.LastSafePos = curPos]]
end )

local CA_RECURRINGPLAYER = PROPKILL.RegisterCombatAchievement(
    {
        id = "theregular",
        title = "The Regular",
        description = "Join the server five times",
        type = "Counter",
        save_progression = true,
        difficulty = 2
    }
)
CA_RECURRINGPLAYER:SetGoal( 5 )
CA_RECURRINGPLAYER:AddListener( "props_PlayerDataLoaded", LISTENER_SERVER, function( achievement, pl )
    if achievement:GetProgression( pl ) then return end

    achievement:AddProgression( pl )
end )

local CA_TOMORROW = PROPKILL.RegisterCombatAchievement(
    {
        id = "seeyoutomorrow",
        title = "See You Tomorrow",
        description = "Join the server two days in a row",
        type = "Counter",
        save_progression = true,
        difficulty = 2
    }
)
CA_TOMORROW:SetGoal( 2 )
CA_TOMORROW:AddListener( "props_PlayerDataLoaded", LISTENER_SERVER, function( achievement, pl )
    if achievement:GetProgression( pl ) then return end

    local LastProgressed = achievement:GetPlayerLastProgression( pl )
    if not LastProgressed then
        achievement:AddProgression( pl )
        return
    end

    local CurrentTime = os.time()

    if (CurrentTime - LastProgressed) > 24*60*60 then
            -- If it's been longer than 1 day, reset
        if (CurrentTime - LastProgressed) >= 48*60*60 then
                -- First reset, then add so players don't have to rejoin to get their new initial first day data
            achievement:ResetProgression( pl )
            achievement:AddProgression( pl )
        else
            achievement:AddProgression( pl )
        end
    else
        --print( CurrentTime - LastProgressed )
    end
end )
