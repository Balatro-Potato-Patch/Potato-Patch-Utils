PotatoPatchUtils.Bubble_Colours = {
    usable = G.C.ETERNAL,
    toggle = G.C.GREEN,
    active = G.C.GOLD,
    inactive = adjust_alpha(G.C.L_BLACK, 0.6)
}

function PotatoPatchUtils.extract_bubble(ctrl, vars)
    if not ctrl then return end
    return (vars or {})[tonumber(ctrl) or {}] or ctrl
end