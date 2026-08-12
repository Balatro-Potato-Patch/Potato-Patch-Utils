PotatoPatchUtils.Bubble_Colours = {
    usable = G.C.ETERNAL,
    used = adjust_alpha(G.C.ETERNAL, 0.6),
    toggle = G.C.GREEN,
    active = G.C.GOLD,
    inactive = adjust_alpha(G.C.L_BLACK, 0.6),
    compatible = G.C.GREEN,
    incompatible = G.C.RED
}

function PotatoPatchUtils.extract_bubble(ctrl, vars)
    if not ctrl then return end
    return (vars or {})[tonumber(ctrl) or {}] or ctrl
end