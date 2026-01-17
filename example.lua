if minetest.global_exists("myfortune") then
    -- Add a custom schematic
    myfortune.register_schematic({
        file = "don_castle.mts", --name of the schematic
        weight = 2,              --the chach of it happening
        offset = -1,             --moves the schematic up or down
        size = 15                --the longest lenght of the x or z of the schematic
    })

    -- Add a custom "Trap" event - name of trap, weight, function
    myfortune.register_event("name", 5, function(pos, player)
        minetest.set_node(pos, {name = "default:lava_source"})
        minetest.chat_send_player(player:get_player_name(), "Burn Baby Burn!")
    end)
end

--Be sure to add myfortuneblock to the depends in mod.conf
