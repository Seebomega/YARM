
if not resmon then error("Reached {{__FILE__}} before resmon.lua!") end

resmon.tracker = {}
local ore_cache = {}


function resmon.tracker.global_init()
    global.ores = global.ores or {}
    global.active_indices = global.active_indices or {}
end


function resmon.tracker.get_ore_index(entity)
    if not entity or not entity.valid then
        return
    end

    local surface_name = entity.surface.name
    local x = math.floor(entity.position.x)
    local y = math.floor(entity.position.y)

    if not global.ores[surface_name] then
        global.ores[surface_name] = {
            x = {},
            y = {},
            coords = {},
            last_amount = {},
        }
    end
    local ore_table = global.ores[surface_name]

    -- if it already exists, just return that index
    if ore_table.coords[x] and ore_table.coords[x][y] then
        return ore_table.coords[x][y]
    end

    -- else, we need to record it
    local new_index = #ore_table.x + 1

    ore_table.coords[x] = ore_table.coords[x] or {}
    ore_table.coords[x][y] = new_index

    ore_table.x[new_index] = x
    ore_table.y[new_index] = y

    ore_table.last_amount[new_index] = entity.amount

    ore_cache[surface_name] = ore_cache[surface_name] or {}
    ore_cache[surface_name][new_index] = entity

    return new_index
end


local function uncache(ore_table, cache, index)
    local x = ore_table.x[index]
    local y = ore_table.y[index]

    ore_table.coords[x] = ore_table.coords[x] or {} -- defensive programming!
    ore_table.coords[x][y] = nil

    ore_table.x[index] = nil
    ore_table.y[index] = nil

    ore_table.last_amount[index] = nil
    cache[index] = nil
end


function resmon.tracker.get_ore(surface_name, index)
    local ore_table = global.ores[surface_name]

    ore_cache[surface_name] = ore_cache[surface_name] or {}

    local cache = ore_cache[surface_name]

    -- Sanity check: if the index does not/cannot exist, return nil
    if not ore_table or not ore_table.x[index] or not ore_table.y[index] then
        cache[index] = nil
        return nil
    end

    -- If we already have it cached, hand it over...
    if cache[index] then
        -- ...unless it became invalid, in which case, fuhgeddaboutit.
        if not cache[index].valid then
            uncache(ore_table, cache, index)
            return nil
        end

        return cache[index]
    end

    -- Else we must cache it
    local x = ore_table.x[index] + 0.5
    local y = ore_table.y[index] + 0.5

    local entity = game.surfaces[surface_name].find_entities_filtered{type="resource", position={x,y}}[1]

    -- However, if the entity is gone or invalid, we should remove its index
    -- now to prevent getting asked about it again
    if not entity or not entity.valid then
        uncache(ore_table, cache, index)
        return nil
    end

    -- Finally, we know we have a valid ore entity, so record it and return it.
    cache[index] = entity
    return entity
end


function resmon.tracker.activate(surface_name, index)
    if not global.active_indices[surface_name] then
        global.active_indices[surface_name] = {}
    end
    local actives = global.active_indices[surface_name]

    if actives[index] then
        actives[index] = actives[index] + 1
    else
        actives[index] = 1
    end
end


function resmon.tracker.deactivate(surface_name, index)
    if not global.active_indices[surface_name] then
        global.active_indices[surface_name] = {}
    end
    local actives = global.active_indices[surface_name]

    if not actives[index] then
        return
    end

    actives[index] = actives[index] - 1
    if actives[index] < 1 then
        global.active_indices[surface_name][index] = nil
    end
end


function resmon.tracker.get_amount(surface_name, index)
    local ore_table = global.ores[surface_name]

    -- Sanity check: if the index does not/cannot exist, return nil
    if not ore_table or not ore_table.last_amount[index] then
        return 0
    end

    return ore_table.last_amount[index]
end

local iter_funcs = {}
local iter_states = {}
local iter_indices = {}

local function next_ore_index(surface_name, active_ores)
    if not iter_indices[surface_name] then
        iter_funcs[surface_name], iter_states[surface_name], iter_indices[surface_name] = pairs(active_ores)
    end

    local func = iter_funcs[surface_name]
    local state = iter_states[surface_name]
    local index = func(state, iter_indices[surface_name])
    iter_indices[surface_name] = index
    return index
end

function resmon.tracker.update_amounts()
    local get_ore = resmon.tracker.get_ore

    for surface_name,active_ores in pairs(global.active_indices) do
        local last_amounts = global.ores[surface_name].last_amount
        for _ = 1,10 do
            local index = next_ore_index(surface_name, active_ores)
            if index then
                log(string.format("Updating ore %d", index))
                local ore = get_ore(surface_name, index)

                if ore and ore.valid then
                    last_amounts[index] = ore.amount
                else
                    last_amounts[index] = nil
                end
            end
        end
    end
end
