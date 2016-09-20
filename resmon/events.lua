
if not resmon then error("Reached {{__FILE__}} before resmon.lua!") end

resmon.events = {}

-- Note: Events must match a name from defines.events; as long as they do,
-- they will automatically attach to the appropriate event.


function resmon.events.on_player_created(event)
    -- TODO: event.player_index
end


function resmon.events.on_player_joined_game(event)
    -- TODO: event.player_index
end


function resmon.events.on_player_left_game(event)
    -- TODO: event.player_index
end


function resmon.events.on_force_created(event)
    -- TODO: event.force
end


function resmon.events.on_forces_merging(event)
    -- TODO: event.source, event.destination
end


function resmon.events.on_built_entity(event)
    -- TODO: event.player_index, event.created_entity
    if resmon.is_drill(event.created_entity) then
        resmon.on_drill_built(event.created_entity)
    end

end


function resmon.events.on_robot_built_entity(event)
    -- TODO: event.robot, event.created_entity
    if resmon.is_drill(event.created_entity) then
        resmon.on_drill_built(event.created_entity)
    end
end


function resmon.events.on_preplayer_mined_item(event)
    -- TODO: event.player_index, event.entity
    if resmon.is_drill(event.entity) then
        resmon.on_drill_mined(event.entity)
    end
end


function resmon.events.on_robot_pre_mined(event)
    -- TODO: event.robot, event.entity
    if resmon.is_drill(event.entity) then
        resmon.on_drill_mined(event.entity)
    end
end


function resmon.events.on_tick(event)
    -- TODO: as little as possible
    resmon.update_drills(event)
end
