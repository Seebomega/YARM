require "util"
require "lib/string"

resmon = {}

require "resmon/events"
require "resmon/filters"
require "resmon/migrations"
require "resmon/tracker"


function resmon.on_init()
    resmon.tracker.global_init()
end


function resmon.on_configuration_changed(config_data)
    -- We don't care if only the world version changed.
    if not config_data.mod_changes then return end

    for mod_name, mod_change in pairs(config_data.mod_changes) do
        if mod_name == "{{MOD_NAME}}" then
            -- Note: if you need to do any migrations, check control_migrations.lua
            for match, func in pairs(resmon.migrations) do
                if mod_change.old_version and string.starts_with(mod_change.old_version, match) then
                    func(mod_change)
                end
            end
        end
    end
end


function resmon.is_drill(entity)
    if not entity or not entity.valid then return false end

    return (entity.type == "mining-drill")
end


local drills = {}


function resmon.on_drill_built(drill)
    local radius = drill.prototype.mining_drill_radius

    local ores = drill.surface.find_entities_filtered{
        type="resource",
        area={
            {drill.position.x - radius, drill.position.y - radius},
            {drill.position.x + radius, drill.position.y + radius},
        }
    }

    local indices = {}
    for _, ore in pairs(ores) do
        local index = resmon.tracker.get_ore_index(ore)
        table.insert(indices, index)
        resmon.tracker.activate(ore.surface.name, index)
    end

    local drill_data = {
        entity = drill,
        ore_indices = indices,
    }

    drills[drill.unit_number] = drill_data

    msg_all{"yarm.drill_has", drill.localised_name, drill.unit_number, {"", "the ores: ", table.concat(indices, ', ')}}
end


local function count_drill(drill_data)
    local count = 0

    local surface_name = drill_data.entity.surface.name
    local get_amount = resmon.tracker.get_amount

    for _,index in pairs(drill_data.ore_indices) do
        count = count + get_amount(surface_name, index)
    end

    msg_all{"yarm.drill_has", drill_data.entity.localised_name, drill_data.entity.unit_number, string.format("%d ore", count)}
end


function resmon.update_drills(event)
    if event.tick % 300 ~= 45 then return end

    for key,drill_data in pairs(drills) do
        if not drill_data.entity or not drill_data.entity.valid then
            drills[key] = nil
        else
            count_drill(drill_data)
        end
    end
end


function resmon.on_drill_mined(entity)
    if not drills or not drills[entity.unit_number] then return end

    for _,index in pairs(drills[entity.unit_number].ore_indices) do
        resmon.tracker.deactivate(entity.surface.name, index)
    end

    drills[entity.unit_number] = nil
end
