PotatoPatchUtils.CREDITS = {}

--#region Credits on Pop Up
PotatoPatchUtils.CREDITS.generate_string = function(developers, prefix, mod_prefix)
    if type(developers) ~= 'table' then return end

    if prefix == 'ppu_team_credit' then
        for _, name in ipairs(developers) do
            if PotatoPatchUtils.Teams[mod_prefix .. '_' .. name].short_credit then
                prefix = prefix .. '_short'
                break
            end
        end
    end

    local amount = #developers
    local credit_string = {n=G.UIT.R, config={align = 'tm'}, nodes={
                {n=G.UIT.R, config={align='cm'}, nodes={{n=G.UIT.T, config={text = localize(prefix), shadow = true, colour = G.C.UI.BACKGROUND_WHITE, scale = 0.27}}}}
            }}

    for i, name in ipairs(developers) do
        local target_row = math.ceil(i/3)
        local dev = PotatoPatchUtils.Developers[mod_prefix .. '_' .. name] or PotatoPatchUtils.Teams[mod_prefix .. '_' .. name] or {}
        if target_row > #credit_string.nodes then table.insert(credit_string.nodes, {n=G.UIT.R, config={align='cm'}, nodes ={}}) end
        table.insert(credit_string.nodes[target_row].nodes, {n=G.UIT.O, config = {object = DynaText({
                    string = dev.loc and localize({type = 'name_text', key = dev.loc, set = 'PotatoPatch'}) or dev.name or 'ERROR',
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
    local obj = card.config.center or card.config.tag and SMODS.Tags[card.config.tag.key]
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

local PotatoPatchUtils_create_UIBox_blind_popup = create_UIBox_blind_popup
function create_UIBox_blind_popup(blind, discovered, vars)
    local ret_val = PotatoPatchUtils_create_UIBox_blind_popup(blind, discovered, vars)
    local obj = blind
    local target = ret_val.nodes
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

        PotatoPatchUtils.Developers[SMODS.current_mod.prefix .. '_' .. args.name] = self

        if args.team and PotatoPatchUtils.Teams[SMODS.current_mod.prefix .. '_' .. args.team] then
            table.insert(PotatoPatchUtils.Teams[SMODS.current_mod.prefix .. '_' .. args.team].members, self)
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
    if args.name and not PotatoPatchUtils.Teams[SMODS.current_mod.prefix .. '_' .. args.name] then -- Prevents duplicate teams from being created
        for k, v in pairs(args or {}) do
            self[k] = v
        end
        
        self.loc = args.loc and type(args.loc) == 'boolean' and 'PotatoPatchTeam_' .. args.name or args.loc
        self.members = {}
        self.mod_id = SMODS.current_mod.id

        PotatoPatchUtils.Teams[SMODS.current_mod.prefix .. '_' .. args.name] = self

        SMODS.Attribute {
            key = SMODS.current_mod.prefix .. '_' .. args.name
        }
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

-- Add loaded game object to attribute if it has matching team


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

--#region Automatic Credit Page
function PotatoPatchUtils.CREDITS.create_credit_tab(mod)
    local mod_teams = {}
    for _, team in pairs(PotatoPatchUtils.Teams) do
        if team.mod_id == mod.id then
            table.insert(mod_teams, team)
        end
    end

    return {n = G.UIT.ROOT, config = { align = "m", r = 0.1, padding = 0.05, colour = G.C.BLACK, minw = 8, minh = 9 }, nodes = {
        {n=G.UIT.C, config = {align = 'cm', id = 'ppu_credits_page_nodes', teams = mod_teams, current_team = 1}, nodes = {
            next(mod_teams) and PotatoPatchUtils.CREDITS.create_team_credit_page(mod_teams[1]),
        }}
    }}
end

SMODS.draw_ignore_keys.ppu_floating_sprite = true
SMODS.DrawStep {
    key = 'ppu_floating_sprite',
    order = 60,
    func = function(self)
        if self.children.ppu_floating_sprite then
            local scale_mod = 0.07 + 0.02*math.sin(1.8*G.TIMERS.REAL) + 0.00*math.sin((G.TIMERS.REAL - math.floor(G.TIMERS.REAL))*math.pi*14)*(1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL)))^3
            local rotate_mod = 0.05*math.sin(1.219*G.TIMERS.REAL) + 0.00*math.sin((G.TIMERS.REAL)*math.pi*5)*(1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL)))^2

            self.children.ppu_floating_sprite:draw_shader('dissolve',0, nil, nil, self.children.center,scale_mod, rotate_mod,nil, 0.1 + 0.03*math.sin(1.8*G.TIMERS.REAL),nil, 0.6)
            self.children.ppu_floating_sprite:draw_shader('dissolve', nil, nil, nil, self.children.center, scale_mod, rotate_mod)
            
        end
    end,
    conditions = { vortex = false, facing = 'front' },
}

function PotatoPatchUtils.CREDITS.create_team_credit_page(team)
    local members = team.members
    local areas = {}
    if PotatoPatchUtils.CREDITS.AREAS then
        for _, area in ipairs(PotatoPatchUtils.CREDITS.AREAS) do
            area:remove()
        end
    end

    PotatoPatchUtils.CREDITS.AREAS = {}
    PotatoPatchUtils.CREDITS.NODES = {}

    for i, member in ipairs(members) do
        PotatoPatchUtils.CREDITS.AREAS[i] = CardArea(G.ROOM.T.x, G.ROOM.T.y, G.CARD_W / 1.25, G.CARD_H / 1.25, {type = 'title_2', card_limit = 1, highlight_limit = 0})
        local card = Card(G.ROOM.T.x, G.ROOM.T.y, G.CARD_W / 1.25, G.CARD_H / 1.25, nil, G.P_CENTERS.c_base)
        card.children.center:remove()
        card.children.center = SMODS.create_sprite(card.T.x, card.T.y, card.T.w, card.T.h, member.atlas or "Joker", member.pos or {x = 0, y = 0})
        if member.soul_pos then
            card.children.ppu_floating_sprite = SMODS.create_sprite(card.T.x, card.T.y, card.T.w, card.T.h, member.atlas or "Joker", member.soul_pos)
            card.children.ppu_floating_sprite.role.draw_major = card
            card.children.ppu_floating_sprite.states.hover.can = false
            card.children.ppu_floating_sprite.states.click.can = false
        end
        PotatoPatchUtils.CREDITS.AREAS[i]:emplace(card)
		
		-- Attach member information to the card
		card.ppu_member = member

		-- Create tooltip
		card.hover = function(self)
			local info_nodes = {n = G.UIT.R, config = { align = "cm", padding = 0, colour = G.C.CLEAR }, nodes = {
                {n = G.UIT.C, config = { align = "cm", padding = 0.2 }, nodes = {}},
            }}
            local text = member.loc and G.localization.descriptions.PotatoPatch[member.loc].text_parsed or nil
			if text then
                if not text[1][1][1] then text = {text} end
                for _, box in ipairs(text) do
                    local node = {n=G.UIT.R, config = {colour = G.C.L_BLACK, r=0.1, padding = 0.15, align = 'cm', shadow = true}, nodes = {}}
                    for _, v in ipairs(box) do
                        table.insert(node.nodes, {n=G.UIT.R, config={align='cm'}, nodes = SMODS.localize_box(v, {text_colour = G.C.UI.TEXT_LIGHT})})
                    end
                    info_nodes.nodes[1].nodes[#info_nodes.nodes[1].nodes + 1] = {n=G.UIT.R, config = {align = 'cm'}, nodes = {{n=G.UIT.C, config = {align = 'cm', colour = G.C.WHITE, r=0.1, padding = 0.025}, nodes = {node}}}}
                end
			end
			self:juice_up(0.05, 0.03)
			play_sound('paper1', math.random() * 0.2 + 0.9, 0.35)
			card.config.h_popup = info_nodes
			card.config.h_popup_config = self:align_h_popup()
			Moveable.hover(self)
		end

        local name = {}
        localize({ type = 'name', set = 'PotatoPatch', key = member.loc, nodes = name, scale = 0.8, maxw = 2, text_colour = member.colour, stylize = true, no_shadow = true, no_pop_in = true, no_bump = true, no_silent = true, no_spacing = true})
        name = name[1] and name[1][1] or {n=G.UIT.T, config={scale = 0.47, colour = member.colour, text = member.name}}

        PotatoPatchUtils.CREDITS.NODES[i] = {n = G.UIT.C, config = { align = "cm", id = "ppu_credit_node_" .. member.name }, nodes = {
            {n = G.UIT.C, config = {r = 0.2, align = "cm", padding = 0.125, colour = G.C.L_BLACK, minw = G.CARD_W / 1.2 + 0.2, minh = G.CARD_H * 1.2}, nodes = {
                {n = G.UIT.C, config = {r = 0.2, align = "tm", padding = 0.1, colour = G.C.BLACK, minw = G.CARD_W / 1.2, minh = G.CARD_H}, nodes = {
                    {n = G.UIT.R, config = {align = "cm"}, nodes = {name}},
                    {n = G.UIT.R, config = {align = "cm"}, nodes = {
                        {n = G.UIT.O, config = {object =  PotatoPatchUtils.CREDITS.AREAS[i]}}
                    }}
                }}
            }}
        }}
        card.states.drag.can = false
    end

    local max_columns = 1
	local row_size = team.credit_rows or {5, 5} 
	local row = 1
	local table_nodes = {}

	for i = 1, #row_size do
		table_nodes[#table_nodes + 1] = {
			n = G.UIT.R,
			config = { align = "cm", padding = 0.1 },
			nodes = {}
		}
	end

	local count = 1
	for _, node in ipairs(PotatoPatchUtils.CREDITS.NODES) do
		if count > row_size[row] then
			count = 1
			row = row + 1
            if row > #row_size then break end
		end
		count = count + 1
		table_nodes[row].nodes[#table_nodes[row].nodes + 1] = node
	end

    local team_name = {}
    localize({ type = 'name', set = 'PotatoPatch', key = team.loc, nodes = team_name, maxw = 7, scale = 1.3, text_colour = team.colour, stylize = true, no_shadow = true, no_pop_in = true, no_bump = true, no_silent = true, no_spacing = true})
    team_name = team_name[1] and team_name[1][1] or {n=G.UIT.C, config = {}, nodes = {{n=G.UIT.T, config={scale = 0.65, colour = team.colour, text = team.name}}}}
    team_name.config.minw = 7
    team_name.config.align = 'cm'


	-- create a card for this member
	return {
		n = G.UIT.R,
		config = { minw = 13, colour = G.C.CLEAR, align = "cm", id = "ppu_credits_page" },
		nodes = {
            {n=G.UIT.C, config = {align = 'cm', padding = 0.1}, nodes = {
                {n=G.UIT.R, config = {align = #row_size == 1 and 'cm' or 'tm', minh = 8, padding = 0.1}, nodes = table_nodes},
                {n=G.UIT.R, config = {align = 'cm', padding = 0.1}, nodes = {
                    {n=G.UIT.C, config = {minw = 0.7, minh = 0.7, align = 'cm', r = 0.1, colour = G.C.RED, hover = true, button = 'ppu_toggle_credit_page', change = -1, shadow = true}, nodes = {
                        {n=G.UIT.T, config = {text = '<', scale = 0.5, colour = G.C.WHITE}}
                    }},
                    {n=G.UIT.C, config = {minw = 0.7, colour = G.C.CLEAR}},
                    team_name,
                    {n=G.UIT.C, config = {minw = 0.7, colour = G.C.CLEAR}},
                    {n=G.UIT.C, config = {minw = 0.7, minh = 0.5, align = 'cm', r = 0.1, colour = G.C.RED, hover = true, button = 'ppu_toggle_credit_page', change = 1, shadow = true}, nodes = {
                        {n=G.UIT.T, config = {text = '>', scale = 0.5, colour = G.C.WHITE}}
                    }},
                }},
            }}
        }
	}
end

function G.FUNCS.ppu_toggle_credit_page(e)
	if not e then return end
	local credit_nodes = G.OVERLAY_MENU:get_UIE_by_ID("ppu_credits_page_nodes")
	if credit_nodes then
        local teams = credit_nodes.config.teams
        local new_selection = (credit_nodes.config.current_team + e.config.change - 1) % #teams + 1
        -- if new_selection > #teams then new_selection = 1 elseif new_selection == 0 then new_selection = #teams end
        credit_nodes:remove()
        local uibox = PotatoPatchUtils.CREDITS.create_team_credit_page(teams[new_selection])
        credit_nodes.config.current_team = new_selection
		credit_nodes.UIBox:add_child(uibox, credit_nodes)
		credit_nodes.UIBox:recalculate()
	end
end

function PotatoPatchUtils.CREDITS.register_page(mod)
    return function()
        return{
            tab_definition_function = function()
                return PotatoPatchUtils.CREDITS.create_credit_tab(mod)
            end,
            label = localize('ppu_credits_tab_label')
        } 
    end
end
--#endregion

--#region JimboQuip stuff

local floating_sprite_draw_ref = SMODS.DrawSteps["floating_sprite"].func
SMODS.DrawSteps["floating_sprite"].func = function(self, layer)
	floating_sprite_draw_ref(self, layer)
	if self.is_dev_quip_sprite then
		local scale_mod = 0.07
			+ 0.02 * math.sin(1.8 * G.TIMERS.REAL)
			+ 0.00
				* math.sin((G.TIMERS.REAL - math.floor(G.TIMERS.REAL)) * math.pi * 14)
				* (1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL))) ^ 3
		local rotate_mod = 0.05 * math.sin(1.219 * G.TIMERS.REAL)
			+ 0.00 * math.sin(G.TIMERS.REAL * math.pi * 5) * (1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL))) ^ 2
		if self.children.floating_sprite then
			self.children.floating_sprite:draw_shader(
				"dissolve",
				0,
				nil,
				nil,
				self.children.center,
				scale_mod,
				rotate_mod,
				nil,
				0.1 + 0.03 * math.sin(1.8 * G.TIMERS.REAL),
				nil,
				0.6
			)
			self.children.floating_sprite:draw_shader(
				"dissolve",
				nil,
				nil,
				nil,
				self.children.center,
				scale_mod,
				rotate_mod
			)
		end
	end
end

--#endregion