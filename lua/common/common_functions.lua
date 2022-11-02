function get_absolute_filepath(relative_path)
    local absolute_path = vim.loop.fs_realpath(relative_path)

    -- File doesn't exist (yet)
    if(absolute_path == nil) then

        -- User did specify a filepath
        if (string.len(relative_path) > 0) then
            local pos_of_last_file_separator = 0
            for i = 1, string.len(relative_path) do
                 local char = string.sub(relative_path, i, i)
                 if (char == "/") then
                     pos_of_last_file_separator = i
                 end
            end

            local dir_path = string.sub(relative_path, 0, pos_of_last_file_separator)
            if (string.len(dir_path) == 0) then
                dir_path = "."
            end
            dir_path = vim.loop.fs_realpath(dir_path)

            local filename = string.sub(relative_path, pos_of_last_file_separator + 1, string.len(relative_path))

            absolute_path = dir_path.."/"..filename
        end
    end

    return absolute_path
end

