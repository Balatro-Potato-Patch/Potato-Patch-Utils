PotatoPatchUtils = SMODS.current_mod

--#region File Loading
local nativefs = NFS

local function load_file_native(path, mod)
    if not path or path == "" then
        error("No path was provided to load.")
    end
    local file_path = path
    local file_content, err = NFS.read(file_path)
    if not file_content then
        return nil,
        "Error reading file '" .. path .. "' for mod with ID '" .. mod.id .. "': " .. err
    end
    local path_len = string.len(path) + 1
    local short_path = string.sub(path, path_len, path:len())
    local chunk, err = load(file_content, "=[SMODS " .. mod.id .. ' "' .. short_path .. '"]')
    if not chunk then
        return nil,
        "Error processing file '" .. path .. "' for mod with ID '" .. mod.id .. "': " .. err
    end
    return chunk
end

function PotatoPatchUtils.load_files(path, mod, blacklist)
    blacklist = blacklist or {}
    local info = nativefs.getDirectoryItemsInfo(path)
    table.sort(info, function(a, b)
        return a.name < b.name
    end)
    for _, v in ipairs(info) do
        if v.type == "directory" and not blacklist[v.name] then
            PotatoPatchUtils.load_files(path .. '/' .. v.name)
        elseif string.find(v.name, ".lua") and not blacklist[v.name] then -- no X.lua.txt files or whatever unless they are also lua files
            local f, err = load_file_native(path .. "/" .. v.name, mod)
            if f then
                f()
            else
                error("error in file " .. v.name .. ": " .. err)
            end
        end
    end
end

--#endregion

-- Other loading things
PotatoPatchUtils.load_files(PotatoPatchUtils.path .. '/src', PotatoPatchUtils)
SMODS.handle_loc_file(PotatoPatchUtils.path, PotatoPatchUtils.id)
PotatoPatchUtils.LOC.init()