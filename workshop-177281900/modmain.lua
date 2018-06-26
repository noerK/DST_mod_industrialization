--[NEW] This is how we tell the game we've created a new prefab.
PrefabFiles = {
	--[NEW] This is the name of our prefab file in scripts/prefabs
	"tut03",
}

--This function spawns the creature at the player's position.
function SpawnCreature(player)
	
	--Get the player's current position.
	local x, y, z = player.Transform:GetWorldPosition()

	--[NEW] Spawn our new creature at the world origin.
	local creature = GLOBAL.SpawnPrefab("tut03")

	--Move the creature to the player's position.
	creature.Transform:SetPosition( x, y, z )	
end

--Tell the engine to run the function "SpawnCreature" as soon as the player spawns in the world.
AddSimPostInit(SpawnCreature)