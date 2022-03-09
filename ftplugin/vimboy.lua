function Deb(text)
    vim.cmd("unsilent echom '" .. text .. "'")
end

function OpenLinkUnderCursor()
    local cursor_col = vim.fn.col('.')
    if IsOnLink(cursor_col) then
        local lengthOfLine = #vim.fn.getline('.')
        local minCol = FindEndOfLink(cursor_col, 1, -1)
        local maxCol = FindEndOfLink(cursor_col, lengthOfLine, 1)
        local fileToOpen = string.sub(vim.fn.getline('.'), minCol, maxCol)
        OpenPage(fileToOpen)
    else
        vim.cmd('normal! viw')
        OpenVisualSelection()
    end
end

function OpenVisualSelection()
    vim.cmd('normal! ')
    local minCol = vim.fn.col("'<")
    local maxCol = vim.fn.col("'>")
    local fileToOpen = string.sub(vim.fn.getline('.'), minCol, maxCol)
    OpenPage(fileToOpen)
end

function OpenPage(name)
    local file_name = vim.api.nvim_buf_get_name(0)
    local base_dir = file_name:match(".*/")

    local fileToOpen = name

    if vim.fn.filereadable(name) == 0 then
        for _, file in ipairs(vim.fn.readdir(base_dir)) do
            if string.lower(name) == string.lower(file) then
                fileToOpen = file
                break
            end
        end
    end
    vim.cmd('edit ' .. vim.fn.fnameescape(fileToOpen))
end

function FindEndOfLink(start_col, end_col, diff)
    for col = start_col, end_col, diff do if not IsOnLink(col) then return col - diff end end
    return end_col
end

-- In the line of the cursor, is this column on a link?
function IsOnLink(col)
    local cursor_line = vim.fn.line('.')
    return #vim.fn.synstack(cursor_line, col) > 0
end

vim.keymap.set('n', '<CR>', OpenLinkUnderCursor)
vim.keymap.set('v', '<CR>', OpenVisualSelection)
