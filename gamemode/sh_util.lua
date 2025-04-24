--[[
				  _________.__    .__                                  
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     / 
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/  
						\/      \/        \/\/         \/              

		Shared utilities
]]--

function FindPlayer( info )
	for k,v in next, player.GetAll() do
		if string.find( string.lower( v:Nick() ), string.lower( info ) ) then
			return v
		elseif string.find( v:SteamID(), info ) then
			return v
		elseif v:UserID() == tonumber(info) then
			return v
		elseif v:UniqueID() == info then
			return v
		end
	end
	
	return nil
end

function ChatPrint( msg )
	for k,v in next, player.GetHumans() do
		v:ChatPrint( msg )
	end
end

Props_Benchmark = {}
local benchmarks = {}

function Props_Benchmark.Init( id, callback )
	benchmarks[ id ] =
	{
		callback = callback,
		iteration = {}
	}
end

function Props_Benchmark.Start( id, int_interations )
	local Bench = benchmarks[ id ]
	Bench.iterations = int_interations
	--Bench.starttime = SysTime()
	for i=1,int_interations do
		Bench.iteration[ #Bench.iteration + 1 ] = SysTime()
		Bench.callback()
		Bench.iteration[ #Bench.iteration ] = (SysTime() - Bench.iteration[ #Bench.iteration ])*1000000
	end
end

function Props_Benchmark.End( id )
	local Output = "Benchmark %s took (fake) %f seconds to complete"
	local Bench = benchmarks[ id ]
	local Average = 0
	for k,v in next, Bench.iteration do
		Average = Average + v
	end
	if CLIENT then
		LocalPlayer():ChatPrint( "Client: " .. string.format( Output, id, Average / Bench.iterations ) )
	else
		print(string.format( Output, id, Average / Bench.iterations ))
		if IsValid(Entity(1)) then
			Entity(1):ChatPrint("Server: " .. string.format( Output, id, Average / Bench.iterations ))
		end
	end

	benchmarks[ id ] = nil
end
