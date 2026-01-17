function myfortune.drop_with_style(pos, drop, r_data)

    local scatter_pos = {
        x = pos.x + (math.random(-3, 3) / 10),
        y = pos.y + 0.5,
        z = pos.z + (math.random(-3, 3) / 10)
    }

    minetest.add_particlespawner({
        amount = 20,
        time = 0.2,
        minpos = pos,
        maxpos = pos,
        minvel = {x = -3, y = 1, z = -3}, 
        maxvel = {x = 3,  y = 5, z = 3},
        minacc = {x = 0, y = -9.81, z = 0},
        maxacc = {x = 0, y = -9.81, z = 0},
        minexptime = 0.5,
        maxexptime = 1.5,
        minsize = 1,
        maxsize = 3,
        texture = "default_item_smoke.png^[colorize:" .. r_data.color .. ":150",
        glow = 14
    })

    local obj = minetest.add_item(scatter_pos, drop.name .. " " .. drop.amount)
    
    if obj then
        obj:set_velocity({
            x = math.random(-2, 2),
            y = 5,
            z = math.random(-2, 2)
        })
        if r_data.label == "ULTRA RARE" then 
            obj:set_properties({glow = 14}) 
        end
    end
end
----------------------------------------------------------------
function myfortune.trigger_pit(pos, player)
    local p_pos = player:get_pos()
    for x = -1, 1 do
        for z = -1, 1 do
            for y = -1, -4, -1 do
                local h_pos = {x=math.floor(p_pos.x)+x, y=math.floor(p_pos.y)+y, z=math.floor(p_pos.z)+z}
                if not minetest.is_protected(h_pos, "") then minetest.remove_node(h_pos) end
            end
        end
    end
    minetest.chat_send_player(player:get_player_name(), "WATCH YOUR STEP!")
end

function myfortune.trigger_sand_trap(pos, player)
    local p_pos = player:get_pos()
    for x = -1, 1 do
        for z = -1, 1 do
            local sand_pos = {x = math.floor(p_pos.x) + x, y = math.floor(p_pos.y) + 3, z = math.floor(p_pos.z) + z}
            if not minetest.is_protected(sand_pos, "") then
                minetest.set_node(sand_pos, {name = "default:sand"})
    			core.check_for_falling(sand_pos)
            end
        end
    end
    minetest.chat_send_player(player:get_player_name(), minetest.colorize("#ffff00", "[Fortune] Watch your head!"))
end


	function myfortune.trigger_lava_leak(pos, player)
    	minetest.after(0.5, function()
        	if not minetest.is_protected(pos, "") then
            	minetest.set_node(pos, {name = "default:lava_source"})
        	end
    	end)
    	minetest.chat_send_player(player:get_player_name(), minetest.colorize("#ff0000", "[Fortune] A leak in the floor!"))
	end


	function myfortune.trigger_gravity_trap(pos, player)
    	player:set_physics_override({
        	jump = 0.5,
        	speed = 0.5,
    	})
    	
    	minetest.after(10, function()
        	if player:is_player() then
            	player:set_physics_override({jump = 1.0, speed = 1.0})
            	minetest.chat_send_player(player:get_player_name(), "§aThe curse lifts...")
        	end
    	end)
    	
    	minetest.chat_send_player(player:get_player_name(), minetest.colorize("#550055", "[Fortune] You feel a heavy weight..."))
	end

myfortune.register_event("lava_leak", 25, myfortune.trigger_lava_leak)
myfortune.register_event("gravity_curse", 25, myfortune.trigger_gravity_trap)
myfortune.register_event("pit_trap", 25, myfortune.trigger_pit)
myfortune.register_event("sand_trap", 25, myfortune.trigger_sand_trap)
