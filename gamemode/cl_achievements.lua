local function NetworkLocalPlayerAchievement( len, EmptyOnClientside, Retried, AchievementID )
    local Achievement = AchievementID or net.ReadString()
        -- If we get an achievement immediately upon connection our entity may not be valid yet.
    if not IsValid( LocalPlayer() ) then --and !Retried then
        timer.Simple( 0.5, function()
            NetworkLocalPlayerAchievement(len, nil, true, Achievement)
        end )
        return
    end

        -- We can probably go ahead and just send the # in the table vs a whole string
    local AchievementTbl = PROPKILL.GetCombatAchievementByUniqueID( Achievement )

    AchievementTbl:UnlockAchievement( LocalPlayer() )
end
net.Receive( "props_NetworkPlayerAchievement", NetworkLocalPlayerAchievement )

net.Receive( "props_NetworkPlayerAchievementsCompleted", function( len )
    local UniqueJoins = net.ReadUInt( 14 )
    local CountAchievements = net.ReadUInt( 5 )

    PROPKILL.Statistics["totaluniquejoins"] = UniqueJoins

    for i=1,CountAchievements do
        local Achievement = PROPKILL.GetCombatAchievementByUniqueID( net.ReadString() )
        Achievement:SetCompletionRate( net.ReadUInt( 14 ) )
        if net.ReadBool() then
            Achievement:UnlockAchievement( LocalPlayer(), true )
        else
                -- This was added solely for server debugging. Hopefully doesn't cause any issues
            Achievement:LockAchievement( LocalPlayer() )
        end
    end

    hook.Run( "props_NetworkPlayerAchievementsCompleted" )
end )

net.Receive( "props_NetworkPlayerAchievementPercentages", function( len)
    PROPKILL.Statistics["totaluniquejoins"] = net.ReadUInt(14)

    local AchievementID = net.ReadString()
    local AchievementsCompletionRate = net.ReadUInt( 14 )

    PROPKILL.GetCombatAchievementByUniqueID(AchievementID):SetCompletionRate(AchievementsCompletionRate)
        -- Hopefully this is only used for props_achievements menu (so we can update all players looking at the menu)
    hook.Run( "props_NetworkPlayerAchievementsCompleted" )
end )

net.Receive( "props_UpdatePlayerAchievementProgress", function()
    local AchievementID = net.ReadString()
    local AchievementProgress = net.ReadUInt( 5 )

    PROPKILL.CombatAchievements[AchievementID] = PROPKILL.CombatAchievements[AchievementID] or {}
    PROPKILL.CombatAchievements[AchievementID].localplayerProgress = AchievementProgress
end )

net.Receive( "props_SendPlayerAllPlayerAchievementsProgress", function()
    local AchievementCount = net.ReadUInt( 6 )

    for i=1,AchievementCount do
        local AchievementID = net.ReadString()
        local AchievementProgress = net.ReadUInt( 5 )

        PROPKILL.CombatAchievements[AchievementID] = PROPKILL.CombatAchievements[AchievementID] or {}
        PROPKILL.CombatAchievements[AchievementID].localplayerProgress = AchievementProgress
    end
end )

AddClientConfigItem( "props_DefaultAchievementSorting",
	{
	Name = "Default Achievement Sorting",
	default = 1,
    min = 1,
	max = 3,
	type = "integer",
	decimals = 0,
	desc = "Default method of sorting achievements menu. 1=Title;2=Difficulty;3=Percentage Completed",
	}
)
