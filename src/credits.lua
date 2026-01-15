PotatoPatchUtils.CREDITS = {}

--#region Credits on Pop Up
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
    if obj and obj.ppu_team then
        local str = PotatoPatchUtils.CREDITS.generate_string(obj.ppu_team, 'ppu_team_credit')
        if str then
            table.insert(target, str)
        end
    end
    if obj and obj.ppu_artist then
        local str = PotatoPatchUtils.CREDITS.generate_string(obj.ppu_artist, 'ppu_art_credit')
        if str then
            table.insert(target, str)
        end
    end
    if obj and obj.ppu_coder then
        local str = PotatoPatchUtils.CREDITS.generate_string(obj.ppu_coder, 'ppu_code_credit')
        if str then
            table.insert(target, str)
        end
    end
    return ret_val
end
--#endregion

--#region Developer Objects
PotatoPatchUtils.Developers = { internal_count = 0 }
PotatoPatchUtils.Developer = Object:extend()
function PotatoPatchUtils.Developer:init(args)
    if args.ppu_name and not PotatoPatchUtils.Developers[args.ppu_name] then -- Prevents duplicate developers from being created
        self.name = args.ppu_name
        self.colour = args.colour
        self.loc = args.loc and type(args.loc) == 'boolean' and 'PotatoPatchDev_' .. args.ppu_name or args.loc

        PotatoPatchUtils.Developers[args.ppu_name] = self
        PotatoPatchUtils.Developers.internal_count = PotatoPatchUtils.Developers.internal_count + 1
    end
end

function PotatoPatchUtils.get_developers_scoring_targets()
    local ret = {}
    for _, dev in ipairs(PotatoPatchUtils.Developers) do
        if dev.calculate and type(dev.calculate) == "function" then
            table.insert(ret, dev)
        end
    end
    return ret
end
--#endregion

--#region Team Objects
PotatoPatchUtils.Teams = { internal_count = 0 }
PotatoPatchUtils.Team = Object:extend()
function PotatoPatchUtils.Developer:init(args)
    if args.ppu_name and not PotatoPatchUtils.Teams[args.ppu_name] then -- Prevents duplicate teams from being created
        self.name = args.ppu_name
        self.colour = args.colour
        self.loc = args.loc and type(args.loc) == 'boolean' and 'PotatoPatchDev_' .. args.ppu_name or args.loc

        PotatoPatchUtils.Teams[args.ppu_name] = self
        PotatoPatchUtils.Teams.internal_count = PotatoPatchUtils.Teams.internal_count + 1
    end
end

function PotatoPatchUtils.get_teams_scoring_targets()
    local ret = {}
    for _, team in ipairs(PotatoPatchUtils.Teams) do
        if team.calculate and type(team.calculate) == "function" then
            table.insert(ret, team)
        end
    end
    return ret
end
--#endregion

--#region TMJ Compat
if TMJ then
    local function get(x)
        return type(x) == 'table' and unpack(x) or unpack {}
    end
    TMJ.SEARCH_FIELD_FUNCS[#TMJ.SEARCH_FIELD_FUNCS + 1] = function(center)
        return { get(center.ppu_coder), get(center.ppu_artist), get(center.ppu_team) }
    end
end
--#endregion
