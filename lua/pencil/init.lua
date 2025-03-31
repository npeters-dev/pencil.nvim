local M = {
    config = {},
    schemes = {},
    active_scheme = "default",
}

M.setup = function(config)
    M.config = config
end

function M.create_toggle(...)
    local keys = { ... }
    return function()
        assert(M.active_scheme, "No active color scheme set")

        if type(next(M.config.toggle_targets)) ~= "nil" then
            keys = M.config.toggle_targets
        elseif type(next(keys)) == "nil" then
            for k, _ in pairs(M.schemes) do
                table.insert(keys, k)
            end
        end

        local schemes_n = 0;
        for _, _ in pairs(keys) do
            schemes_n = schemes_n + 1
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
    if M.config.default == key then
        M.apply(key)
    end
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
