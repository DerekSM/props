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

-- https://gist.github.com/DarkWiiPlayer/a6496cbce062ebe5d534e4b881d4efef
-- select keyword is generally faster for low-ish amounts of concatenations.
function table.FastConcat( str_Separator, ... )
	local Pre = {}
	local PreCount = 0
	local select = select
		-- Basically a fast way of accessing varargs, traditionally done with {...}
	for i=1,select("#", ...) do
			-- Keeping an outside counter actually speeds this up.
		PreCount = PreCount + 1
		Pre[PreCount] = select(i, ...)
	end

	return table.concat(Pre, str_Separator)
end

-- Used by an achievement
function math.DeltaAngle( current, new )
	local Delta = (new - current) % 360
	if Delta > 180 then Delta = Delta - 360 end
	if Delta < -180 then Delta = Delta + 360 end

	return Delta
end

-- https://github.com/Facepunch/garrysmod/blob/efcd6eb8d534063bdbe24522810669434f1083ce/garrysmod/lua/includes/util.lua#L78
-- Generic PrintTable except we SEARCH for a key name (case-insensitive)
-- If the table has subtables, and the table matches the key name, we will return all subtables
-- If the table has subtables, and the table DOESNT match, but a subtable does, it will return only the original table and its subtables
-- This is a WIP. It's not complete.
function SearchPrintTable( t, keysearch, indent, done )
	local Msg = Msg
	local string = string

	done = done or {}
	done2 = done2 or {}
	indent = indent or 0
	local keys = table.GetKeys( t )

	table.sort( keys, function( a, b )
		if ( isnumber( a ) and isnumber( b ) ) then return a < b end
		return tostring( a ) < tostring( b )
	end )

	done[ t ] = true

	for i = 1, #keys do
		local key = keys[ i ]
		local value = t[ key ]

		if string.find(string.lower(tostring(key)), string.lower(keysearch), nil, true) then
			key = ( type( key ) == "string" ) and "[\"" .. key .. "\"]" || "[" .. tostring( key ) .. "]"
			MsgN( key )
		end

	end

end

-- ChatGPT, can ignore
function deepSearchKeysPartial(tbl, targetKeyPart, path, results, visited)
    path = path or {}
    results = results or {}
    visited = visited or {}

    if visited[tbl] then return results end
    visited[tbl] = true

    for key, value in pairs(tbl) do
        local keyStr = tostring(key)
        local currentPath = {unpack(path)}
        table.insert(currentPath, keyStr)

        -- Check if the key contains the target substring
        if string.lower(keyStr):find(targetKeyPart:lower()) then
            table.insert(results, table.concat(currentPath, "."))
        end

        -- Recurse into tables
        if type(value) == "table" then
            deepSearchKeysPartial(value, targetKeyPart, currentPath, results, visited)
        end
    end

    return results
end


function Print(...)
    local args = {...}
    for _, v in ipairs(args) do
        if istable(v) then
            PrintTable(v)
        else
            print(v)
        end
    end
end
print2 = Print



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
	if not Bench then print("Error with Benchmark. Maybe the Init function was called before it existed?") return end
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

	local TimeTaken = Average / Bench.iterations

	if CLIENT then
		LocalPlayer():ChatPrint( "Client: " .. string.format( Output, id, TimeTaken ) )
	else
		print(string.format( Output, id, TimeTaken ))
		if IsValid(Entity(1)) then
			Entity(1):ChatPrint("Server: " .. string.format( Output, id, TimeTaken ))
		end
	end

	benchmarks[ id ] = nil

	return TimeTaken
end

function Props_Benchmark.CompareTimes( time1, time2 )
	local Output = "Benchmark one was different by about %f percent"

	local PercentDifference = (math.abs(time1 - time2) / ((time1 + time2) / 2)) * 100

	if CLIENT then
		LocalPlayer():ChatPrint( "Client: " .. string.format( Output, PercentDifference ) )
	else
		print(string.format( Output, PercentDifference ) )
		if IsValid(Entity(1)) then
			Entity(1):ChatPrint("Server: " .. string.format( Output, PercentDifference ) )
		end
	end
end
