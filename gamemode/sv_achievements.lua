hook.Add("OnAchievementUnlocked", "props_NetworkPlayerAchievement", function( pl, id, fancytitle )
        -- Only the player needs to know they've unlocked this achievement
    net.Start( "props_NetworkPlayerAchievement")
            -- We can probably go ahead and just send the # in the table vs a whole string
        net.WriteString( id )
    net.Send( pl )

        -- Broadcast to the rest of the players the percentage of players completed
        -- If we want to get really tricky we
    Props_SendPlayerAchievementPercentages( player.GetHumans(), id )
    pl:SaveCombatAchievements()
    props_SaveCombatAchievements()

    if PROPKILL.Config["achievements_playsound"].default then
        pl:EmitSound("vo/coast/odessa/female01/nlo_cheer03.wav", 30)
    end
    if PROPKILL.Config["achievements_announce"].default then
        --pl:ChatPrint("You've unlocked achievement " .. fancytitle)
        for k,v in next, player.GetHumans() do
            PROPKILL.ChatText( v, PROPKILL.Colors.Blue,
			"Props: ", team.GetColor(pl:Team()), pl:Nick(), color_white, " has completed the \"" .. fancytitle .. "\" achievement." )
        end
	else
            -- Still announce it, but only to the player.
        pl:ChatPrint("You've unlocked achievement " .. fancytitle)
    end
end )

hook.Add("OnAchievementProgressed", "props_SavePlayerAchievementProgression", function( pl, id, fancytitle, newprogression )
    if PROPKILL.GetCombatAchievementByUniqueID( id ).save_progression then

        pl:SaveCombatAchievements()
    end
end )

hook.Add("OnAchievementProgressReset", "props_SavePlayerAchievementProgression", function( pl, id, fancytitle )
    if PROPKILL.GetCombatAchievementByUniqueID( id ).save_progression then
        pl:SaveCombatAchievements()
    end
end )

    -- When should we call this?
--[[function Props_SendPlayerAllAchievementPercentages( tblPlayers )
    local GetCombatAchievements = PROPKILL.GetCombatAchievements()

    net.Start( "props_NetworkPlayerAllAchievementPercentages")
        net.WriteUInt( PROPKILL.Statistics["totaluniquejoins"] or 1, 14)
        net.WriteUInt( #GetCombatAchievements, 5 )
        for k,v in next, GetCombatAchievements do
            net.WriteString( v:GetUniqueID() )
            net.WriteUInt( v:GetCompletionRate(), 14 )
        end
    net.Send( tblPlayers )
end]]

    -- Called whenever someone unlocks an achievement
    -- We can probably optimize this but for now its fine.
function Props_SendPlayerAchievementPercentages( tblPlayers, achievement )
    local GetCombatAchievements = PROPKILL.GetCombatAchievementByUniqueID( achievement )

    net.Start( "props_NetworkPlayerAchievementPercentages")
        net.WriteUInt( PROPKILL.Statistics["totaluniquejoins"] or 1, 14)
        net.WriteString( achievement )
        net.WriteUInt( GetCombatAchievements:GetCompletionRate(), 14 )
    net.Send( tblPlayers )
end

    -- Should really only be called when player first joins
    -- Essentially replicates Props_SendPlayerAllAchievementPercentages but one additional parameter
function Props_SendPlayerAllAchievementsCompleted( pl )
    net.Start( "props_NetworkPlayerAchievementsCompleted" )
        net.WriteUInt( PROPKILL.Statistics["totaluniquejoins"] or 1, 14)
        net.WriteUInt( PROPKILL.CombatAchievementsCount, 5 )
        for k,v in next, PROPKILL.GetCombatAchievements() do
            net.WriteString( v:GetUniqueID() )
            net.WriteUInt( v:GetCompletionRate(), 14 )
            net.WriteBool( v:GetProgression( pl ) )
        end
    net.Send( pl )
end

function Props_UpdatePlayerAchievementProgress( pl, achievement, i_progress )
    net.Start( "props_UpdatePlayerAchievementProgress" )
        net.WriteString( achievement )
        net.WriteUInt( i_progress, 5 )
    net.Send( pl )
end

    -- Not a fan of the duplication of effort but it is what it is... maybe
function Props_SendPlayerAllPlayerAchievementsProgress( pl )
    local Counter = 0
    for k,v in next, PROPKILL.GetCombatAchievements() do
        if v.type != "Counter" then continue end
        if not v.save_progression then continue end

        local Unlocked, Progression = v:GetProgression( pl )
        if Unlocked then continue end

        Counter = Counter + 1
    end

    net.Start( "props_SendPlayerAllPlayerAchievementsProgress" )
        net.WriteUInt( Counter, 6 )
        for k,v in next, PROPKILL.GetCombatAchievements() do
            if v.type != "Counter" then continue end
            if not v.save_progression then continue end

            local Unlocked, Progression = v:GetProgression( pl )
            if Unlocked then continue end

            net.WriteString( v:GetUniqueID() )
            net.WriteUInt( Progression, 5 )
        end
    net.Send( pl )
end


hook.Add("OnSettingChanged", "DontPotentiallyCorruptPlayerAchievements", function( pl, setting, beforeChange, change )
    if setting == "achievements_enabled" and change == "true" then
        for k,v in next, player.GetHumans() do
            PROPKILL.ChatText( v, PROPKILL.Colors.Blue,
			"Props: ", color_white, "Gamemode achievements setting has been changed. A map change is required to save player data." )
        end
    end
end )
