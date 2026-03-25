PotatoPatchUtils.CREDITS = {}

--#region Credits on Pop Up
PotatoPatchUtils.CREDITS.generate_string = function(developers, prefix, mod_prefix)
    if type(developers) ~= 'table' then return end

    local amount = #developers
    local credit_string = {n=G.UIT.R, config={align = 'tm'}, nodes={
                {n=G.UIT.R, config={align='cm'}, nodes={{n=G.UIT.T, config={text = localize(prefix), shadow = true, colour = G.C.UI.BACKGROUND_WHITE, scale = 0.27}}}}
            }}

    for i, name in ipairs(developers) do
        local target_row = math.ceil(i/3)
        local dev = PotatoPatchUtils.Developers[mod_prefix .. name] or PotatoPatchUtils.Teams[mod_prefix .. name] or {}
        if target_row > #credit_string.nodes then table.insert(credit_string.nodes, {n=G.UIT.R, config={align='cm'}, nodes ={}}) end
        table.insert(credit_string.nodes[target_row].nodes, {n=G.UIT.O, config = {object = DynaText({
                    string = dev.loc and localize(dev.loc, 'PotatoPatch') or dev.name or 'ERROR',
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
        local str = PotatoPatchUtils.CREDITS.generate_string(obj.ppu_team, 'ppu_team_credit', obj.mod.prefix)
        if str then
            table.insert(target, str)
        end
    end
    if obj and obj.ppu_artist then
        local str = PotatoPatchUtils.CREDITS.generate_string(obj.ppu_artist, 'ppu_art_credit', obj.mod.prefix)
        if str then
            table.insert(target, str)
        end
    end
    if obj and obj.ppu_coder then
        local str = PotatoPatchUtils.CREDITS.generate_string(obj.ppu_coder, 'ppu_code_credit', obj.mod.prefix)
        if str then
            table.insert(target, str)
        end
    end
    return ret_val
end
--#endregion

--#region Developer Objects
PotatoPatchUtils.Developers = {}
PotatoPatchUtils.Developer = Object:extend()
function PotatoPatchUtils.Developer:init(args)
    if args.name and not PotatoPatchUtils.Developers[SMODS.current_mod.prefix .. args.name] then -- Prevents duplicate developers from being created
        for k, v in pairs(args or {}) do
            self[k] = v
        end

        self.loc = args.loc and type(args.loc) == 'boolean' and 'PotatoPatchDev_' .. args.name or args.loc
        self.mod_id = SMODS.current_mod.id

        PotatoPatchUtils.Developers[SMODS.current_mod.prefix .. args.name] = self

        if args.team and PotatoPatchUtils.Teams[SMODS.current_mod.prefix .. args.team] then
            table.insert(PotatoPatchUtils.Teams[SMODS.current_mod.prefix .. args.team].members, self)
        end
    end
end

function PotatoPatchUtils.get_developers_scoring_targets()
    local ret = {}
    for _, dev in pairs(PotatoPatchUtils.Developers) do
        if dev.calculate and type(dev.calculate) == "function" then
            table.insert(ret, dev)
        end
    end
    return ret
end
--#endregion

--#region Team Objects
PotatoPatchUtils.Teams = {}
PotatoPatchUtils.Team = Object:extend()
function PotatoPatchUtils.Team:init(args)
    if args.name and not PotatoPatchUtils.Teams[SMODS.current_mod.prefix .. args.name] then -- Prevents duplicate teams from being created
        for k, v in pairs(args or {}) do
            self[k] = v
        end
        
        self.loc = args.loc and type(args.loc) == 'boolean' and 'PotatoPatchTeam_' .. args.name or args.loc
        self.members = {}
        self.mod_id = SMODS.current_mod.id

        PotatoPatchUtils.Teams[SMODS.current_mod.prefix .. args.name] = self
    end
end

function PotatoPatchUtils.get_teams_scoring_targets()
    local ret = {}
    for _, team in pairs(PotatoPatchUtils.Teams) do
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