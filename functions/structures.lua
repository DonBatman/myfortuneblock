function myfortune.get_random_schematic()
    local total_weight = 0
    for _, s in ipairs(myfortune.schematics) do
        total_weight = total_weight + s.weight
    end

    local rand = math.random(1, total_weight)
    local curr = 0
    for _, s in ipairs(myfortune.schematics) do
        curr = curr + s.weight
        if rand <= curr then return s end
    end
end

function myfortune.spawn_schematic(pos, digger)
    local schem = myfortune.get_random_schematic()
    if not schem then return false end

    local half = math.floor(schem.size / 2)
    local corners = {
        {x=pos.x - half, y=pos.y, z=pos.z - half},
        {x=pos.x + half, y=pos.y, z=pos.z + half}
    }
    
    for _, c in ipairs(corners) do
        if minetest.is_protected(c, "") then
            minetest.chat_send_player(digger:get_player_name(), "Area protected! Structure blocked.")
            return false
        end
    end

    local mod_name = schem.mod or "myfortuneblock"
	local path = minetest.get_modpath(mod_name) .. "/schematics/" .. schem.file
    local spawn_pos = {x = pos.x - half, y = pos.y + schem.offset, z = pos.z - half}

    minetest.place_schematic(spawn_pos, path, "random", nil, true)
    return true
end
