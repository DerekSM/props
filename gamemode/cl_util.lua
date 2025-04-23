--[[
				  _________.__    .__                                  
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     / 
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/  
						\/      \/        \/\/         \/              

		Clientside utilities
]]--
local string = string

	-- 900 in this example is what my ScrH was in developing
	--	ScrH() - 170
	
	-- example usage:
	--	GetUniversalSize( 900 - 170 )
	--
	--		Does this: (900 - 170) / 900
	--		returns a number: 0.8111
	--		then use that number in your final:
	--			ScrH() or ScrW() * sizereturned
function GetUniversalSize( difference, scrsize )
	return (scrsize - difference) / scrsize
end

function FixLongName( str, maxlength )
	if #tostring(str) > maxlength then
		str = string.sub( str, 1, maxlength ) .. "..."
	end

	return str
end

-- https://gist.github.com/DarkWiiPlayer/a6496cbce062ebe5d534e4b881d4efef
-- select keyword is generally faster for low-ish amounts of concatenations.
function table.FastConcat( str_Separator, ... )
	local Pre = {}
	local select = select
	for i=1,select("#", ...) do
		Pre[#Pre + 1] = select(i, ...)
	end

	return table.concat(Pre, str_Separator)
end
