--------------------
-- Author: IIYAMA (Updated by Kenix) --
--------------------

local addEventHandler 		= addEventHandler;
local removeEventHandler 	= removeEventHandler;
local table_remove			= table.remove;
local unpack				= unpack;
local len					= table.getn;
local root					= root;

local renderEvents = {
	"onClientRender",
	"onClientPreRender",
	"onClientHUDRender"
}

local allTargetFunctions = {} -- All attached functions will be stored in this table.

local acceptedRenderEventTypes = {} -- Is type in use? See: renderEvents.
local renderEventTypeStatus = {} -- Is the event in use? (so it doesn't have to be attached again)

do
	-- prepare the data
	for i=1, len( renderEvents ) do
		local event = renderEvents[i]
		allTargetFunctions[event] = {}
		acceptedRenderEventTypes[event] = true
		renderEventTypeStatus[event] = false
	end
end

-- render all events here
local processTargetFunction = function ( timeSlice )
	local targetFunctions = allTargetFunctions[ eventName ]
	
	for i = 1, len( targetFunctions ) do
		local targetFunctionData = targetFunctions[i]
		local arguments = targetFunctionData[2]
		
		if not arguments then
			targetFunctionData[ 1 ]( timeSlice )
		else
			if timeSlice then
				targetFunctionData[ 1 ]( timeSlice, unpack( arguments ) )
			else
				targetFunctionData[ 1 ]( unpack( arguments ) )
			end
		end
	end
end


-- check if a function is already attached
local checkIfFunctionIsTargetted = function (theFunction, event)
	if not event or not acceptedRenderEventTypes[event] then
		event = "onClientRender"
	end
	
	local targetFunctions = allTargetFunctions[event]
	
	for i = 1, len( targetFunctions ) do
		if targetFunctions[i][1] == theFunction then
			return true
		end
	end
	
	return false
end

-- add render event, default type is onClientRender
function addRenderEvent(theFunction, event, ...)
	if not event or not acceptedRenderEventTypes[event] then
		event = "onClientRender"
	end
	
	if not checkIfFunctionIsTargetted(theFunction) then
		local targetFunctions = allTargetFunctions[event]
		
		-- Don't pass an arguments if it not needed.
		local aArgs = { ... };
		local mArgs = len( aArgs ) > 0 and aArgs or nil;
		
		targetFunctions[ len( targetFunctions ) + 1 ] = { theFunction, mArgs }
		
		-- attach an event
		if not renderEventTypeStatus[event] then
			addEventHandler (event, root, processTargetFunction, false, "high")
			renderEventTypeStatus[event] = true
		end
		
		return true
	end
	
	return false
end

-- remove a render event
function removeRenderEvent(theFunction, event)
	if not event or not acceptedRenderEventTypes[event] then
		event = "onClientRender"
	end
	
	local targetFunctions = allTargetFunctions[event]
	
	local i = 1;
	
	repeat
		if targetFunctions[i][1] == theFunction then
			table_remove(targetFunctions, i)
			
			if len( targetFunctions ) == 0 then
				if renderEventTypeStatus[event] then
					removeEventHandler (event, root, processTargetFunction)
					renderEventTypeStatus[event] = false
				end
			end
			
			return true
		else
			i = i + 1;
		end
	until not targetFunctions[i];
	
	return false
end
