local function detect_line_option(str)
    return str:match("^%+(%d+)$")
end

local function detect_dash_parametes(str)
    return str:match("^-") ~= nil
end

local dummy_parameters_list = {
    ["-o"] = "split",
    ["-O"] = "vsplit",
    ["-p"] = "tab",
    ["--"] = "ignore"
}

local function detect_parameters(str)
    local handled_opt = dummy_parameters_list[str]
    if handled_opt then
        return handled_opt
    end
    return detect_dash_parametes(str)
end

function extract_args(args, options)
    local files = {}
    local index = 1
    for i, arg in ipairs(args) do
        -- this repeat block allow break to act as continue in the for loop
        -- it may need some refactoring
        repeat
            if i == 1 then
                break
            end
            local opt = detect_parameters(arg)
            if not options.ignore and opt then
                if opt ~= true then
                    options[opt] = true
                end
                break
            end

            local line = detect_line_option(arg)
            if not options.ignore and line then
                -- When + option used first let's apply this on the first file
                local index = (index > 1) and (index - 1) or (index)
                if not files[index] then
                    files[index] = {}
                end
                files[index].line = line
                break
            end

            if not files[index] then
                files[index] = {}
            end
            files[index].path = arg
            index = index + 1
            break
        until false
    end
    return files
end
