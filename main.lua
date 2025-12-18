-- Loose Pockets
-- Version: 1.0
-- Autor: alexandrusu1
-- https://github.com/alexandrusu1/loose-pockets


local Mod = RegisterMod("Loose Pockets", 1)
local game = Game()
local rng = RNG()

local DROP_CHANCE = 1.0
local DESPAWN_TIMER = 150
local BLACKLIST = {
    [CollectibleType.COLLECTIBLE_POLAROID] = true,
    [CollectibleType.COLLECTIBLE_NEGATIVE] = true,
    [CollectibleType.COLLECTIBLE_KEY_PIECE_1] = true,
    [CollectibleType.COLLECTIBLE_KEY_PIECE_2] = true,
    [CollectibleType.COLLECTIBLE_KNIFE_PIECE_1] = true,
    [CollectibleType.COLLECTIBLE_KNIFE_PIECE_2] = true
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
    if math.random() > DROP_CHANCE then return end
    local items = getPlayerPassiveItems(player)
    if #items == 0 then return end
    local dropCount = 1
    if amount >= 2 then
        dropCount = 2
    end
    for i = 1, math.min(dropCount, #items) do
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
    local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, itemID, playerPos, velocity, player):ToPickup()
    if pickup then
        pickup:GetData().IsSpilledItem = true
        pickup:GetData().SpillTimer = DESPAWN_TIMER
    end
end

function Mod:OnPickupUpdate(pickup)
    if not pickup:GetData().IsSpilledItem then return end
    pickup:GetData().SpillTimer = pickup:GetData().SpillTimer - 1
    if pickup:GetData().SpillTimer < 60 then
        if pickup:GetData().SpillTimer % 10 < 5 then
            pickup:SetColor(Color(1,1,1,0.5,0,0,0), 2, 1, false, false)
        else
            pickup:SetColor(Color(1,1,1,1,0,0,0), 2, 1, false, false)
        end
    end
    if pickup:GetData().SpillTimer <= 0 then
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector(0,0), nil)
        SFXManager():Play(SoundEffect.SOUND_THUMBS_DOWN, 1.0, 0, false, 1.0)
        pickup:Remove()
    end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Mod.OnDamage, EntityType.ENTITY_PLAYER)
Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, Mod.OnPickupUpdate, PickupVariant.PICKUP_COLLECTIBLE)
