
if not resmon then error("Reached {{__FILE__}} before resmon.lua!") end


resmon.sorters = {}

resmon.sorters.asc_by_permille_remaining = function(left, right)
    if left.remaining_permille ~= right.remaining_permille then
        return left.remaining_permille < right.remaining_permille
    elseif left.added_at ~= right.added_at then
        return left.added_at < right.added_at
    else
        return left.name < right.name
    end
end
