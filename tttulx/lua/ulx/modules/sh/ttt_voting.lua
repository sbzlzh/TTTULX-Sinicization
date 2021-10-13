--[=[-------------------------------------------------------------------------------------------
¦                              Trouble in Terrorist Town Commands                              ¦
¦                                   By: Skillz and Bender180                                   ¦
¦                              +---------++---------++---------+                               ¦
¦                              ¦ +-+ +-+ ¦¦ +-+ +-+ ¦¦ +-+ +-+ ¦                               ¦
¦                              +-+ ¦ ¦ +-++-+ ¦ ¦ +-++-+ ¦ ¦ +-+                               ¦
¦----------------------------------¦ ¦--------¦ ¦--------¦ ¦-----------------------------------¦
¦----------------------------------¦ ¦--------¦ ¦--------¦ ¦-----------------------------------¦
¦----------------------------------+-+--------+-+--------+-+-----------------------------------¦
¦                  All code included is completely original or extracted                       ¦
¦            from the base ttt files that are provided with the ttt gamemode.                  ¦
¦                                                                                              ¦
---------------------------------------------------------------------------------------------]=]
local CATEGORY_NAME  = "TTT Í¶Æ±"
local gamemode_error = "µ±Ç°µÄÓÎÏ·Ä£Ê½ÔÚ×î¿Ö²ÀµÄ³ÇÕòÖÐ²¢²»Âé·³"


---[Next Round Slay Voting]----------------------------------------------------------------------------

local function voteslaynrDone2( t, target, time, ply, reason )
	
    local shouldslaynr = false
	
	if t.results[ 1 ] and t.results [ 1 ] > 0 then
		shouldslaynr = true
		if reason then
			ulx.fancyLogAdmin( ply, "#A ½«ÔÊÐí #T ÔÚÏÂÒ»ÂÖ±»É±ËÀ (#s)", target, reason )
		else
			ulx.fancyLogAdmin( ply, "#A ½«ÔÊÐí #T ÔÚÏÂÒ»ÂÖ±»É±ËÀ", target )
		end
	else
		ulx.fancyLogAdmin( ply, "#A ½«²»ÔÊÐíÔÚÏÂÒ»ÂÖÉ±ËÀ #T", target )
	end

	if shouldslaynr then
    	if not GetConVarString("gamemode") == "terrortown" then ULib.tsayError( calling_ply, gamemode_error, true ) else
            local target_ply = target:Nick()
            --ULib.consoleCommand( "ulx slaynr " ..target:Nick().. "\n" ) --has issue with players with spaces in name
            --going to write to pdata directly for more streamlined look
            
            local eslays = target:GetPData("slaynr_slays", 0) --get existing slays or 0
            local nslays
        
            nslays = eslays + 1 --add the vote slay to the existing slays
        
            target:SetPData("slaynr_slays", nslays) --add the new slays
            --heavy lifting will be done by existing slaynr command
                        
            target:ChatPrint("¸ù¾ÝÍ¶Æ±,Äã½«ÔÚÏÂÒ»ÂÖ±»É±")
        end
        
	end
end

local function voteslaynrDone( t, target, time, ply, reason)
	local results = t.results
	local winner
	local winnernum = 0
	for id, numvotes in pairs( results ) do
		if numvotes > winnernum then
			winner = id
			winnernum = numvotes
		end
	end
	
	local ratioNeeded = GetConVarNumber( "ulx_voteslaynrSuccessratio" )
	local minVotes = GetConVarNumber( "ulx_voteslaynrMinvotes" )
	local str
	if winner ~= 1 or winnernum < minVotes or winnernum / t.voters < ratioNeeded then
		str = "Í¶Æ±½á¹û:ÓÃ»§½«ÔÚÏÂÒ»ÂÖ´æ»î. (" .. (results[ 1 ] or "0") .. "/" .. t.voters .. ")"
	else
		str = "Í¶Æ±½á¹û:ÓÃ»§½«ÔÚÏÂÒ»ÂÖ±»É±ËÀ,µÈ´ýÅú×¼. (" .. winnernum .. "/" .. t.voters .. ")"
		ulx.doVote( "½ÓÊÜ½á¹û²¢É±ËÀ " .. target:Nick() .. "?", { "ÊÇ", "·ñ" }, voteslaynrDone2, 30000, { ply }, true, target, time, ply, reason )
	end
	
	ULib.tsay( _, str ) -- TODO, color?
	ulx.logString( str )
	if game.IsDedicated() then Msg( str .. "\n" ) end
end

function ulx.voteslaynr( calling_ply, target_ply, reason )
	if voteInProgress then
		ULib.tsayError( calling_ply, "ÒÑ¾­ÓÐÍ¶Æ±ÕýÔÚ½øÐÐÖÐ¡£ÇëµÈ´ýµ±Ç°µÄ½áÊø.", true )
		return
	end

	local msg = "É±ËÀ " .. target_ply:Nick() .. " ÏÂ»ØºÏ?"
	if reason and reason ~= "" then
		msg = msg .. " (" .. reason .. ")"
	end

	ulx.doVote( msg, { "Yes", "No" }, voteslaynrDone, _, _, _, target_ply, time, calling_ply, reason )
	ulx.fancyLogAdmin( calling_ply, "#A ÏëÔÚÏÂÒ»ÂÖÉ±ËÀ #T", target_ply )
