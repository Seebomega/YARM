require "util"
require "lib/string"

resmon = {}

require "control_migrations"
require "resmon/events"
require "resmon/filters"

function resmon.on_init()
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


function resmon.is_drill(entity_prototype)
    return (entity_prototype.type == "mining-drill")
end


function resmon.on_drill_built(drill)
    local radius = drill.prototype.mining_drill_radius

    local ores = drill.surface.find_entities_filtered{
        type="resource",
        area={
            {drill.position.x - radius, drill.position.y - radius},
            {drill.position.x + radius, drill.position.y + radius},
        }
    }

    -- proof of concept: miner visible ore count
    local count = 0
    for _, ore in pairs(ores) do
        count = count + ore.amount
    end

    msg_all({"", "The ", drill.localised_name, " has ", count, " ore"})
end
