PotatoPatchUtils.CREDITS = {}

PotatoPatchUtils.CREDITS.generate_string = function(developers, prefix)
    if type(developers) ~= 'table' then return end

    local amount = #developers
    local credit_string = {n=G.UIT.R, config={align = 'tm'}, nodes={
                {n=G.UIT.R, config={align='cm'}, nodes={{n=G.UIT.T, config={text = localize(prefix), shadow = true, colour = G.C.UI.BACKGROUND_WHITE, scale = 0.27}}}}
            }}

    for i, name in ipairs(developers) do
        local target_row = math.ceil(i/3)
        local dev = PotatoPatchUtils.Developers[name] or {}
        if target_row > #credit_string.nodes then table.insert(credit_string.nodes, {n=G.UIT.R, config={align='cm'}, nodes ={}}) end
        table.insert(credit_string.nodes[target_row].nodes, {n=G.UIT.O, config = {object = DynaText({
                    string = dev.loc and localize(dev.loc) or dev.name or name,
                    colours = { dev and dev.colour or G.C.UI.BACKGROUND_WHITE }, scale = 0.27,
                    silent = true, shadow = true, y_offset = -0.6, 
                })
            }
        })
        if i < amount then
            table.insert(credit_string.nodes[target_row].nodes, {n=G.UIT.T, config = {text = localize(i+1 == amount and 'ppu_and_spacer' or 'ppu_comma_spacer'), shadow = true, colour = G.C.UI.BACKGROUND_WHITE, scale = 0.27 } })
        end
    end

    return credit_string
end

local PotatoPatchUtils_card_popup = G.UIDEF.card_h_popup
function G.UIDEF.card_h_popup(card)
    local ret_val = PotatoPatchUtils_card_popup(card)
    local obj = card.config.center
    local target = ret_val.nodes[1].nodes[1].nodes[1].nodes
    if obj and obj.artist then
        local str = PotatoPatchUtils.CREDITS.generate_string(obj.artist, 'ppu_art_credit')
        if str then
            table.insert(target, str)
        end
    end
    if obj and obj.coder then
        local str = PotatoPatchUtils.CREDITS.generate_string(obj.coder, 'ppu_code_credit')
        if str then
            table.insert(target, str)
        end
    end
    return ret_val
end

if TMJ then
    local function get(x)
        return type(x) == 'table' and unpack(x) or unpack {}
    end
    TMJ.SEARCH_FIELD_FUNCS[#TMJ.SEARCH_FIELD_FUNCS+1] = function(center)
        return {get(center.coder), get(center.artist)}
    end
end

PotatoPatchUtils.Developers = {internal_count = 0}
    PotatoPatchUtils.Developer = Object:extend()
    function PotatoPatchUtils.Developer:init(args)
        self.name = args.name
        self.colour = args.colour
        self.loc = args.loc and type(args.loc) == 'boolean' and 'PotatoPatchDev_'..args.name or args.loc
        
        PotatoPatchUtils.Developers[args.name] = self
        PotatoPatchUtils.Developers.internal_count = PotatoPatchUtils.Developers.internal_count + 1
    end
