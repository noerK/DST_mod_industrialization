require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/electric_light.zip"),
}


local function onUpdateLight(inst)

    if not inst._isPowerOn:value() then
        inst.Light:SetRadius(0)
        inst.Light:SetIntensity(0)
        inst.Light:SetFalloff(0)
        inst.AnimState:PlayAnimation("idle")
    else
        inst.Light:SetRadius(inst.light_params.radius)
        inst.Light:SetIntensity(inst.light_params.intensity)
        inst.Light:SetFalloff(inst.light_params.falloff)
        inst.AnimState:PlayAnimation("idle_on")
    end

    if TheWorld.ismastersim then
        inst.Light:Enable(inst._isPowerOn:value())
    end
end

local function onhammered(inst, worker)
    local x, y, z = inst.Transform:GetWorldPosition()
    inst.components.lootdropper:DropLoot()
    inst:Remove()
end

local function onhit(inst, worker)
    inst.AnimState:PlayAnimation("grow")
    if inst.components.energized.is_energized == true then
        inst.AnimState:PushAnimation("idle_on")
    else
        inst.AnimState:PushAnimation("idle")
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("grow")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/lightningrod")
    inst._is_built = true
end

local function PowerOn(inst)
    if inst._isPowerOn ~= true then
        inst._isPowerOn:set(true)
        inst:UpdateLight()
        inst.components.energized:StartConsuming()
    end
end

local function PowerOff(inst)
    if inst._isPowerOn ~= false then
        inst._isPowerOn:set(false)
        inst:UpdateLight()
        inst.components.energized:StopConsuming()
    end
end


local function onEnergyChange(inst)
    if inst:HasTag("isEnergized") and inst.switchState == "ON" then
        PowerOn(inst)
    else
        PowerOff(inst)
    end
end

local function SetSwitchState(inst, state)
    inst.switchState = state
    onEnergyChange(inst)
end


local function SwitchOn(inst)
    inst:SetSwitchState("ON")
end

local function SwitchOff(inst)
    inst:SetSwitchState("OFF")
end

local function OnSave(inst, data)
    data.switchState = inst.switchState
end

local function OnLoad(inst, data)
    if data == nil then return end
    inst.switchState = data.switchState
    onEnergyChange(inst)
end



local function GetDebugString(inst)
    return string.format("State: %s", inst.switchState)
end

local function getStatus(inst)
    if inst:HasTag("isEnergized") == true then
        return "shiny"
    else
        return "It needs some volts i guess"
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddLightWatcher()
    inst.entity:AddNetwork()

    inst.LightWatcher:SetLightThresh(.075)
    inst.LightWatcher:SetDarkThresh(.05)

    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(0)
    inst.Light:SetRadius(0)
    inst.Light:SetColour(237/255, 237/255, 209/255)
    inst.Light:Enable(false)
    inst.Light:EnableClientModulation(true)

    inst.AnimState:SetBank("electric_light")
    inst.AnimState:SetBuild("electric_light")
    inst.AnimState:PlayAnimation("idle")

    inst.MiniMapEntity:SetIcon("bulb_plant.png")
    inst.MiniMapEntity:SetPriority(0.1)

    inst.light_params = {
        falloff = .5,
        intensity = .8,
        radius = 3,
    }

    inst.UpdateLight = onUpdateLight
    inst._isPowerOn = net_bool(inst.GUID, "electric_light._isPowerOn", "isPowerOn_net")

    inst:AddTag("structure")

    MakeObstaclePhysics(inst, .3)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("isPowerOn_net", onUpdateLight)

        return inst
    end

    -----------------------
    inst.switchState = "ON"

    local color = 0.75 + math.random() * 0.25
    inst.AnimState:SetMultColour(color, color, color, 1)

    -------------------------
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(2)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("energized")
    inst.components.energized.capacity = 100
    inst.components.energized.consumption = 10
    inst.components.energized:SetOnIsEnergized(onEnergyChange)
    -----------------------------

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getStatus

    inst.SetLightState = SetSwitchState

    inst.SwitchOn = SwitchOn

    inst:ListenForEvent("percentusedchange", onEnergyChange)

    inst.OnLoad = OnLoad
    inst.OnSave = OnSave
    inst.debugstringfn = GetDebugString

    onEnergyChange(inst)

    inst:ListenForEvent("onbuilt", onbuilt)

    return inst
end

return Prefab("electric_light", fn, assets, prefabs),
    MakePlacer("electric_light_placer", "electric_light_placement", "electric_light_placement", "idle")
