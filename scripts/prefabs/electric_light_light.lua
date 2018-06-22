local lightColour = { 0, 183 / 255, 1 }
local function GetHeatFn(inst)
    return  0
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()
    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("heater")
    inst.components.heater.heatfn = GetHeatFn
    inst.components.heater:SetThermics(false, true)

    inst:AddComponent("firefx")
    inst.components.firefx.levels =
    {
        { anim = "level1", sound = "", radius = 5, intensity = .8, falloff = .33, colour = lightColour, soundintensity = 0 },
    }
    inst.components.firefx:SetLevel(1)
    inst.components.firefx.usedayparamforsound = false

    return inst
end

return Prefab("electric_light_light", fn, assets)