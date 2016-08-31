
function string.starts_with(haystack, needle)
    return string.sub(haystack, 1, string.len(needle)) == needle
end
