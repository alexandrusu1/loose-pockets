local Mod = RegisterMod("Loose Pockets", 1)
local game = Game()
local rng = RNG()

local Config = {
    DropChance = 100,
    DespawnSeconds = 5,
    MaxItems = 1,
    PickupDelay = 30,
    PanicMode = false
}

if ModConfigMenu then
    local Category = "Loose Pockets"
    
    ModConfigMenu.UpdateCategory(Category, {
        Info = "Configure Loose Pockets settings.",
        Note = "Settings apply immediately."
    })

    ModConfigMenu.AddSetting(Category, "General", {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function() return Config.DropChance end,
        Minimum = 0,
        Maximum = 100,
        Display = function() return "Drop Chance: " .. Config.DropChance .. "%" end,
        OnChange = function(n) Config.DropChance = n end,
        Info = "Chance to drop items when taking damage."
    })

    ModConfigMenu.AddSetting(Category, "General", {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function() return Config.DespawnSeconds end,
        Minimum = 1,
        Maximum = 60,
        Display = function() return "Despawn Time: " .. Config.DespawnSeconds .. "s" end,
        OnChange = function(n) Config.DespawnSeconds = n end,
        Info = "How long items stay on floor before vanishing."
    })

    ModConfigMenu.AddSetting(Category, "General", {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function() return Config.MaxItems end,
        Minimum = 1,
        Maximum = 10,
        Display = function() return "Max Drops: " .. Config.MaxItems end,
        OnChange = function(n) Config.MaxItems = n end,
        Info = "Maximum items dropped per hit."
    })

    ModConfigMenu.AddSetting(Category, "Advanced", {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function() return Config.PickupDelay end,
        Minimum = 0,
        Maximum = 90,
        Display = function() return "Pickup Delay: " .. Config.PickupDelay .. " frames" end,
        OnChange = function(n) Config.PickupDelay = n end,
        Info = "Cooldown before you can pick up dropped items (30 frames = 1 sec)."
    })

    ModConfigMenu.AddSetting(Category, "Advanced", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return Config.PanicMode end,
        Display = function() return "Panic Mode: " .. (Config.PanicMode and "ON" or "OFF") end,
        OnChange = function(b) Config.PanicMode = b end,
        Info = "If ON, dropped items are invisible/ghostly."
    })
end

local BLACKLIST = {
    [CollectibleType.COLLECTIBLE_POLAROID] = true,
    [CollectibleType.COLLECTIBLE_NEGATIVE] = true,
    [CollectibleType.COLLECTIBLE_KEY_PIECE_1] = true,
    [CollectibleType.COLLECTIBLE_KEY_PIECE_2] = true,
    [CollectibleType.COLLECTIBLE_KNIFE_PIECE_1] = true,
    [CollectibleType.COLLECTIBLE_KNIFE_PIECE_2] = true,
    [CollectibleType.COLLECTIBLE_DOGMA] = true
}

local function getPlayerPassiveItems(player)
    local items = {}
    for i = 1, CollectibleType.NUM_COLLECTIBLES - 1 do
        if player:HasCollectible(i) and not BLACKLIST[i] then
            table.insert(items, i)
        end
    end
    return items
end

function Mod:OnDamage(entity, amount, flags, source, countdown)
    if not entity or not entity:ToPlayer() then return end
    local player = entity:ToPlayer()
    
    if flags & DamageFlag.DAMAGE_CURSED_DOOR > 0 then return end
    if flags & DamageFlag.DAMAGE_FAKE > 0 then return end
    if flags & DamageFlag.DAMAGE_IV_BAG > 0 then return end
    if flags & DamageFlag.DAMAGE_NO_PENALTIES > 0 then return end
    
    local room = game:GetLevel():GetCurrentRoom()
    if room:GetType() == RoomType.ROOM_SACRIFICE and (flags & DamageFlag.DAMAGE_SPIKES > 0) then
        return
    end

    if rng:RandomInt(100) >= Config.DropChance then return end
    
    local items = getPlayerPassiveItems(player)
    if #items == 0 then return end
    
    local baseDrops = 1
    if amount >= 2 then
        baseDrops = 2
    end
    
    local dropCount = math.min(baseDrops, Config.MaxItems, #items)
    
    for i = 1, dropCount do
        local idx = rng:RandomInt(#items) + 1
        local itemID = items[idx]
        
        player:RemoveCollectible(itemID)
        
        local srcPos = player.Position
        if source and source.Entity then
            srcPos = source.Entity.Position
        end
        
        Mod:SpawnSpilledItem(itemID, player.Position, srcPos, player)
        table.remove(items, idx)
    end
end

function Mod:SpawnSpilledItem(itemID, playerPos, damageSourcePos, player)
    local direction = (playerPos - damageSourcePos):Normalized()
    if direction:Length() == 0 then
        direction = Vector(0, -1)
    end
    
    local angle = rng:RandomFloat() * 60 - 30
    direction = direction:Rotated(angle)
    local velocity = direction * 10
    
    local ent = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, itemID, playerPos, velocity, nil)
    local pickup = ent:ToPickup()
    
    if pickup then
        local data = pickup:GetData()
        data.IsSpilledItem = true
        data.SpillTimer = math.max(1, Config.DespawnSeconds) * 30
        data.OriginalItemID = itemID
        data.SpawnedFrame = game:GetFrameCount()
    end
end

function Mod:OnPickupUpdate(pickup)
    if not pickup or pickup.Type ~= EntityType.ENTITY_PICKUP or pickup.Variant ~= PickupVariant.PICKUP_COLLECTIBLE then return end
    
    local data = pickup:GetData()
    if not data.IsSpilledItem then return end
    
    local currentMaxTime = math.max(1, Config.DespawnSeconds) * 30
    if not data.SpillTimer then data.SpillTimer = currentMaxTime end

    data.SpillTimer = data.SpillTimer - 1
    
    if data.SpillTimer < 60 then
        if data.SpillTimer % 10 < 5 then
            pickup:SetColor(Color(1,1,1,0.5,0,0,0), 2, 1, false, false)
        else
            pickup:SetColor(Color(1,1,1,1,0,0,0), 2, 1, false, false)
        end
    end
    
    if data.SpillTimer <= 0 then
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector(0,0), nil)
        SFXManager():Play(SoundEffect.SOUND_THUMBS_DOWN, 1.0, 0, false, 1.0)
        pickup:Remove()
    end
end

function Mod:OnPrePickupCollision(pickup, collider)
    if not pickup or not pickup:GetData().IsSpilledItem then return end
    
    local spawned = pickup:GetData().SpawnedFrame or 0
    local now = game:GetFrameCount()
    
    if now - spawned < Config.PickupDelay then
        return true
    end
    
    if Config.PanicMode then
        pickup:SetColor(Color(1,1,1,0.5,0,0,0), 2, 1, false, false)
    else
        pickup:SetColor(Color(1,1,1,1,0,0,0), 2, 1, false, false)
    end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Mod.OnDamage, EntityType.ENTITY_PLAYER)
Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, Mod.OnPickupUpdate)
Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Mod.OnPrePickupCollision)