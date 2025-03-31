local M = {
    schemes = {},
    active_scheme = "default",
}

function M.create_toggle()
    return function()
        assert(M.active_scheme, "No active color scheme set")

        local keys = {}
        local schemes_n = 0;
        for k, _ in pairs(M.schemes) do
            schemes_n = schemes_n + 1
            table.insert(keys, k)
        end

        for i, v in ipairs(keys) do
            if M.active_scheme == M.get(v) then
                local next_index = math.fmod(i, schemes_n) + 1
                M.apply(keys[next_index])
                break
            end
        end
    end
end

function M.set(key, scheme)
    M.schemes[key] = scheme
end

function M.get(key)
    assert(M.schemes[key], "No color scheme found for key: " .. key)
    return M.schemes[key]
end

function M.apply(scheme)
    M.active_scheme = M.get(scheme)
    vim.cmd.colorscheme(M.active_scheme)

    print("Scheme: " .. M.active_scheme)
end

vim.api.nvim_create_user_command("Scheme", function(opts)
    local target = opts.fargs[1]
    M.apply(target)
end, { nargs = 1 })

vim.keymap.set("n", "<C-,>", M.create_toggle())

return M
