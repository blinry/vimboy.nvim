-- Used for debugging purposes during development.
function Debug(text)
    vim.cmd("unsilent echom '" .. text .. "'")
end

-- Open the link under the cursor, or the word under the cursor if no link is found.
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

-- Loop through the characters of the current line, until we're no longer on a link.
function FindEndOfLink(start_col, end_col, diff)
    for col = start_col, end_col, diff do if not IsOnLink(col) then return col - diff end end
    return end_col
end

-- In the line of the cursor, is this column on a link?
function IsOnLink(col)
    local cursor_line = vim.fn.line('.')
    return #vim.fn.synstack(cursor_line, col) > 0
end

-- Open the current visual selection.
function OpenVisualSelection()
    vim.cmd('normal! ')
    local minCol = vim.fn.col("'<")
    local maxCol = vim.fn.col("'>")
    local fileToOpen = string.sub(vim.fn.getline('.'), minCol, maxCol)
    OpenPage(fileToOpen)
end

function RecursivePages(dir)
    local results = {}
    for _, file in ipairs(vim.fn.readdir(dir)) do
        if not file:match('^%.') then
            local path = file
            if vim.fn.isdirectory(path) == 1 then
                for _, r in ipairs(RecursiveFiles(path)) do
                    table.insert(results, path .. '/' .. r)
                end
            else
                table.insert(results, path)
            end
        end
    end
    table.sort(results, function(a,b) return #a<#b end)
    return results
end

function FindRootDir(filename)
    local dir = vim.fn.fnamemodify(filename, ':h')
    if vim.fn.isdirectory(dir .. '/.git') == 1 then
        return dir
    elseif vim.fn.isdirectory(dir .. '/../.git') == 1 then
        return vim.fn.fnamemodify(dir, ':h')
    else
        return dir
    end
end

-- Open the page with the given name.
function OpenPage(name)
    local file_name = vim.api.nvim_buf_get_name(0)
    local base_dir = FindRootDir(file_name)
    Debug(base_dir)

    local fileToOpen = name

    if vim.fn.filereadable(name) == 0 then
        -- If the file doesn't exist, try to find versions of the file with different casing.
        for _, file in ipairs(RecursivePages(base_dir)) do
            local tail = vim.fn.fnamemodify(file, ':t')
            if string.lower(name) == string.lower(tail) then
                fileToOpen = file
                break
            end
        end
    end
    local path = vim.fn.fnamemodify(base_dir .. '/' .. fileToOpen, ":.")
    vim.cmd('edit ' .. vim.fn.fnameescape(path))
end

vim.keymap.set('n', '<CR>', OpenLinkUnderCursor)
vim.keymap.set('v', '<CR>', OpenVisualSelection)
