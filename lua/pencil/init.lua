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
        assert(M.active_scheme, "No active scheme")


        if type(next(M.config.toggle_targets)) ~= "nil" then
            keys = M.config.toggle_targets
        elseif type(next(keys)) == "nil" then
            for k, _ in pairs(M.schemes) do
                table.insert(keys, k)
            end
        end

        local keys_n = table.maxn(keys)
        if keys_n == 0 then
            return
        end

        local is_active_registered = false
        for _, v in ipairs(keys) do
            if M.active_scheme == M.get(v).name then
                is_active_registered = true
                break
            end
        end
        if not is_active_registered then
            M.apply(keys[1])
            return
        end

        for i, v in ipairs(keys) do
            if M.active_scheme == M.get(v).name then
                local next_index = math.fmod(i, keys_n) + 1
                M.apply(keys[next_index].name)
                break
            end
        end
    end
end

function M.set(key, scheme, on_apply)
    M.schemes[key] = { name = scheme, on_apply = on_apply }
    if M.config.default == key then
        M.apply(key)
    end
end

function M.get(key)
    assert(M.schemes[key], "No color scheme found for key: " .. key)
    return M.schemes[key]
end

function M.apply(scheme)
    local s = M.get(scheme)
    M.active_scheme = s.name
    vim.cmd.colorscheme(M.active_scheme)

    if s.on_apply then
        s.on_apply()
    end

    print("Scheme: " .. M.active_scheme)
end

vim.api.nvim_create_user_command("Scheme", function(opts)
    local target = opts.fargs[1]
    M.apply(target)
end, { nargs = 1 })

vim.keymap.set("n", "<C-,>", M.create_toggle())

return M
