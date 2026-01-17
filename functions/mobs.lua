function myfortune.get_installed_mobs()
    local mobs = {hostile = {}, peaceful = {}}
    for name, _ in pairs(minetest.registered_entities) do
        if name:find("mobs_") or name:find(":mob") or name:find("monster") or name:find("animal") then
            if name:find("monster") or name:find("zombie") or name:find("spider") or name:find("creeper") then
                table.insert(mobs.hostile, name)
            else
                table.insert(mobs.peaceful, name)
            end
        end
    end
    return mobs
end

local mob_list = myfortune.get_installed_mobs()

function myfortune.trigger_mob(pos, player_name)
    local spawn_pos = {x=pos.x, y=pos.y + 0.5, z=pos.z}
    local mob_pool = {}

    for name, def in pairs(minetest.registered_entities) do
        if name:find("mobs_monster:") or 
           name:find("mobs_animal:") or 
           name:find("mcl_mobs:") or 
           name:find("mobs_water:") or
           name:find("mob_horse:") or
           name:find("dmobs:") or
           name:find("bees:") or
           name:find("bugslive:") or
           name:find("mobs_creeper:") or
           name:find("mobs_mc:") or
           name:find("mobs_skeletons:") or
           name:find("zombie:") or
           name:find("mobs_sky:") or
           name:find("ghost:") or
           name:find("slimes:") or
           name:find("mr_goat:") or
           name:find("kpgmobs:") or
           name:find("pmobs:") or
           name:find("nssm:") or
           name:find("nssm_extra:") or
           name:find("creatura:") or
           name:find("animalia:") or
           name:find("goblins:") or
           name:find("zoonami_3d_mobs:") or
           name:find("marinaramobs:") or
           name:find("ethereal_bosses:") or
           name:find("skeleton:") or
           name:find("creatures:") then
            
            if not name:find("horse") and 
               not name:find("villager") and 
               not name:find("trader") and
               not name:find("npc") then
                table.insert(mob_pool, name)
            end
        end
    end

    if #mob_pool > 0 then
        local pick = mob_pool[math.random(#mob_pool)]
        local staticdata = 'return {["name"]="' .. pick .. '", ["forced_base_size"]=1}'
        local ent = minetest.add_entity(spawn_pos, pick, staticdata)
        
        if ent then
            local obj = ent:get_luaentity()
            minetest.after(0.1, function()
                if obj and obj.object then
                    if pick:find("monster") or pick:find("zombie") or pick:find("creeper") then
                        obj.state = "attack"
                        obj.attack = minetest.get_player_by_name(player_name)
                    end
                end
            end)
        end

        local clean_name = pick:split(":")[2] or pick
        minetest.chat_send_player(player_name, "A " .. clean_name .. " appeared!")
        minetest.add_particlespawner({
            amount = 20, time = 0.2, 
            minpos = pos, maxpos = pos,
            texture = "default_item_smoke.png^[colorize:"..(type=="hostile" and "#FF0000" or "#FFFFFF")..":150",
            glow = 14
        })
        return
    end

    minetest.set_node(pos, {name = "tnt:tnt_burning"})
end

