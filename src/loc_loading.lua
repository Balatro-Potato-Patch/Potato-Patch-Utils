local nativefs = NFS
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

local function mergeTables(dest, source)
    if dest == nil then return source end
    for k,v in pairs(source) do
        if dest[k] == nil then
            dest[k] = v
        else
            if type(v) ~= "table" or type(dest[k]) ~= "table" then
                dest[k] = v
            else
                dest[k] = mergeTables(dest[k], v)
            end
        end
    end
    return dest
end

local function loadLang(path, mod_id)
    local files = nativefs.getDirectoryItemsInfo(path)
    local ret = nil
    for _, v in ipairs(files) do
        if v.type == "file" then
            local loc_table = assert(loadstring(nativefs.read(path .. v.name), ('=[SMODS %s "%s"]'):format(mod_id, string.match(v.name, '[^/]+/[^/]+$'))))()
            ret = mergeTables(ret, loc_table)
        end
    end
    return ret
end

local function processLoc(locPath, mod_id)
    local info = nativefs.getDirectoryItemsInfo(locPath)
    table.sort(info, function(a, b)
        return a.name < b.name
    end)
    local ret = {}
    for _, v in ipairs(info) do
        if v.type == "directory" then
            ret[v.name] = loadLang(locPath .. v.name .. "/", mod_id)
        end
    end
    return ret
end

local function injectLoc(loc)
    if not loc then return end
    mergeTables(G.localization, loc)
end

function PotatoPatchUtils.LOC.process_loc_text(locPath, mod_id)
    local txt = processLoc(locPath, mod_id)

    injectLoc(txt['en-us'])
    injectLoc(txt['default'])
    injectLoc(txt[G.SETTINGS.language])
    injectLoc(txt[G.SETTINGS.real_language])
end