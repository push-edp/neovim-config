-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    command = "checktime",
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
    callback = function()
        local current_tab = vim.fn.tabpagenr()
        vim.cmd("tabdo wincmd =")
        vim.cmd("tabnext " .. current_tab)
    end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function(event)
        local exclude = { "gitcommit" }
        local buf = event.buf
        if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
            return
        end
        vim.b[buf].lazyvim_last_loc = true
        local mark = vim.api.nvim_buf_get_mark(buf, '"')
        local lcount = vim.api.nvim_buf_line_count(buf)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})


-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "gitcommit", "markdown" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.spell = true
    end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    callback = function(event)
        if event.match:match("^%w%w+://") then
            return
        end
        local file = vim.loop.fs_realpath(event.match) or event.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end,
})

vim.api.nvim_create_augroup("_show_dashboard", {})
vim.api.nvim_create_autocmd("VimEnter", {
    group = "_show_dashboard",
    nested = true,
    callback = function(args)
        vim.api.nvim_del_augroup_by_name("_show_dashboard")
        if vim.fn.argc() == 0 then
            vim.api.nvim_exec_autocmds("User", { pattern = "ShowDashboard" })
        end
    end,
})

vim.api.nvim_create_augroup("_dir_opened", {})
vim.api.nvim_create_autocmd("BufEnter", {
    group = "_dir_opened",
    nested = true,
    callback = function(args)
        local bufname = vim.api.nvim_buf_get_name(args.buf)
        local stat = vim.loop.fs_stat(bufname)
        if stat and stat.type == "directory" then
            vim.api.nvim_del_augroup_by_name("_dir_opened")
            vim.api.nvim_exec_autocmds("User", { pattern = "DirOpened" })
            vim.api.nvim_exec_autocmds(args.event, { buffer = args.buf, data = args.data })
        end
    end,
})

vim.api.nvim_create_augroup("_file_opened", {})
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufWritePre" }, {
    group = "_file_opened",
    nested = true,
    callback = function(args)
        local bufname = vim.api.nvim_buf_get_name(args.buf)
        local stat = vim.loop.fs_stat(bufname)
        if stat and stat.type == "directory" then
            return
        end
        local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
        if not (vim.fn.expand "%" == "" or buftype == "nofile") then
            vim.api.nvim_del_augroup_by_name("_file_opened")
            vim.schedule(function()
                vim.api.nvim_exec_autocmds("User", { pattern = "FileOpenedLazy" })
            end)
            vim.api.nvim_exec_autocmds("User", { pattern = "FileOpened" })
        end
    end,
})
