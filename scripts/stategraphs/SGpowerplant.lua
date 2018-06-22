local events = {}
local states =
{
    State{
        name = "turn_on",
        tags = { "idle" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_on")
            inst.AnimState:PlayAnimation("turn_on")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_on")
            end),
        }
    },

    State{
        name = "turn_off",
        tags = { "idle" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_off")
            inst.AnimState:PlayAnimation("turn_off")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_off")
            end),
        }
    },

    State{
        name = "idle_on",
        tags = { "idle" },

        onenter = function(inst)
            if not inst.SoundEmitter:PlayingSound("firesuppressor_idle") then
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_idle", "firesuppressor_idle")
            end
            inst.AnimState:PlayAnimation("idle_on_loop")
        end,

        timeline =
        {
            TimeEvent(16 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_chuff")
            end)
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_on")
            end),
        }
    },

    State{
        name = "idle_off",
        tags = { "idle" },

        onenter = function(inst)
            inst.SoundEmitter:KillSound("firesuppressor_idle")
            inst.AnimState:PlayAnimation("idle_off", true)
        end,
    },

    State{
        name = "light_on",
        tags = { "idle", "light" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("light_on")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_light_on")
            end),
        },
    },

    State{
        name = "light_off",
        tags = { "idle" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_off")
            inst.AnimState:PlayAnimation("light_off")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_off")
            end),
        },
    },

    State{
        name = "idle_light_on",
        tags = { "idle", "light" },

        onenter = function(inst)
            if not inst.SoundEmitter:PlayingSound("firesuppressor_idle") then
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_idle", "firesuppressor_idle")
            end
            inst.AnimState:PlayAnimation("idle_light_loop", true)
        end,

    },

    State{
        name = "turn_on_light",
        tags = { "idle" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_on")
            inst.AnimState:PlayAnimation("turn_on_light")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_on")
            end),
        }
    },

    State{
        name = "hit",
        tags = { "busy" },

        onenter = function(inst, light)
            if inst.on then
                inst.AnimState:PlayAnimation("hit_on")
            else
                inst.sg.statemem.light = light
                inst.AnimState:PlayAnimation(light and "hit_light" or "hit_off")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.on then
                    inst.sg:GoToState("idle_on")
                else
                    inst.sg:GoToState(inst.sg.statemem.light and "idle_light_on" or "idle_off")
                end
            end),
        },
    },
}

return StateGraph("powerplant", states, events, "idle_off")
