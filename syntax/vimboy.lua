vim.api.nvim_set_hl(0, "vimboyLink", {link = "Underlined"})
vim.cmd('syntax clear vimboyLink')

local file_name = vim.api.nvim_buf_get_name(0)
local base_dir = file_name:match(".*/")

function AddLink(filename)
    vim.cmd('syntax match vimboyLink /\\c\\V\\<' .. vim.fn.escape(filename, '/\\') .. '/')
end

for _, file in ipairs(vim.fn.readdir(base_dir)) do AddLink(file) end
