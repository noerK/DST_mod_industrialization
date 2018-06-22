name = "A POWER MOD"
description = "power power power power"
author = "noerK"
version = "0.0.1"

--[[

]]

icon_atlas = "preview.xml"
icon = "preview.tex"

forumthread = ""

api_version = 10

priority = 1

server_filter_tags = {"electricity", "power", "light"}

dst_compatible = true

client_only_mod = false
all_clients_require_mod = true

configuration_options = {}

local multiplicator_options = {}
for i=0,30 do
	multiplicator_options[i+1] = {
		description = "" .. (i*10) .. "%",
		data = ((i*10)/100)
	}
end

local static_options = {}
for i=-40,40 do
	static_options[i+41] = {
		description = "" .. (i*5) .. "",
		data = (i*5)
	}
end

local boolean_options = {
	{
		description = "Yes",
		data = true
	},
	{
		description = "No",
		data = false
	},
}

local alphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
local key_options = {}
for i=1,#alphabet do
	key_options[i] = {description = alphabet[i], data = 96 + i}
end

local function addMultiplicatorSetting(name, label, default, hover)
	configuration_options[#configuration_options + 1] = {
		name = name,
		label = label,
		options = multiplicator_options,
		default = default or 1,
		hover = hover or nil
	}
end

local function addStaticSetting(name, label, default, hover)
	configuration_options[#configuration_options + 1] = {
		name = name,
		label = label,
		options = static_options,
		default = default or 0,
		hover = hover or nil
	}
end

local function addBooleanSetting(name, label, default, hover)
	configuration_options[#configuration_options + 1] = {
		name = name,
		label = label,
		options = boolean_options,
		default = default or true,
		hover = hover or nil
	}
end

local function addKeyBindingSetting(name, label, default, hover)
	configuration_options[#configuration_options + 1] = {
		name = name,
		label = label,
		options = key_options,
		default = 110,
		hover = hover or nil
	}
end
