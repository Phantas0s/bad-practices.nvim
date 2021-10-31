local M = {}

local NOTIFICATION_OFFSET = 5000

local function check_has_notify_plugin()
    return pcall(function() require('notify') end)
end

local last_shown_dict = {}

local CLEANUP_INTERVAL = 30000
-- clear `last_shown_dict` from older messages to free memory
-- invoked every 30 seconds
local function cleanup()
    local new_dict = {}
    local now = vim.loop.now()
    for key, value in pairs(last_shown_dict) do
        if last_shown_dict[key] < (now + NOTIFICATION_OFFSET) then
            new_dict[key] = value
        end
    end

    last_shown_dict = new_dict

    vim.defer_fn(cleanup, CLEANUP_INTERVAL)
end
cleanup()

local notify = {
    pretty = function(msg)
        require('notify')(msg, 'ERROR', {
            title = 'BadPractices',
            icon = '●',
        })
    end,
    default = function(msg)
        -- use echo instead of echom or echoerr to avoid saving message to :messages
        vim.cmd("echohl WarningMsg | echo '" .. msg .. "' | echohl None")
    end
}

-- uses nvim-notify if installed
-- or prints to status line
function M.print_warn(msg)
    local now = vim.loop.now()
    -- avoid shoing notification too often
    if last_shown_dict[msg] == nil or last_shown_dict[msg] + NOTIFICATION_OFFSET < now then
        last_shown_dict[msg] = now

        if check_has_notify_plugin() then
            notify.pretty(msg)
        else
            notify.default(msg)
        end
    end
end

return M

