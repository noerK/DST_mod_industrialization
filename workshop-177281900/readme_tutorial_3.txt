Creature Mod Tutorial 3 - "Importing animation from Spriter"

In this tutorial we're going to import a brand new creature from 'Spriter'.  Spriter is a 2D animation tool that comes packaged with the Don't Starve Mod tools.  Let's get started!

	* Step 1 - Importing a Spriter Project
	Spriter saves it's data to '.scml' files.  To import a Spriter project, all we need to do is copy the Spriter '.scml' file and all of it's images to a subfolder in our mod called 'exported'.  In this tutorial's case, the spriter file is called 'tut03.scml'.

	* Step 2 - Creating a Prefab.
	All objects in 'Don't Starve' are spawned from prefabs.  A prefab is a way of defining an object that can be spawned in the game.  So to spawn our newly imported Spriter creature, we need to create a new prefab.  To add a new prefab, you need to create a subfolder for your mod called 'scripts' and inside that folder, create another subfolder called 'prefabs'.  This is where we put new prefabs create by our mod.  For this tutorial, our prefab file is called 'tut03.lua'.

	* Step 3 - Registering our Prefab.
	Everything our mod contains needs to be registered within 'modmain.lua'.  In this case we want to register a new prefab so at the top of 'modmain.lua' we need to list our prefab files.

	* Step 4 - Spawning our Prefab.
	We now need to spawn an instance of our prefab in game.  So again in 'modmain.lua' we need to change our 'SpawnCreature' function to spawn our new prefab instead of the Beefalo.

And that's it!  If you've followed all the steps correctly, you should now see your creature spawn in game and play it's idle animation!