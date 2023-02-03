require "TimedActions/ISBaseTimedAction"

HBGPlungeBiowaste = ISBaseTimedAction:derive("HBGPlungeBiowaste");

function HBGPlungeBiowaste:isValid()
    return self.homebiogas:getObjectIndex() ~= -1 and self.homebiogas:getSquare():isOutside()
end

function HBGPlungeBiowaste:start()
    self:setActionAnim("Loot")
	self.character:SetVariable("LootPosition", "Mid")
    self.character:reportEvent("EventLootItem")
end

function HBGPlungeBiowaste:waitToStart()
    self.character:faceThisObject(self.homebiogas)
    return self.character:shouldBeTurning()
end

function HBGPlungeBiowaste:update()
    self.character:faceThisObject(self.homebiogas)
end

function HBGPlungeBiowaste:stop()
    self.character:stopOrTriggerSound(self.sound)

    ISBaseTimedAction.stop(self);
end

function HBGPlungeBiowaste:perform()

    if self.homebiogas:getContainer():getAllCategory("Food"):size() > 0 then
        CBioGasSystem.instance:sendCommand(self.character,"plungeBiowaste", { { x = self.homebiogas:getX(), y = self.homebiogas:getY(), z = self.homebiogas:getZ() }})
    else
        self.character:Say(getText("IGUI_BioGas_ContainerEmpty"))
    end

    ISInventoryPage.renderDirty = true

    ISBaseTimedAction.perform(self);
end

function HBGPlungeBiowaste:new(character, homebiogas)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.homebiogas = homebiogas
    o.stopOnWalk = true;
    o.stopOnRun = true;
    o.stopOnAim = false
    o.maxTime = (90 - (character:getPerkLevel(Perks.Farming) - 3) * 10) * 2 * getGameTime():getMinutesPerDay() / 10 --2 hours at level 3, ~half at level 10 --- temp /10
    if o.character:isTimedActionInstant() then
        o.maxTime = 1
    end
    return o;
end
