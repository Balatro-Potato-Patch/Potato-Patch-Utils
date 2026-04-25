--Adds credits for decks
--Rebuild the deck UI each time an arrow button is clicked, placing the credits underneath the white region

G.FUNCS.overlay_menu  = function(args)
  if not args then return end
  --Remove any existing overlays if there is one
  if G.OVERLAY_MENU then G.OVERLAY_MENU:remove() end
  G.CONTROLLER.locks.frame_set = true
  G.CONTROLLER.locks.frame = true
  G.CONTROLLER.cursor_down.target = nil
  G.CONTROLLER:mod_cursor_context_layer(G.NO_MOD_CURSOR_STACK and 0 or 1)

  args.config = args.config or {}
  args.config = {
    align = args.config.align or "cm",
    offset = args.config.offset or {x=0,y=10},
    major = args.config.major or G.ROOM_ATTACH,
    bond = 'Weak',
    no_esc = args.config.no_esc
  }
  G.OVERLAY_MENU = true
  --Generate the UIBox
  G.OVERLAY_MENU = UIBox{
    definition = args.definition,
    config = args.config
  }

  --Set the offset and align. The menu overlay can be initially offset in the y direction and this will ensure it slides to middle
  G.OVERLAY_MENU.alignment.offset.y = 0
  if not args.no_jiggle then G.ROOM.jiggle = G.ROOM.jiggle + 1 end --add args.no_jiggle to stop the room from shaking, probably should be done via patching
  G.OVERLAY_MENU:align_to_major()
end

--Collection

