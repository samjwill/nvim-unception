function get_absolute_filepath(relative_path)
    local absolute_path = vim.loop.fs_realpath(relative_path)

    -- File doesn't exist (yet)
    if(absolute_filepath == nil) then

        -- User did specify a filepath
        if (string.len(iter) > 0) then
            local pos_of_last_file_separator = 0
            for i = 1, string.len(iter) do
                 local char = string.sub(iter, i, i)
                 if (char == "/") then
                     pos_of_last_file_separator = i
                 end
            end

            local dir_path = string.sub(iter, 0, pos_of_last_file_separator)
            if (dir_path == nil) then
                dir_path = "./"
            end
            local filename = string.sub(iter, pos_of_last_file_separator + 1, string.len(iter))

            absolute_filepath = get_absolute_filepath(dir_path).."/"..filename
        end
    end

    return absolute_path
end

