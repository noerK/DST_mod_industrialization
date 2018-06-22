
local function on_is_energized()
    return nil
end

local Energized = Class(function(self, inst)
    self.inst = inst
    self.consuming = false

    self.capacity = 0
    self.current_energy = 0
    self.consumption = 0
    self.is_energized = false
end,
nil,
{
    is_energized = on_is_energized,
})


function Energized:OnRemoveFromEntity()
    self:StopConsuming()
    self.inst:RemoveTag("isEnergized")
end

function Energized:MakeEmpty()
    if self.current_energy > 0 then
        self:DoDelta(-self.current_energy)
    end
end

function Energized:InitializeEnergyLevel(energy)
    if self.capacity < energy then
        self.capacity = energy
    end
    self.current_energy = energy
end

function Energized:OnSave()
    if self.current_energy ~= self.capacity then
        return {energy = self.current_energy}
    end
end

function Energized:OnLoad(data)
    if data.energy then
        self:InitializeEnergyLevel(math.max(0, data.energy))
    end
end

function Energized:IsEmpty()
    return self.current_energy <= 0
end

function Energized:SetOnIsEnergized(fn)
    self.on_is_energized = fn
end

function Energized:GetPercent()
    return self.capacity > 0 and math.max(0, math.min(1, self.current_energy / self.capacity)) or 0
end

function Energized:SetPercent(percent)
    local target = (self.capacity * percent)
    self:DoDelta(target - self.current_energy)
end

function Energized:TransferEnergy(amount)
    self:DoDelta(self.current_energy + amount)
end

local function doConsumption(inst, self)
    self:DoUpdate(self.consumption)
end

function Energized:StartConsuming()
    self.consuming = true
    if self.task == nil then
        self.task = self.inst:DoPeriodicTask(1, doConsumption, nil, self)
    end
end

function Energized:StopConsuming()
    self.consuming = false
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
end

function Energized:DoDelta(amount)
    print("consumption")
    print(self.current_energy)
    self.current_energy = math.max(0, math.min(self.capacity, self.current_energy + amount) )
    print(self.current_energy)
    if not self.inst:HasTag("isEnergized") and self.current_energy > 0 then
        self.inst:AddTag("isEnergized")
        self.is_energized = false
    end

    if self.inst:HasTag("isEnergized") and self.current_energy <= 0 then
        self.inst:RemoveTag("isEnergized")
        self.is_energized = true
    end

    self.inst:PushEvent("percentusedchange", { percent = self:GetPercent() })
end

function Energized:SetUpdateFn(fn)
    self.updatefn = fn
end

function Energized:DoUpdate(delta)
    if self.consuming then
        self:DoDelta(-delta)
    end

    if self:IsEmpty() then
        self:StopConsuming()
    end

    if self.updatefn ~= nil then
        self.updatefn(self.inst)
    end
end

return Energized