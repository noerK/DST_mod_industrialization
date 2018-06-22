PrefabFiles = {
    "powerplant",
    "electric_light"
}
local Ingredient = GLOBAL.Ingredient
local RECIPETABS = GLOBAL.RECIPETABS
local STRINGS = GLOBAL.STRINGS
local TECH = GLOBAL.TECH

STRINGS.NAMES.POWERPLANT = "Powerplant"
STRINGS.RECIPE_DESC.POWERPLANT = "Here comes electricity!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.POWERPLANT = "A simple generator"

STRINGS.NAMES.ELECTRIC_LIGHT = "Electric Light"
STRINGS.RECIPE_DESC.ELECTRIC_LIGHT = "Light thorugh electricity"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ELECTRIC_LIGHT = "Shiny"


AddRecipe("powerplant", {
    Ingredient("gears", 2), Ingredient("cutstone", 4), Ingredient("transistor", 2)
}, RECIPETABS.LIGHT,  TECH.SCIENCE_TWO, "powerplant_placer")

AddRecipe("electric_light", {
    Ingredient("twigs", 2), Ingredient("lightbulb", 1), Ingredient("transistor", 1)
}, RECIPETABS.LIGHT,  TECH.SCIENCE_TWO, "electric_light_placer")