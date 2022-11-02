function get_absolute_filepath(relative_path)
    local absolute_path = vim.loop.fs_realpath(relative_path)

    -- The absolute path that's returned needs escaped special chars.
    -- Just escaping everything once is acceptable, so go ahead and
    -- interpolate backslashes so we don't have to maintain a special
    -- character list or rely on another external tool.
    --absolute_path = string.gsub(absolute_path, ".", "\\\\%1")
    -- TODO: Uncomment? ^^^

    return absolute_path
end

