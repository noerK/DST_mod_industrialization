--[NEW] Here we list any assets required by our prefab.
local assets=
{
	--[NEW] this is the name of the Spriter file.
	Asset("ANIM", "anim/tut03.zip"),
}

--[NEW] This function creates a new entity based on a prefab.
local function init_prefab()

	--[NEW] First we create an entity.
	local inst = CreateEntity()

	--[NEW] Then we add a transform component se we can place this entity in the world.
	local trans = inst.entity:AddTransform()

	--[NEW] Then we add an animation component which allows us to animate our entity.
	local anim = inst.entity:AddAnimState()
	
	--[NEW] The bank name is the name of the Spriter file.
    anim:SetBank("tut03")

    --[NEW] The build name is the name of the animation folder in spriter.
    anim:SetBuild("tut03")

    --[NEW] Here we start playing the 'idle' animation and tell it to loop.
    anim:PlayAnimation("idle", true )

    --[NEW] return our new entity so that it can be added to the world.
    return inst
end

--[NEW] Here we register our new prefab so that it can be used in game.
return Prefab( "monsters/tut03", init_prefab, assets, nil)
