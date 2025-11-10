local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local config = require("telescope.config").values
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local utils = require("telescope.utils")

local plenary = require('plenary')
local log = require('plenary.log').new {
    plugin = 'nvim-cd-history',
    level = 'debug',
}

local M = {}

function M._job(job_opts)
    log.info('Running job', job_opts)
    local job = plenary.job:new(job_opts):sync()
    log.debug('Ran job', vim.inspect(job))
    return job
end

function M.read_cd_history()
    local job_opts = {
        command = "cat",
        args = { vim.fn.expand("~/.cd_history") }
    }
    return M._job(job_opts)
end


function M.c(opts)

    pickers
        .new(opts, {
            finder = finders.new_dynamic({
                fn = function()
                    return M.read_cd_history()
                end,
                entry_maker = function(entry)
                    return {
                        value = entry,
                        display = entry,
                        ordinal = entry
                    }
                end,
            }),

            -- on_input_filter_cb = opts.on_input_filter_cb,
            sorter = config.generic_sorter(opts),

            previewer = previewers.new_termopen_previewer({
                title = 'directory',
                get_command = function (entry)
                    return 'timeout 1 eza --tree -L 1 --color=always ' .. entry.value .. ' | head -n 50'
                end
            }),

            attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)

                    local selection = action_state.get_selected_entry()
                    log.info('changing directory: ', selection.value)
                    -- vim.api.nvim_set_current_dir(selection.value)
                    vim.cmd('edit ' .. selection.value)
                end)
                return true
            end,
        })
        :find()
end

return M
