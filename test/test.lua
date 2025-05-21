-- really need to find a better solution to include lua file into unit tests
local function get_source_path()
    return debug.getinfo(2, "S").source:sub(2):gsub("[a-z-_1-9A-Z]+.lua$", "")
end
package.path = package.path .. ";" .. get_source_path() .. "../lua/?.lua"
require "common.arg_parse"

describe("unception nvim tests", function()
    describe("argument parser", function()
        local tests_list = {
            -- { -- NYI
            --     argv = { "file", "\\+32" },
            --     output = { { file = "open" }, { file = "+32" } }
            -- },
            {
                argv = { "/usr/bin/nvim", "file", "+5", "-p" },
                output = { { path = "file", line = "5" } },
                option = { multi_file_open_method="tab" }
            },
            {
                argv = { "/usr/bin/dontcare", "file", "file2", "+32" },
                output = { { path = "file" }, { path = "file2", line = "32" } },
                option = { }
            },
            {
                argv = { "/usr/bin/dontcare", "--ignored-option-long", "-i", "file", "file2", "+32" },
                output = { { path = "file" }, { path = "file2", line = "32" } },
                option = { }
            },
            -- { -- NYI
            --     argv = { "/usr/bin/dontcare", "\\- file starting with dash" },
            --     output = { { file = "- file starting with dash" } }
            -- },
            {
                argv = { "/usr/bin/dontcare", "--", "- file starting with dash" },
                output = { { path = "- file starting with dash" } },
                option = { }
            },
            {
                argv = { "/usr/bin/nvim", "file", "+5", "-o" },
                output = { { path = "file", line = "5" } },
                option = { multi_file_open_method="split" }
            },
            {
                argv = { "/usr/bin/nvim", "file", "+5", "-O" },
                output = { { path = "file", line = "5" } },
                option = { multi_file_open_method="vsplit" }
            },
        }
        for i, test in ipairs(tests_list) do
            it("argument parser " .. tostring(i), function()
                local options = {}
                local ret = unception_arg_parse(test.argv, options)
                assert.are.same(test.output, ret)
                assert.are.same(options, test.option)
            end)
        end

    end)
end)
