require "prefabutil"

local easing = require("easing")

local assets =
{
    Asset("ANIM", "anim/firefighter.zip"),
    Asset("ANIM", "anim/firefighter_placement.zip"),
    Asset("ANIM", "anim/firefighter_meter.zip"),
}

local glow_assets =
{
    Asset("ANIM", "anim/firefighter_glow.zip"),
}

local prefabs =
{
    "snowball",
    "collapse_small",
    "powerplant_glow",
}

local detectTask = nil

local WarningColours =
{
    green = { 163 / 255, 255 / 255, 186 / 255 },
    yellow = { 255 / 255, 228 / 255, 81 / 255 },
    red = { 255 / 255, 146 / 255, 146 / 255 },
}


local function fuel_nearby_takers(inst)
    local x,y,z = inst.Transform:GetWorldPosition()
    local nearbyTakers = TheSim:FindEntities(x,y,z, 20, "electric_light")
    for i, v in ipairs(nearbyTakers) do
        if v.components.energized then
            local delta = v.components.energized.capacity - v.components.energized.current_energy
            inst.components.fueled:DoDelta(-(delta/10))
            v.components.energized:DoDelta(delta)
        end
    end
end

local function Cancel(inst)
    if detectTask ~= nil then
        detectTask:Cancel()
        detectTask = nil
    end
end

function taker_fueler_activate(inst)
    Cancel(inst)
    detectTask = inst:DoPeriodicTask(5, fuel_nearby_takers, 5)
end

function taker_fueler_deactivate(inst)
    Cancel(inst)
end


local function TurnOff(inst, instant)
    inst.on = false
    inst.components.fueled:StopConsuming()
    taker_fueler_deactivate(inst)
    inst.sg:GoToState(instant and "idle_off" or "turn_off")
end

local function TurnOn(inst, instant)
    inst.on = true
    inst.components.fueled:StartConsuming()
    taker_fueler_activate(inst)
    inst.sg:GoToState(instant and "idle_on" or "turn_on")
end


local function OnFuelEmpty(inst)
    inst.components.machine:TurnOff()
end

local function OnAddFuel(inst)
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/machine_fuel")
    if inst.on == false then
        inst.components.machine:TurnOn()
    end
end

local function OnFuelSectionChange(new, old, inst)
    if inst._fuellevel ~= new then
        inst._fuellevel = new
        inst.AnimState:OverrideSymbol("swap_meter", "firefighter_meter", tostring(new))
    end
end

local function CanInteract(inst)
    return not inst.components.fueled:IsEmpty()
end

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.SoundEmitter:KillSound("firesuppressor_idle")
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function onhit(inst, worker)
    if not (inst:HasTag("burnt") or inst.sg:HasStateTag("busy")) then
        inst.sg:GoToState("hit", inst.sg:HasStateTag("light"))
    end
end

local function getstatus(inst, viewer)
    return inst.components.fueled ~= nil
        and inst.components.fueled.currentfuel / inst.components.fueled.maxfuel <= .25
        and "LOWFUEL"
        or "ON"
end

local function OnEntitySleep(inst)
    inst.SoundEmitter:KillSound("firesuppressor_idle")
end

local function OnRemoveEntity(inst)
    inst._glow:Remove()
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt and inst.components.burnable ~= nil and inst.components.burnable.onburnt ~= nil then
        inst.components.burnable.onburnt(inst)
    end
end

local function oninit(inst)
    inst._glow.Follower:FollowSymbol(inst.GUID, "swap_glow", 0, 0, 0)
end

local function onbuilt(inst)
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_craft")
end





--------------------------------------------------------------------------
local PLACER_SCALE = 1.55