function create_UIBox_your_collection_decks(center)
    center = center or G.P_CENTERS.b_red
  G.GAME.viewed_back = Back(center)
  
  local area = CardArea(
    G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
    1.2*G.CARD_W,
    1.2*G.CARD_H, 
    {card_limit = 52, type = 'deck', highlight_limit = 0})

  for i = 1, 52 do
    local card = Card(G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h, G.CARD_W*1.2, G.CARD_H*1.2, pseudorandom_element(G.P_CARDS), G.P_CENTERS.c_base, {playing_card = i, viewed_back = true})
    card.sprite_facing = 'back'
    card.facing = 'back'
    area:emplace(card)
    if i == 52 then G.sticker_card = card; card.sticker = get_deck_win_sticker(G.GAME.viewed_back.effect.center) end
  end

  local i = 1
  local current_option = 1

  local ordered_names = {}
  for k, v in ipairs(G.P_CENTER_POOLS.Back) do
    ordered_names[#ordered_names+1] = v.name
    if v.key == center.key then current_option = i end
    i = i + 1
  end

  local obj = G.GAME.viewed_back.effect.center
  
  local t = create_UIBox_generic_options({ back_func = 'your_collection', contents = {
    create_option_cycle({options = ordered_names, opt_callback = 'change_viewed_back_collection', current_option = current_option, colour = G.C.RED, w = 4.5, focus_args = {snap_to = true}, mid = 
            {n=G.UIT.R, config={align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes={
              {n=G.UIT.R, config={align = "cm", padding = 0.2, colour = G.C.BLACK, r = 0.2}, nodes={
                {n=G.UIT.C, config={align = "cm", padding = 0}, nodes={
                  {n=G.UIT.O, config={object = area}}
                }},
                {n=G.UIT.C, config={align = "tm", minw = 3.7, minh = 2.1, r = 0.1, colour = G.C.L_BLACK, padding = 0.1}, nodes={
                  {n=G.UIT.R, config={align = "cm", emboss = 0.1, r = 0.1, minw = 4, maxw = 4, minh = 0.6}, nodes={
                    {n=G.UIT.O, config={id = nil, func = 'RUN_SETUP_check_back_name', object = Moveable()}},
                  }},
                  {n=G.UIT.R, config={align = "cm", colour = G.C.WHITE, emboss = 0.1, minh = 2.2, r = 0.1}, nodes={
                    {n=G.UIT.O, config={id = G.GAME.viewed_back.name, func = 'RUN_SETUP_check_back', object = UIBox{definition = G.GAME.viewed_back:generate_UI(), config = {offset = {x=0,y=0}}}}}
                  }},
                  obj and obj.ppu_team and PotatoPatchUtils.CREDITS.generate_string(obj.ppu_team, 'ppu_team_credit', obj.mod.prefix, args),
                  obj and obj.ppu_artist and PotatoPatchUtils.CREDITS.generate_string(obj.ppu_artist, 'ppu_art_credit', obj.mod.prefix, args),
                  obj and obj.ppu_coder and PotatoPatchUtils.CREDITS.generate_string(obj.ppu_coder, 'ppu_code_credit', obj.mod.prefix, args),
                }},
              }},
            }}}),
          }})
  return t
end

G.FUNCS.change_viewed_back_collection = function(args)
    G.viewed_stake = G.viewed_stake or 1
    G.GAME.viewed_back:change_to(G.P_CENTER_POOLS.Back[args.to_key])
    if G.sticker_card then G.sticker_card.sticker = get_deck_win_sticker(G.GAME.viewed_back.effect.center) end
    local max_stake = get_deck_win_stake(G.GAME.viewed_back.effect.center.key) or 0
    G.viewed_stake = math.min(G.viewed_stake, max_stake + 1)
    G.PROFILES[G.SETTINGS.profile].MEMORY.deck = args.to_val
    local center = G.GAME.viewed_back.effect.center
    G.FUNCS.overlay_menu{
        definition = create_UIBox_your_collection_decks(center),
        config = {offset = {x = 0, y = 0}}, --keep the menu centered when switching between decks
        no_jiggle = true                    --and don't shake the room
    }
end

--Run setup

PotatoPatchUtils_run_setup_config = nil --stores "from_game_over", "from_game_won" etc

G.FUNCS.setup_run = function(e)
  G.SETTINGS.paused = true
  PotatoPatchUtils_run_setup_config = e.config.id --store this for later
  G.FUNCS.overlay_menu{
    definition = G.UIDEF.run_setup((e.config.id == 'from_game_over' or e.config.id == 'from_game_won' or e.config.id == 'challenge_list') and e.config.id),
  }
  if (e.config.id == 'from_game_over' or e.config.id == 'from_game_won') then G.OVERLAY_MENU.config.no_esc =true end
end

function G.UIDEF.run_setup(from_game_over, new_run)
    new_run = new_run or false --boolean that decides if selected tab should be "New Run" or "Continue"

  G.run_setup_seed = nil
  local _challenge_chosen = from_game_over == 'challenge_list'
  from_game_over = from_game_over and not (from_game_over == 'challenge_list')

  local _can_continue = G.MAIN_MENU_UI and G.FUNCS.can_continue({config = {func = true}})
  G.FUNCS.false_ret = function() return false end
  local t =   create_UIBox_generic_options({no_back = from_game_over, no_esc = from_game_over, contents ={
      {n=G.UIT.R, config={align = "cm", padding = 0, draw_layer = 1}, nodes={
        create_tabs(
        {tabs = {
            {
                label = localize('b_new_run'),
                chosen = new_run or (not _challenge_chosen) and (not _can_continue),
                tab_definition_function = G.UIDEF.run_setup_option,
                tab_definition_function_args = 'New Run'
            },
            G.STAGE == G.STAGES.MAIN_MENU and {
                label = localize('b_continue'),
                chosen = (not _challenge_chosen) and _can_continue and (not new_run),
                tab_definition_function = G.UIDEF.run_setup_option,
                tab_definition_function_args = 'Continue',
                func = 'can_continue'
            } or {
              label = localize('b_challenges'),
              tab_definition_function = G.UIDEF.challenges,
              tab_definition_function_args = from_game_over,
              chosen = _challenge_chosen
            },
            G.STAGE == G.STAGES.MAIN_MENU and {
              label = localize('b_challenges'),
              tab_definition_function = G.UIDEF.challenges,
              tab_definition_function_args = from_game_over,
              chosen = _challenge_chosen
            } or nil,
        },
        snap_to_nav = true}),
      }},
  }})
  return t
end

function G.UIDEF.run_setup_option(type)
    local center = G.GAME.viewed_back and G.GAME.viewed_back.effect.center or G.P_CENTERS.b_red --Get the deck to display

  if not G.SAVED_GAME then
    G.SAVED_GAME = get_compressed(G.SETTINGS.profile..'/'..'save.jkr')
    if G.SAVED_GAME ~= nil then G.SAVED_GAME = STR_UNPACK(G.SAVED_GAME) end
  end

  G.SETTINGS.current_setup = type
  G.GAME.viewed_back = Back(center)

  G.PROFILES[G.SETTINGS.profile].MEMORY.stake = G.PROFILES[G.SETTINGS.profile].MEMORY.stake or 1

  if type == 'Continue' then 
    
    G.viewed_stake = 1
    if G.SAVED_GAME ~= nil then
      saved_game = G.SAVED_GAME
      local viewed_deck = center
      for k, v in pairs(G.P_CENTERS) do
        if v.name == saved_game.BACK.name then viewed_deck = k end
      end
      G.GAME.viewed_back:change_to(G.P_CENTERS[viewed_deck])
      G.viewed_stake = saved_game.GAME.stake or 1
    end
  end

  if type == 'New Run' then
    if G.OVERLAY_MENU then 
      local seed_toggle = G.OVERLAY_MENU:get_UIE_by_ID('run_setup_seed')
      if seed_toggle then seed_toggle.states.visible = true end
    end
    G.viewed_stake = G.PROFILES[G.SETTINGS.profile].MEMORY.stake or 1
    G.FUNCS.change_stake({to_key = G.viewed_stake})
  else
    G.run_setup_seed = nil
    if G.OVERLAY_MENU then 
      local seed_toggle = G.OVERLAY_MENU:get_UIE_by_ID('run_setup_seed')
      if seed_toggle then seed_toggle.states.visible = false end
    end
  end

  local area = CardArea(
    G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
    G.CARD_W,
    G.CARD_H, 
    {card_limit = 5, type = 'deck', highlight_limit = 0, deck_height = 0.75, thin_draw = 1})

  for i = 1, 10 do
    local card = Card(G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h, G.CARD_W, G.CARD_H, pseudorandom_element(G.P_CARDS), G.P_CENTERS.c_base, {playing_card = i, viewed_back = true})
    card.sprite_facing = 'back'
    card.facing = 'back'
    area:emplace(card)
    if i == 10 then G.sticker_card = card; card.sticker = get_deck_win_sticker(G.GAME.viewed_back.effect.center) end
  end

  local ordered_names, viewed_deck = {}, 1
  for k, v in ipairs(G.P_CENTER_POOLS.Back) do
    ordered_names[#ordered_names+1] = v.name
    if v.name == G.GAME.viewed_back.name then viewed_deck = k end
  end

  local lwidth, rwidth = 1.4, 1.8

  local type_colour = G.C.BLUE

  local scale = 0.39
  G.setup_seed = ''

  local obj = center

  local t = {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR, minh = 6.6, minw = 6}, nodes={
                type == 'Continue' and {n=G.UIT.R, config={align = "tm", minh = 3.8, padding = 0.15}, nodes={
                    {n=G.UIT.R, config={align = "cm", minh = 3.3, minw = 6.8}, nodes={
                      {n=G.UIT.C, config={align = "cm", colour = G.C.BLACK, padding = 0.15, r = 0.1, emboss = 0.05}, nodes={
                        {n=G.UIT.C, config={align = "cm"}, nodes={
                          {n=G.UIT.R, config={align = "cm", shadow = false}, nodes={
                            {n=G.UIT.O, config={object = area}}
                          }},
                        }},{n=G.UIT.C, config={align = "cm", minw = 4, maxw = 4, minh = 1.7, r = 0.1, colour = G.C.L_BLACK, padding = 0.1}, nodes={
                            {n=G.UIT.R, config={align = "cm", r = 0.1, minw = 4, maxw = 4, minh = 0.6}, nodes={
                              {n=G.UIT.O, config={id = nil, func = 'RUN_SETUP_check_back_name', object = Moveable()}},
                            }},
                            {n=G.UIT.R, config={align = "cm", colour = G.C.WHITE,padding = 0.03, minh = 1.75, r = 0.1}, nodes={
                              {n=G.UIT.R, config={align = "cm"}, nodes={
                                {n=G.UIT.C, config={align = "cm", minw = lwidth, maxw = lwidth}, nodes={{n=G.UIT.T, config={text = localize('k_round'),colour = G.C.UI.TEXT_DARK, scale = scale*0.8}}}},
                                {n=G.UIT.C, config={align = "cm"}, nodes={{n=G.UIT.T, config={text = ': ',colour = G.C.UI.TEXT_DARK, scale = scale*0.8}}}},
                                {n=G.UIT.C, config={align = "cl", minw = rwidth, maxw = lwidth}, nodes={{n=G.UIT.T, config={text = tostring(saved_game.GAME.round),colour = G.C.RED, scale = 0.8*scale}}}}
                              }},
                              {n=G.UIT.R, config={align = "cm"}, nodes={
                                {n=G.UIT.C, config={align = "cm", minw = lwidth, maxw = lwidth}, nodes={{n=G.UIT.T, config={text = localize('k_ante'),colour = G.C.UI.TEXT_DARK, scale = scale*0.8}}}},
                                {n=G.UIT.C, config={align = "cm"}, nodes={{n=G.UIT.T, config={text = ': ',colour = G.C.UI.TEXT_DARK, scale = scale*0.8}}}},
                                {n=G.UIT.C, config={align = "cl", minw = rwidth, maxw = lwidth}, nodes={{n=G.UIT.T, config={text = tostring(saved_game.GAME.round_resets.ante),colour = G.C.BLUE, scale = 0.8*scale}}}}
                              }},
                              {n=G.UIT.R, config={align = "cm"}, nodes={
                                {n=G.UIT.C, config={align = "cm", minw = lwidth, maxw = lwidth}, nodes={{n=G.UIT.T, config={text = localize('k_money'),colour = G.C.UI.TEXT_DARK, scale = scale*0.8}}}},
                                {n=G.UIT.C, config={align = "cm"}, nodes={{n=G.UIT.T, config={text = ': ',colour = G.C.UI.TEXT_DARK, scale = scale*0.8}}}},
                                {n=G.UIT.C, config={align = "cl", minw = rwidth, maxw = lwidth}, nodes={{n=G.UIT.T, config={text = localize('$')..tostring(saved_game.GAME.dollars),colour = G.C.ORANGE, scale = 0.8*scale}}}}
                              }},
                              {n=G.UIT.R, config={align = "cm"}, nodes={
                                {n=G.UIT.C, config={align = "cm", minw = lwidth, maxw = lwidth}, nodes={{n=G.UIT.T, config={text = localize('k_best_hand'),colour = G.C.UI.TEXT_DARK, scale = scale*0.8}}}},
                                {n=G.UIT.C, config={align = "cm"}, nodes={{n=G.UIT.T, config={text = ': ',colour = G.C.UI.TEXT_DARK, scale = scale*0.8}}}},
                                {n=G.UIT.C, config={align = "cl", minw = rwidth, maxw = lwidth}, nodes={{n=G.UIT.T, config={text = number_format(saved_game.GAME.round_scores.hand.amt),colour = G.C.RED, scale = scale_number(saved_game.GAME.round_scores.hand.amt, 0.8*scale)}}}}
                              }},
                              saved_game.GAME.seeded and {n=G.UIT.R, config={align = "cm"}, nodes={
                                {n=G.UIT.C, config={align = "cm", minw = lwidth, maxw = lwidth}, nodes={{n=G.UIT.T, config={text = localize('k_seed'),colour = G.C.UI.TEXT_DARK, scale = scale*0.8}}}},
                                {n=G.UIT.C, config={align = "cm"}, nodes={{n=G.UIT.T, config={text = ': ',colour = G.C.UI.TEXT_DARK, scale = scale*0.8}}}},
                                {n=G.UIT.C, config={align = "cl", minw = rwidth, maxw = lwidth}, nodes={{n=G.UIT.T, config={text = tostring(saved_game.GAME.pseudorandom.seed),colour = G.C.RED, scale = 0.8*scale}}}}
                              }} or nil,
                            }}       
                          }},
                          {n=G.UIT.C, config={align = "cm"}, nodes={
                            {n=G.UIT.O, config={id = G.GAME.viewed_back.name, func = 'RUN_SETUP_check_back_stake_column', object = UIBox{definition = G.UIDEF.deck_stake_column(G.GAME.viewed_back.effect.center.key), config = {offset = {x=0,y=0}}}}}
                          }}  
                        }}     
                      }}}} or
                      {n=G.UIT.R, config={align = "cm", minh = 3.8}, nodes={
                        create_option_cycle({options =  ordered_names, opt_callback = 'change_viewed_back_new', current_option = viewed_deck, colour = G.C.RED, w = 3.5, mid = 
                        {n=G.UIT.R, config={align = "cm", minh = 3.3, minw = 5}, nodes={
                            {n=G.UIT.C, config={align = "cm", colour = G.C.BLACK, padding = 0.15, r = 0.1, emboss = 0.05}, nodes={
                              {n=G.UIT.C, config={align = "cm"}, nodes={
                                {n=G.UIT.R, config={align = "cm", shadow = false}, nodes={
                                  {n=G.UIT.O, config={object = area}}
                                }},
                              }},{n=G.UIT.C, config={align = "cm", minh = 1.7, r = 0.1, colour = G.C.L_BLACK, padding = 0.1}, nodes={
                                  {n=G.UIT.R, config={align = "cm", r = 0.1, minw = 4, maxw = 4, minh = 0.6}, nodes={
                                    {n=G.UIT.O, config={id = nil, func = 'RUN_SETUP_check_back_name', object = Moveable()}},
                                  }},
                                  {n=G.UIT.R, config={align = "cm", colour = G.C.WHITE, minh = 1.7, r = 0.1}, nodes={
                                    {n=G.UIT.O, config={id = G.GAME.viewed_back.name, func = 'RUN_SETUP_check_back', object = UIBox{definition = G.GAME.viewed_back:generate_UI(), config = {offset = {x=0,y=0}}}}}
                                  }},
                                  obj.ppu_team and PotatoPatchUtils.CREDITS.generate_string(obj.ppu_team, 'ppu_team_credit', obj.mod.prefix),
                                  obj.ppu_artist and PotatoPatchUtils.CREDITS.generate_string(obj.ppu_artist, 'ppu_art_credit', obj.mod.prefix),
                                  obj.ppu_coder and PotatoPatchUtils.CREDITS.generate_string(obj.ppu_coder, 'ppu_code_credit', obj.mod.prefix),
                                }},
                                {n=G.UIT.C, config={align = "cm"}, nodes={
                                  {n=G.UIT.O, config={id = G.GAME.viewed_back.name, func = 'RUN_SETUP_check_back_stake_column', object = UIBox{definition = G.UIDEF.deck_stake_column(G.GAME.viewed_back.effect.center.key), config = {offset = {x=0,y=0}}}}}
                                }}   
                              }}     
                            }}
                          })
                        }},
                  {n=G.UIT.R, config={align = "cm"}, nodes={
                    type == 'Continue' and {n=G.UIT.R, config={align = "cm", minh = 2.2, minw = 5}, nodes={
                      {n=G.UIT.R, config={align = "cm", minh = 0.17}, nodes={}},
                      {n=G.UIT.R, config={align = "cm"}, nodes={
                        {n=G.UIT.O, config={id = nil, func = 'RUN_SETUP_check_stake', insta_func = true, object = Moveable()}},
                      }}
                    }}
                    or {n=G.UIT.R, config={align = "cm", minh = 2.2, minw = 6.8}, nodes={
                      {n=G.UIT.O, config={id = nil, func = 'RUN_SETUP_check_stake', insta_func = true, object = Moveable()}},
                    }},
                }},
                {n=G.UIT.R, config={align = "cm", padding = 0.05, minh = 0.9}, nodes={
                  {n=G.UIT.O, config={align = "cm", func = 'toggle_seeded_run', object = Moveable()}, nodes={
                  }},
                }},
                {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
                  {n=G.UIT.C, config={align = "cm", minw = 2.4, id = 'run_setup_seed'}, nodes={
                    type == 'New Run' and create_toggle{col = true, label = localize('k_seeded_run'), label_scale = 0.25, w = 0, scale = 0.7, ref_table = G, ref_value = 'run_setup_seed'} or nil
                  }},
                    {n=G.UIT.C, config={align = "cm", minw = 5, minh = 0.8, padding = 0.2, r = 0.1, hover = true, colour = G.C.BLUE, button = "start_setup_run", shadow = true, func = 'can_start_run'}, nodes={
                      {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
                        {n=G.UIT.T, config={text = localize('b_play_cap'), scale = 0.8, colour = G.C.UI.TEXT_LIGHT,func = 'set_button_pip', focus_args = {button = 'x',set_button_pip = true}}}
                      }}
                    }},
                   {n=G.UIT.C, config={align = "cm", minw = 2.5}, nodes={}}
                }}
            }}
  return t
end

G.FUNCS.change_viewed_back_new = function(args)
    G.viewed_stake = G.viewed_stake or 1
    G.GAME.viewed_back:change_to(G.P_CENTER_POOLS.Back[args.to_key])
    if G.sticker_card then G.sticker_card.sticker = get_deck_win_sticker(G.GAME.viewed_back.effect.center) end
    local max_stake = get_deck_win_stake(G.GAME.viewed_back.effect.center.key) or 0
    G.viewed_stake = math.min(G.viewed_stake, max_stake + 1)
    G.PROFILES[G.SETTINGS.profile].MEMORY.deck = args.to_val
    
    G.FUNCS.overlay_menu{
        definition = G.UIDEF.run_setup(PotatoPatchUtils_run_setup_config, true),
        config = {offset = {x = 0, y = 0}}, --keep the menu centered when switching between decks
        no_jiggle = true                    --and don't shake the room
    }

end