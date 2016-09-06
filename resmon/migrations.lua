
if not resmon then error("Reached {{__FILE__}} before resmon.lua!") end

resmon.migrations = {}

-- Note: Migrations are keyed by a substring like "0.7", with which the
-- affected 'from' versions should start.
-- The value should be a function that takes mod_change = {old_version="...",
-- new_version="..."} and performs the necessary work (chaining to later
-- migrations if necessary).

resmon.migrations["0.7"] = function(mod_change)
    -- TODO: Migrate 0.7.x data structures
end
