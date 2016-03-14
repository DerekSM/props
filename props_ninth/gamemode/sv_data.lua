local _R = debug.getregistry()

function _R.Player:SavePropkillData()
	local steamid = string.gsub( self:SteamID(), ":", "_" )
	
	local data = 
	{
	self:TotalFrags(),
	self:TotalDeaths(),
	--self:GetTotalFrags(),
	--self:GetTotalDeaths(),
	
	self:GetFlybys(),
	self:GetLongshots(),
	
	--[[self:Accuracy(),
	self.PlayerHits or 0,
	self.PropSpawns or 0,]]
	
	self:GetBestKillstreak()
	}
	
	file.Write( "props/" .. steamid .. ".txt", pon.encode( data ) )
end

function _R.Player:LoadPropkillData()
	local steamid = string.gsub( self:SteamID(), ":", "_" )
	
	if file.Exists( "props/" .. steamid .. ".txt", "DATA" ) then
		
		local data = pon.decode( file.Read( "props/" .. steamid .. ".txt", "DATA" ) )

		self:SetTotalFrags( data[ 1 ] )
		self:SetTotalDeaths( data[ 2 ] )
		
		self:SetFlybys( data[ 3 ] )
		self:SetLongshots( data[ 4 ] )
		
		--[[self:SetAccuracy( data[ 5 ] )
		self.PlayerHits = data[ 6 ]
		self.PropSpawns = data[ 7 ]]
		
		--self.BestKillstreak = data[ 5 ]
		self:SetBestKillstreak( data[ 5 ] )
	
	end
end
