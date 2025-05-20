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
            --     intput = { "file", "\\+32" },
            --     output = { { file = "open" }, { file = "+32" } }
            -- },
            {
                intput = { "/usr/bin/nvim", "file", "+5" },
                output = { { file = "file", line = "5" } }
            },
            {
                intput = { "/usr/bin/dontcare", "file", "file2", "+32" },
                output = { { file = "file" }, { file = "file2", line = "32" } }
            },
            {
                intput = { "/usr/bin/dontcare", "--ignored-option-long", "-i", "file", "file2", "+32" },
                output = { { file = "file" }, { file = "file2", line = "32" } }
            },
            -- { -- NYI
            --     intput = { "/usr/bin/dontcare", "\\- file starting with dash" },
            --     output = { { file = "- file starting with dash" } }
            -- },
            {
                intput = { "/usr/bin/dontcare", "--", "- file starting with dash" },
                output = { { file = "- file starting with dash" } }
            }
        }
        for i, test in ipairs(tests_list) do
            it("argument parser " .. tostring(i), function()
                local options = {}
                local ret = extract_args(test.intput, options)
                assert.are.same(test.output, ret)
            end)
        end

    end)
end)
