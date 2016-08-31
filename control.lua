require "resmon"

if not resmon then error("{{MOD_NAME}} has become badly corrupted: the variable resmon should've been set!") end


function msg_all(message)
    for _,p in pairs(game.players) do
        p.print(message)
    end
end


script.on_init(resmon.on_init)
script.on_configuration_changed(resmon.on_configuration_changed)


for name, func in pairs(resmon.events) do
    if not defines.events[name] then
        log(string.format("{{MOD_NAME}}: ignoring handler for non-existent event %s", name))
    else
        script.on_event(defines.events[name], func)
    end
end
