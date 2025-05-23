local function detect_line_option(str)
    return str:match("^%+(%d+)$")
end

local function detect_dash_parametes(str)
    return str:match("^-") ~= nil
end

local parameters_map = {
    ["-o"] = "split",
    ["-O"] = "vsplit",
    ["-p"] = "tab",
    ["-d"] = "diff",
}

local function detect_parameters(str)
    local handled_opt = parameters_map[str]
    if handled_opt then
        return handled_opt
    end
    return detect_dash_parametes(str)
end


local function parse_double_dash(arg, state)
    if state.double_dash then
        return false
    end
    if arg == "--" then
        state.double_dash = true
        return true
    end
    return false
end

local function parse_option(arg, state)
    if state.double_dash then
        return false
    end

    local opt = detect_parameters(arg)

    if not opt then
        return false
    end

    if opt ~= true then
        state.options.multi_file_open_method = opt
    end
    return true
end

local function parse_line_number(arg, state)
    if state.double_dash then
        return false
    end

    local line = detect_line_option(arg)
    if not line then
        return false
    end

    -- When + option used first let's apply this on the first file
    local index = (state.index > 1) and (state.index - 1) or (state.index)

    if not state.files[index] then
        state.files[index] = {}
    end

    state.files[index].line = tonumber(line)

    return true
end

local function parse_file(arg, state)
    if not state.files[state.index] then
        state.files[state.index] = {}
    end
    state.files[state.index].path = arg
    state.index = state.index + 1
    return true
end

---This function filter all files
---and return only the mapping of files -> line number
---@param files {[string]:any}[]
---@return { [string]: integer } dict with file -> line
local function extract_file_with_line_number(files)
    local ret = {}
    for _, file in ipairs(files) do
        if file.line then
            ret[file.path] = file.line
        end
    end

    return ret
end

---This is the list of parsing function
---Note that the order matter
local parser = {
    parse_double_dash,
    parse_option,
    parse_line_number,
    parse_file,
}

---This function parse bare neovim argument list
---It has two purpose:
---
---1. Detect cmd line option `-o -O -p`, and fill the given options
---2. Detect +\d line number specifier, and returning a dictionary of file:line number
---Here we don't care of file without any file number since those
---will be handled by neovim argument parser which is smartest than this parser
---
---Limitation: this is a really dumb parser if you run neovim for example with
---`nvim --cmd "this_is_cmd_argument" +32` this_is_cmd_argument will end up within
---the list of file returned by this function, we don't really care since files
---to open will be retrieved by the neovim parser via vim.call("argv") here we want
---a good enough parser to detect line number after a file and some options that's it
---@param args string[] this argument need the bare argv from neovim
---@param options table
---@return { [string]: integer }
function unception_arg_parse(args, options)
    local state = {
        files = {},
        index = 1,
        double_dash = false,
        options = options
    }

    -- remove nvim in argv[1]
    table.remove(args, 1)

    for _, arg in ipairs(args) do
        for _, fn in ipairs(parser) do
            if fn(arg, state) then
                break
            end
        end
    end

   return extract_file_with_line_number(state.files)
end
