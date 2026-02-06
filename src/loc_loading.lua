PotatoPatchUtils.LOC = {}

function PotatoPatchUtils.LOC.init()
    for g_k, group in pairs(G.localization.PotatoPatch) do
        for t, center in pairs(group) do
            center.text_parsed = {}
            if not center.text then else
                for _, line in ipairs(center.text) do
                    table.insert(center.text_parsed, PotatoPatchUtils.LOC.recursive_parse(line))
                end
            end
            center.name_parsed = {}
            if not center.name then else
                for _, line in ipairs(type(center.name) == 'table' and center.name or {center.name}) do
                    center.name_parsed[#center.name_parsed+1] = loc_parse_string(line)
                end
            end
            if center.unlock then
                center.unlock_parsed = {}
                for _, line in ipairs(center.unlock) do
                center.unlock_parsed[#center.unlock_parsed+1] = loc_parse_string(line)
                end
            end
        end
    end
end

function PotatoPatchUtils.LOC.recursive_parse(target)
    if type(target) == 'table' then
        if target.text then
            local parsed = {}
            for _, line in ipairs(target.text) do
                table.insert(parsed, PotatoPatchUtils.LOC.recursive_parse(line))
            end
            target.text_parsed = parsed
            if target.name then
                target.name_parsed = {}
                for _, line in ipairs(type(target.name) == 'table' and target.name or {target.name}) do
                    target.name_parsed[#target.name_parsed+1] = loc_parse_string(line)
                end
            end
            return parsed
        else
            local parsed = {}
            for _, line in ipairs(target) do
                table.insert(parsed, PotatoPatchUtils.LOC.recursive_parse(line))
            end
            return parsed
        end
    end
    return loc_parse_string(target)
end