local excluded_nodes = {"air", "ignore"}

local function is_excluded(node_name)
    for _, excluded in ipairs(excluded_nodes) do
        if node_name == excluded then return true end
    end
    return false
end

function myfortune.assign_rarity(node_name)
    local ultra = {"diamond", "tnt:tnt", "nyancat"}
    local very  = {"gold", "mese", "pick", "shovel", "axe", "sword", "tool"}
    local rare  = {"iron", "copper", "ore", "coal"}

    local function matches(name, keywords)
        for _, k in ipairs(keywords) do if name:find(k) then return true end end
        return false
    end

    if matches(node_name, ultra) then return myfortune.rarity_levels.ultra_rare.weight
    elseif matches(node_name, very) then return myfortune.rarity_levels.very_rare.weight
    elseif matches(node_name, rare) then return myfortune.rarity_levels.rare.weight
    end
    return nil
end

function myfortune.build_drop_list()
    local list = {}
    for item_name, def in pairs(minetest.registered_items) do
        if def and def.description ~= "" and not is_excluded(item_name) 
           and not (def.groups and def.groups.not_in_creative_inventory) then
            local w = myfortune.assign_rarity(item_name)
            if w then table.insert(list, {item = item_name, weight = w}) end
        end
        if def and def.fortune_rarity then
       		return myfortune.rarity_levels[def.fortune_rarity].weight
    	end
    end
    return list
end

myfortune.dynamic_drop_list = myfortune.build_drop_list()

function myfortune.get_random_item()
    local total_weight = 0
    for _, item in ipairs(myfortune.dynamic_drop_list) do total_weight = total_weight + item.weight end
    local rand = math.random(1, total_weight)
    local curr = 0
    for _, item in ipairs(myfortune.dynamic_drop_list) do
        curr = curr + item.weight
        if rand <= curr then
            local amt = math.random(1, math.max(1, 5 - item.weight))
            return {name = item.item, amount = amt, weight = item.weight}
        end
    end
end
