myland = myland or {}
myfortune = {}
math.randomseed(os.time())
myfortune.modpath = minetest.get_modpath("myfortuneblock")

myfortune.rarity_levels = {
    rare = {weight = 20, color = "#55FF55", label = "RARE", chat = ""},
    very_rare = {weight = 5, color = "#5555FF", label = "VERY RARE", chat = ""},
    ultra_rare = {weight = 1, color = "#AA00AA", label = "ULTRA RARE", chat = ""}
}

myfortune.config = {
    structure_chance = 10,
    mob_chance = 15,
    trap_chance = 5,
}
local function formal_name(str)
    local name = str:find(":") and str:split(":")[2] or str
    name = name:gsub("_", " ")
    return (name:gsub("^%l", string.upper))
end

local function colorize(text, hex)
    return minetest.get_color_escape_sequence(hex) .. text .. minetest.get_color_escape_sequence("#ffffff")
end

function myfortune.register_schematic(schem_data)
    table.insert(myfortune.schematics, schem_data)
end

myfortune.registered_events = {}
function myfortune.register_event(name, chance, func)
    table.insert(myfortune.registered_events, {
        name = name,
        chance = chance,
        action = func
    })
end

dofile(myfortune.modpath .. "/schematics.lua")
dofile(myfortune.modpath .. "/functions/loot.lua")
dofile(myfortune.modpath .. "/functions/traps.lua")
dofile(myfortune.modpath .. "/functions/mobs.lua")
dofile(myfortune.modpath .. "/functions/structures.lua")

minetest.register_node("myfortuneblock:block", {
    description = "Fortune Block",
    tiles = {"myfortuneblock.png"},
    is_ground_content = true,
    groups = {cracky = 1, level = 2},
    light_source = 10,
    drop = "",
    scale = 0.5,
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        if not digger or not digger:is_player() then return end
        
        local player_name = digger:get_player_name()
		local roll = math.random(1, 100)
        
        local struct_chance = 10
        local mob_chance    = 10
        local trap_chance   = 15

        if roll <= struct_chance then
            if #myfortune.schematics > 0 then
                myfortune.spawn_schematic(pos, player_name)
                return
            end
        
        elseif roll <= (struct_chance + mob_chance) then
            if myfortune.trigger_mob then
                myfortune.trigger_mob(pos, player_name)
                return
            end

        elseif roll <= (struct_chance + mob_chance + trap_chance) then
            if #myfortune.registered_events > 0 then
                local pick = math.random(1, #myfortune.registered_events)
                myfortune.registered_events[pick].action(pos, digger)
                return
            end
        end

        local num_drops = math.random(1, 5)
        local found_items = {}

        for i = 1, num_drops do
            local drop = myfortune.get_random_item()
            if drop then
                local r_data = myfortune.rarity_levels.rare
                for _, data in pairs(myfortune.rarity_levels) do
                    if data.weight == drop.weight then r_data = data break end
                end
                
                myfortune.drop_with_style(pos, drop, r_data)
                
                local clean_item_name = formal_name(drop.name)
                local colored_name = colorize(clean_item_name, r_data.color)
                
                table.insert(found_items, colored_name)
                
                if r_data.label == "Ultra Rare" then
                    minetest.chat_send_all(minetest.colorize("#ffaa00", "[Fortune] ") .. 
                        player_name .. " hit the Jackpot: " .. colored_name .. "!")
                end
            end
        end
        
        if #found_items > 0 then
            minetest.chat_send_player(player_name, 
                minetest.colorize("#ffaa00", "[Fortune] Found: ") .. table.concat(found_items, ", "))
        end
    end,
})

minetest.register_ore({
    ore_type       = "scatter",
    ore            = "myfortuneblock:block",
    wherein        = {"default:stone"},
    clust_scarcity = 15 * 15 * 15,
    clust_num_ores = 1,
    clust_size     = 1,
    y_min          = -31000,
    y_max          = -10,
})
minetest.register_ore({
    ore_type       = "scatter",
    ore            = "myfortuneblock:block",
    wherein        = {"default:dirt_with_grass", "default:sand", "default:desert_sand", "default:silver_sand"},
    clust_scarcity = 30 * 30 * 30,
    clust_num_ores = 1,
    clust_size     = 1,
    y_min          = -10,
    y_max          = 100,
})

minetest.register_tool("myfortuneblock:tester_wand", {
    description = "Admin Testing Wand",
    inventory_image = "default_stick.png^[colorize:#ff0000:150",
    tool_capabilities = {
        full_punch_interval = 0.1,
        max_drop_level = 3,
        groupcaps = {
            unbreakable = {times={[1]=0, [2]=0, [3]=0}, uses=0, maxlevel=3},
            fleshy = {times={[1]=0, [2]=0, [3]=0}, uses=0, maxlevel=3},
        },
        damage_groups = {fleshy=10},
    },
})
