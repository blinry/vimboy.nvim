vim.api.nvim_set_hl(0, "vimboyLink", {link = "Underlined"})
vim.cmd('syntax clear vimboyLink')

local file_name = vim.api.nvim_buf_get_name(0)
local base_dir = FindRootDir(file_name)

function AddLink(filename)
    local relative_path = vim.fn.substitute(filename, base_dir .. '/', '', '')
    vim.cmd('syntax match vimboyLink /\\c\\V\\<' .. vim.fn.escape(relative_path, '/\\') .. '/')
end

function RecursiveFiles(dir)
    local results = {}
    for _, file in ipairs(vim.fn.readdir(dir)) do
        if not file:match('^%.') then
            local path = dir .. '/' .. file
            if vim.fn.isdirectory(path) == 1 then
                for _, r in ipairs(RecursiveFiles(path)) do
                    table.insert(results, r)
                end
            else
                table.insert(results, path)
                table.insert(results, file)
            end
        end
    end
    table.sort(results, function(a,b) return #a<#b end)
    return results
end

for _, file in ipairs(RecursiveFiles(base_dir)) do
    AddLink(file)
end
