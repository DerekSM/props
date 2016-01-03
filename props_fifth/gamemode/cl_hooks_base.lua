
--[[

*

* Initializing of client

*

--]]
function GM:Initialize()
	for k,v in pairs( properties.List ) do
		if v.Order < 2000 and k != "remove" then
			properties.List[ k ] = nil
		end
	end
	
	--[[LocalPlayer():InstallDataTable()
	LocalPlayer():NetworkVar( "Int", 0, "TotalFrags" )
	LocalPlayer():NetworkVar( "Int", 1, "TotalDeaths" )
	LocalPlayer():NetworkVar( "Int", 2, "Killstreak" )
	LocalPlayer():NetworkVar( "Int", 3, "BestKillstreak" )
	LocalPlayer():NetworkVar( "Int", 4, "Flybys" )
	LocalPlayer():NetworkVar( "Int", 5, "Longshots" )]]
end

function GM:PhysgunPickup( pl )
	return false
end

function GM:OnCleanup( name )

	--self:AddNotify( "#Cleaned_"..name, NOTIFY_CLEANUP, 5 )
	
	-- Find a better sound :X
	surface.PlaySound( "buttons/button15.wav" )

end

net.Receive( "PlayerKilled", function()
	local victim = net.ReadEntity()
	if not IsValid( victim ) then
		return
	end
	local inflictor = net.ReadString()
	local attacker = net.ReadEntity()
	
	if IsValid( attacker ) then
		GAMEMODE:AddDeathNotice( attacker:Nick(), attacker:Team(), inflictor, victim:Nick(), victim:Team() )
	end
end )

/*
		START STEAL FROM DeathZone (Sowwy anthrax :c)
*/

local MessageCache = {}
local function DrawMessageCache()
	--for i, v in pairs(MessageCache) do
	for i, v in next, MessageCache do

		if v.goingUp then
			local amount = 255 / 30
			if v.alpha + amount <= 255 then
				v.alpha = v.alpha + amount
			else
				v.alpha = 255
			end
		else
			local amount = 255 / 100
			v.alpha = v.alpha - amount
			if v.alpha <= 0 then
				v.alpha = 0
			end
		end

		if CurTime() >= v.time + 1.8 then
			v.goingUp = false
		end

		if not v.goingUp and v.alpha <= 0 then
			table.remove(MessageCache, i)
		end

		local targetY
		if v.goingUp then
			targetY = -(i * 20)
			v.y = v.y + ((targetY - v.y) / 20)

			targetX = 30
			v.x = v.x + ((targetX - v.x) / 40)
		else
			targetY = 200
			v.y = v.y + ((targetY - v.y) / 80)

			targetX = -100
			v.x = v.x + ((targetX - v.x) / 60)
		end

		surface.SetMaterial(Material( "icon16/add.png" ,"nocull" ))
		surface.SetDrawColor(Color(255, 255, 255, v.alpha))
		surface.DrawTexturedRect(10 + v.x, (ScrH() / 2) + v.y - 8, 16, 16)
		draw.SimpleTextOutlined(v.data.text, "Trebuchet18", 30 + v.x, (ScrH() / 2) + v.y, Color(v.data.col.r, v.data.col.g, v.data.col.b, v.alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(v.data.col.r / 2, v.data.col.g / 2, v.data.col.b / 2, v.alpha / 2))
	end
	
	if #MessageCache > 16 then
		--table.remove(MessageCache, 1)
		for i=1,5 do
			MessageCache[ i ].goingup = false
		end
	end
end

hook.Add("HUDPaint", "PK_DrawMessageCache", DrawMessageCache)
net.Receive("PK_HUDMessage", function()
	if LocalPlayer().specialdeaths and not tobool(LocalPlayer().specialdeaths) then return end
	
	--local data = net.ReadTable()
	local data_string = net.ReadString()
	local data_int1 = net.ReadUInt( 8 )
	local data_int2 = net.ReadUInt( 8 )
	local data_int3 = net.ReadUInt( 8 )
	surface.PlaySound("buttons/lightswitch2.wav")
	--LocalPlayer():ConsoleMsg(Color( data_int1, data_int2, data_int3, 255 ), data_string)

	--for k, v in pairs(MessageCache) do
	for k, v in next, MessageCache do
		v.time = v.time + 0.8
	end

	MessageCache[ #MessageCache + 1 ] = {data = {text = data_string, col = Color(data_int1,data_int2,data_int3,255)}, x = 0, y = 0, goingUp = true, time = CurTime(), alpha = 0}
end)

/*
		END STEAL FROM DeathZone
*/