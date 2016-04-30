
AddCSLuaFile()
DEFINE_BASECLASS( "player_sandbox" )

local PLAYER = {}

function PLAYER:SetupDataTables()

	self.Player:NetworkVar( "Int", 0, "TotalFrags" )
	self.Player:NetworkVar( "Int", 1, "TotalDeaths" )
	self.Player:NetworkVar( "Int", 2, "Killstreak" )
	self.Player:NetworkVar( "Int", 3, "BestKillstreak" )
	self.Player:NetworkVar( "Int", 4, "Flybys" )
	self.Player:NetworkVar( "Int", 5, "Longshots" )
	
	BaseClass.SetupDataTables( self )

end

function PLAYER:Loadout()

	BaseClass.Loadout( self )
	
end

function PLAYER:SetModel()
	
	BaseClass.SetModel( self )

end

function PLAYER:Spawn()
	
	print( "NigGER ")
	
	BaseClass.Spawn( self )

end

function PLAYER:ShouldDrawLocal()
	
	return false
	
end

function PLAYER:CreateMove( cmd )
	
end

function PLAYER:CalcView( view )
	
end

function PLAYER:GetHandsModel()

	BaseClass.GetHandsModel( self )
	
end

--
-- Reproduces the jump boost from HL2 singleplayer
--
local JUMPING

function PLAYER:StartMove( move )
	
	-- Only apply the jump boost in FinishMove if the player has jumped during this frame
	-- Using a global variable is safe here because nothing else happens between SetupMove and FinishMove
	if bit.band( move:GetButtons(), IN_JUMP ) ~= 0 and bit.band( move:GetOldButtons(), IN_JUMP ) == 0 and self.Player:OnGround() then
		JUMPING = true
	end
	
end

function PLAYER:Move( mv ) end				-- Runs the move (can run multiple times for the same client)

function PLAYER:FinishMove( move )
	
	-- If the player has jumped this frame
	if JUMPING then
		-- Get their orientation
		local forward = self.Player:EyeAngles()
		forward.p = 0
		forward = forward:Forward()
		
		-- Compute the speed boost
		
		-- HL2 normally provides a much weaker jump boost when sprinting
		-- For some reason this never applied to GMod, so we won't perform
		-- this check here to preserve the "authentic" feeling
		local speedBoostPerc = ( ( not self.Player:Crouching() ) and 0.5 ) or 0.1
		
		local speedAddition = math.abs( move:GetForwardSpeed() * speedBoostPerc )
		local maxSpeed = move:GetMaxSpeed() * ( 1 + speedBoostPerc )
		local newSpeed = speedAddition + move:GetVelocity():Length2D()
		
		-- Clamp it to make sure they can't bunnyhop to ludicrous speed
		if newSpeed > maxSpeed then
			speedAddition = speedAddition - (newSpeed - maxSpeed)
		end
		
		-- Reverse it if the player is running backwards
		if move:GetForwardSpeed() < 0 then
			speedAddition = -speedAddition
		end
		
		-- Apply the speed boost
		move:SetVelocity(forward * speedAddition + move:GetVelocity())
	end
	
	JUMPING = nil
	
end

--
-- Name: PLAYER:ViewModelChanged
-- Desc: Called when the player changes their weapon to another one causing their viewmodel model to change
-- Arg1: Entity|viewmodel|The viewmodel that is changing
-- Arg2: string|old|The old model
-- Arg3: string|new|The new model
-- Ret1:
--
function PLAYER:ViewModelChanged( vm, old, new )
end

--
-- Name: PLAYER:PreDrawViewmodel
-- Desc: Called before the viewmodel is being drawn (clientside)
-- Arg1: Entity|viewmodel|The viewmodel
-- Arg2: Entity|weapon|The weapon
-- Ret1:
--
function PLAYER:PreDrawViewModel( vm, weapon )
end

--
-- Name: PLAYER:PostDrawViewModel
-- Desc: Called after the viewmodel has been drawn (clientside)
-- Arg1: Entity|viewmodel|The viewmodel
-- Arg2: Entity|weapon|The weapon
-- Ret1:
--
function PLAYER:PostDrawViewModel( vm, weapon )
end


player_manager.RegisterClass( "player_propkill", PLAYER, "player_sandbox" )