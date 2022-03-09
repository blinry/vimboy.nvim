vim.cmd('highlight link vimboyLink Underlined')
vim.cmd('syntax clear vimboyLink')

local file_name = vim.api.nvim_buf_get_name(0)
local base_dir = file_name:match(".*/")

function addLink(filename)
    vim.cmd('syntax match vimboyLink /\\c\\V\\<' .. vim.fn.escape(filename, '/\\') .. '/')
end

for _, file in ipairs(vim.fn.readdir(base_dir)) do addLink(file) end
