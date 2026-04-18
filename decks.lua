--Adds credits for decks
--Minor change to src/credits.lua, adding arguments so I can define default colour as deck descriptions are on a white background

local PotatoPatchUtils_back_generate_UI = Back.generate_UI
function Back:generate_UI(other, ui_scale, min_dims, challenge)
	local original = PotatoPatchUtils_back_generate_UI(self, other, ui_scale, min_dims, challenge)
	local obj = other or self.effect.center
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