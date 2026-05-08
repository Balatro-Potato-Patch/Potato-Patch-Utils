--Adds credits for blinds

local PotatoPatchUtils_blind_popup = create_UIBox_blind_popup
function create_UIBox_blind_popup(blind, discovered, vars) --When hovered in collection
	local original = PotatoPatchUtils_blind_popup(blind, discovered, vars)
	local obj = blind
    local target = original.nodes

    local args = {}
    args.colour = G.C.UI.TEXT_DARK --fallback colour

    if obj and obj.ppu_team then
        local str = PotatoPatchUtils.CREDITS.generate_string(obj.ppu_team, 'ppu_team_credit', obj.mod.prefix, args)
        if str then
            table.insert(target, str)
        end
    end
    if obj and obj.ppu_artist then
        local str = PotatoPatchUtils.CREDITS.generate_string(obj.ppu_artist, 'ppu_art_credit', obj.mod.prefix, args)
        if str then
            table.insert(target, str)
        end
    end
    if obj and obj.ppu_coder then
        local str = PotatoPatchUtils.CREDITS.generate_string(obj.ppu_coder, 'ppu_code_credit', obj.mod.prefix, args)
        if str then
            table.insert(target, str)
        end
    end

    return original
end

local PotatoPatchUtils_blind_choice = create_UIBox_blind_choice
function create_UIBox_blind_choice(type, run_info) --When choosing blind/run info screen
    local original = PotatoPatchUtils_blind_choice(type, run_info)
    
    local blind_choice = {
        config = G.P_BLINDS[G.GAME.round_resets.blind_choices[type]],
    }

	local obj = blind_choice.config
    local target = original.nodes

    local args = {}
    args.colour = G.C.UI.TEXT_LIGHT --fallback colour

    if obj and obj.ppu_team then
        local str = PotatoPatchUtils.CREDITS.generate_string(obj.ppu_team, 'ppu_team_credit', obj.mod.prefix, args)
        if str then
            table.insert(target, str)
        end
    end
    if obj and obj.ppu_artist then
        local str = PotatoPatchUtils.CREDITS.generate_string(obj.ppu_artist, 'ppu_art_credit', obj.mod.prefix, args)
        if str then
            table.insert(target, str)
        end
    end
    if obj and obj.ppu_coder then
        local str = PotatoPatchUtils.CREDITS.generate_string(obj.ppu_coder, 'ppu_code_credit', obj.mod.prefix, args)
        if str then
            table.insert(target, str)
        end
    end

    return original
end

local PotatoPatchUtils_RawDeveloperString
PotatoPatchUtils_RawDeveloperString = function(developers, prefix, mod_prefix) --modified from credits function
    local amount = #developers
    local credit_string = localize(prefix)

    for i, name in ipairs(developers) do
        
        local dev = PotatoPatchUtils.Developers[mod_prefix .. '_' .. name] or PotatoPatchUtils.Teams[mod_prefix .. '_' .. name] or {}

        local loc = localize({type = 'name_text', key = dev.loc, set = 'PotatoPatch'})
        if loc ~= "ERROR" then 
            credit_string = credit_string .. loc
        else
            credit_string = credit_string .. dev.name
        end
        
        if i < amount then
            credit_string = credit_string .. localize(i+1 == amount and 'ppu_and_spacer' or 'ppu_comma_spacer')
        end
    end

    return credit_string
end

local PotatoPatchUtils_set_text = Blind.set_text
function Blind:set_text() --When facing a blind
    local original = PotatoPatchUtils_set_text(self)

    local obj = G.GAME.blind.config.blind

    local args = {}
    args.colour = G.C.UI.TEXT_LIGHT --fallback colour

    if obj and obj.ppu_team then
        self.loc_debuff_lines[#self.loc_debuff_lines + 1] = PotatoPatchUtils_RawDeveloperString(obj.ppu_team, 'ppu_team_credit', obj.mod.prefix)
    end
    if obj and obj.ppu_artist then
        self.loc_debuff_lines[#self.loc_debuff_lines + 1] = PotatoPatchUtils_RawDeveloperString(obj.ppu_artist, 'ppu_art_credit', obj.mod.prefix)
    end
    if obj and obj.ppu_coder then
        self.loc_debuff_lines[#self.loc_debuff_lines + 1] = PotatoPatchUtils_RawDeveloperString(obj.ppu_coder, 'ppu_code_credit', obj.mod.prefix)
    end
end