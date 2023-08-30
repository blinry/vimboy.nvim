-- Link the 'vimboyLink' highlight group to the eisting 'Underlined' group.
vim.api.nvim_set_hl(0, "vimboyLink", {link = "Underlined"})

-- Remove all existing vimboyLink syntax matches.
vim.cmd('syntax clear vimboyLink')

-- Find the directory of the current file.
local base_dir = vim.fn.expand('%:h')

-- Loop through all files in the directory, and add a syntax match for each one.
for _, file in ipairs(vim.fn.readdir(base_dir)) do
    vim.cmd('syntax match vimboyLink /\\c\\V\\<' .. vim.fn.escape(file, '/\\') .. '/')
end