end

local voteslaynr = ulx.command( CATEGORY_NAME, "ulx votesnr", ulx.voteslaynr, "!votesnr" )
voteslaynr:addParam{ type=ULib.cmds.PlayerArg }
voteslaynr:addParam{ type=ULib.cmds.StringArg, hint="Ô­Òò", ULib.cmds.optional, ULib.cmds.takeRestOfLine}
voteslaynr:defaultAccess( ULib.ACCESS_ADMIN )
voteslaynr:help( "¿ªÊ¼Í¶Æ±ÒÔÔÚÏÂÒ»ÂÖÉ±ËÀÄ¿±ê." )
if SERVER then ulx.convar( "voteslaynrSuccessratio", "0.6", _, ULib.ACCESS_ADMIN ) end -- The ratio needed for a voteslaynr to succeed
if SERVER then ulx.convar( "voteslaynrMinvotes", "1", _, ULib.ACCESS_ADMIN ) end -- Minimum votes needed for voteslaynr

---[Spectator Voting]----------------------------------------------------------------------------

local function votefsDone2( t, target, time, ply, reason )
	
    local shouldfs = false
	
	if t.results[ 1 ] and t.results [ 1 ] > 0 then
		shouldfs = true
			ulx.fancyLogAdmin( ply, "#A ½«ÔÊÐí #T ±»ÆÈÅÔ¹Û.", target )
	else
		ulx.fancyLogAdmin( ply, "#A ²»ÔÊÐí #T ±»ÆÈÅÔ¹Û.", target )
	end

	if shouldfs then
    	if not GetConVarString("gamemode") == "terrortown" then ULib.tsayError( calling_ply, gamemode_error, true ) else
            target:ConCommand("ttt_spectator_mode 1")
			target:ConCommand("ttt_cl_idlepopup")
        end
        
	end
end

local function votefsDone( t, target, time, ply, reason)
	local results = t.results
	local winner
	local winnernum = 0
	for id, numvotes in pairs( results ) do
		if numvotes > winnernum then
			winner = id
			winnernum = numvotes
		end
	end
	
	local ratioNeeded = GetConVarNumber( "ulx_votefsSuccessratio" )
	local minVotes = GetConVarNumber( "ulx_votefsMinvotes" )
	local str
	if winner ~= 1 or winnernum < minVotes or winnernum / t.voters < ratioNeeded then
		str = "Í¶Æ±½á¹û:ÓÃ»§½«±»·¢ËÍµ½¹ÛÖÚ. (" .. (results[ 1 ] or "0") .. "/" .. t.voters .. ")"
	else
		str = "Í¶Æ±½á¹û:ÓÃ»§½«±»·¢ËÍ¸øÅÔ¹ÛÕß,µÈ´ýÅú×¼. (" .. winnernum .. "/" .. t.voters .. ")"
		ulx.doVote( "½ÓÊÜ½á¹û²¢·¢ËÍ " .. target:Nick() .. " µ½¹ÛÖÚ?", { "ÊÇ", "·ñ" }, votefsDone2, 30000, { ply }, true, target, time, ply, reason )
	end
	
	ULib.tsay( _, str ) -- TODO, color?
	ulx.logString( str )
	if game.IsDedicated() then Msg( str .. "\n" ) end
end

function ulx.votefs( calling_ply, target_ply, reason )
	if voteInProgress then
		ULib.tsayError( calling_ply, "ÒÑ¾­ÓÐÍ¶Æ±ÕýÔÚ½øÐÐÖÐ.ÇëµÈ´ýµ±Ç°µÄ½áÊø.", true )
		return
	end

	local msg = "Force " .. target_ply:Nick() .. " µ½¹ÛÖÚ?"
	if reason and reason ~= "" then
		msg = msg .. " (" .. reason .. ")"
	end

	ulx.doVote( msg, { "ÊÇ", "·ñ" }, votefsDone, _, _, _, target_ply, time, calling_ply, reason )
	ulx.fancyLogAdmin( calling_ply, "#A ÏëÈÃ #T ³ÉÎªÅÔ¹ÛÕß.", target_ply )
end

local votefs = ulx.command( CATEGORY_NAME, "ulx votefs", ulx.votefs, "!votefs" )
votefs:addParam{ type=ULib.cmds.PlayerArg }
votefs:addParam{ type=ULib.cmds.StringArg, hint="Ô­Òò", ULib.cmds.optional, ULib.cmds.takeRestOfLine}
votefs:defaultAccess( ULib.ACCESS_ADMIN )
votefs:help( "¿ªÊ¼Í¶Æ±ÈÃÄ¿±êÇ¿ÖÆ½øÈëÅÔ¹ÛÕßÄ£Ê½." )
if SERVER then ulx.convar( "votefsSuccessratio", "0.6", _, ULib.ACCESS_ADMIN ) end -- The ratio needed for a votefs to succeed
if SERVER then ulx.convar( "votefsMinvotes", "1", _, ULib.ACCESS_ADMIN ) end -- Minimum votes needed for votefs