local function OnEnableHelper(inst, enabled)
    if enabled then
        if inst.helper == nil then
            inst.helper = CreateEntity()

            --[[Non-networked entity]]
            inst.helper.entity:SetCanSleep(false)
            inst.helper.persists = false

            inst.helper.entity:AddTransform()
            inst.helper.entity:AddAnimState()

            inst.helper:AddTag("CLASSIFIED")
            inst.helper:AddTag("NOCLICK")
            inst.helper:AddTag("placer")

            inst.helper.Transform:SetScale(PLACER_SCALE, PLACER_SCALE, PLACER_SCALE)

            inst.helper.AnimState:SetBank("firefighter_placement")
            inst.helper.AnimState:SetBuild("firefighter_placement")
            inst.helper.AnimState:PlayAnimation("idle")
            inst.helper.AnimState:SetLightOverride(1)
            inst.helper.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
            inst.helper.AnimState:SetLayer(LAYER_BACKGROUND)
            inst.helper.AnimState:SetSortOrder(1)
            inst.helper.AnimState:SetAddColour(0, .2, .5, 0)

            inst.helper.entity:SetParent(inst.entity)
        end
    elseif inst.helper ~= nil then
        inst.helper:Remove()
        inst.helper = nil
    end
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetPriority(5)
    inst.MiniMapEntity:SetIcon("firesuppressor.png")

    MakeObstaclePhysics(inst, 1)

    inst.AnimState:SetBank("firefighter")
    inst.AnimState:SetBuild("firefighter")
    inst.AnimState:PlayAnimation("idle_off")
    inst.AnimState:OverrideSymbol("swap_meter", "firefighter_meter", "10")

    inst:AddTag("structure")

    inst.Light:SetIntensity(.4)
    inst.Light:SetRadius(.8)
    inst.Light:SetFalloff(1)
    inst.Light:SetColour(unpack(WarningColours.green))
    inst.Light:Enable(false)

    --Dedicated server does not need deployhelper
    if not TheNet:IsDedicated() then
        inst:AddComponent("deployhelper")
        inst.components.deployhelper.onenablehelper = OnEnableHelper
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._fuellevel = 10

    inst._glow = SpawnPrefab("powerplant_glow")
    inst:DoTaskInTime(0, oninit)
    inst:ListenForEvent("onbuilt", onbuilt)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("machine")
    inst.components.machine.turnonfn = TurnOn
    inst.components.machine.turnofffn = TurnOff
    inst.components.machine.caninteractfn = CanInteract
    inst.components.machine.cooldowntime = 0.5

    inst:AddComponent("fueled")
    inst.components.fueled:SetDepletedFn(OnFuelEmpty)
    inst.components.fueled:SetTakeFuelFn(OnAddFuel)
    inst.components.fueled.accepting = true
    inst.components.fueled:SetSections(10)
    inst.components.fueled:SetSectionCallback(OnFuelSectionChange)
    inst.components.fueled:InitializeFuelLevel(TUNING.FIRESUPPRESSOR_MAX_FUEL_TIME)
    inst.components.fueled.bonusmult = 5
    inst.components.fueled.secondaryfueltype = FUELTYPE.CHEMICAL


    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:SetStateGraph("SGpowerplant")

    inst.OnSave = onsave
    inst.OnLoad = onload
    --inst.OnLoadPostPass = OnLoadPostPass
    inst.OnEntitySleep = OnEntitySleep
    inst.OnRemoveEntity = OnRemoveEntity

    inst.components.machine:TurnOn()

    MakeHauntableWork(inst)

    return inst
end

local function onfade(inst)
    if inst._ison:value() then
        local df = math.max(.1, (1 - inst._fade) * .5)
        inst._fade = inst._fade + df
        if inst._fade >= 1 then
            inst._fade = 1
            inst._task:Cancel()
            inst._task = nil
        end
        inst.AnimState:OverrideMultColour(inst._fade, inst._fade, inst._fade, inst._fade)
    else
        local df = math.max(.1, inst._fade * .5)
        inst._fade = inst._fade - df
        if inst._fade <= 0 then
            inst._fade = 0
            inst._task:Cancel()
            inst._task = nil
        end
        inst.AnimState:OverrideMultColour(inst._fade, inst._fade, inst._fade, inst._fade)
    end
end

local function onisondirty(inst)
    if inst._task == nil and (inst._ison:value() and 1 or 0) ~= inst._fade then
        inst._task = inst:DoPeriodicTask(FRAMES, onfade, 0)
    end
end

local function oninitglow(inst)
    if inst._ison:value() then
        inst.AnimState:OverrideMultColour(1, 1, 1, 1)
        inst._fade = 1
    end
    inst:ListenForEvent("onisondirty", onisondirty)
end

local function glow_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("firefighter_glow")
    inst.AnimState:SetBuild("firefighter_glow")
    inst.AnimState:PlayAnimation("green", true)
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetFinalOffset(-1)
    inst.AnimState:OverrideMultColour(0, 0, 0, 0)

    inst._ison = net_bool(inst.GUID, "powerplant_glow._ison", "onisondirty")
    inst._fade = 0
    inst._task = nil
    inst:DoTaskInTime(0, oninitglow)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function placer_postinit_fn(inst)
    --Show the flingo placer on top of the flingo range ground placer

    local placer2 = CreateEntity()

    --[[Non-networked entity]]
    placer2.entity:SetCanSleep(false)
    placer2.persists = false

    placer2.entity:AddTransform()
    placer2.entity:AddAnimState()

    placer2:AddTag("CLASSIFIED")
    placer2:AddTag("NOCLICK")
    placer2:AddTag("placer")

    local s = 1 / PLACER_SCALE
    placer2.Transform:SetScale(s, s, s)

    placer2.AnimState:SetBank("firefighter")
    placer2.AnimState:SetBuild("firefighter")
    placer2.AnimState:PlayAnimation("idle_off")
    placer2.AnimState:SetLightOverride(1)

    placer2.entity:SetParent(inst.entity)

    inst.components.placer:LinkEntity(placer2)
end

return Prefab("powerplant", fn, assets, prefabs),
    Prefab("powerplant_glow", glow_fn, glow_assets),
    MakePlacer("powerplant_placer", "powerplant_placement", "powerplant_placement", "idle", true, nil, nil, PLACER_SCALE, nil, nil, placer_postinit_fn)
