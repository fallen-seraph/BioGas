BioGasMenu = BioGasMenu or {}
BioGasMenu._index = BioGasMenu

local rGood, gGood, bGood = 0,1,0
local rBad, gBad, bBad = 0,1,0
local richGood, richBad, richNeutral = " <RGB:0,1,0> ", " <RGB:1,0,0> ", " <RGB:1,1,1> "

if getCore().getGoodHighlitedColor then
	local good = getCore():getGoodHighlitedColor()
	local bad = getCore():getBadHighlitedColor()
	rGood, gGood, bGood, rBad, gBad, bBad = good:getR(), good:getG(), good:getB(), bad:getR(), bad:getG(), bad:getB()
	richGood, richBad = string.format(" <RGB:%.2f,%.2f,%.2f> ",rGood, gGood, bGood), string.format(" <RGB:%.2f,%.2f,%.2f> ",rBad, gBad, bBad)
end

local function plungeBiowaste (worlobjects,player,homebiogas)
	local character = getSpecificPlayer(player)
		if luautils.walkAdj(character, homebiogas:getSquare(), true) then
			ISTimedActionQueue.add(HBGPlungeBiowaste:new(character, homebiogas))
		end
end

local function siphonMethane (worlobjects,player,homebiogas,tank)
	local character = getSpecificPlayer(player)
	if luautils.walkAdj(character, homebiogas:getSquare(), true) then
		ISTimedActionQueue.add(ISWalkToTimedAction:new(character,homebiogas:getSquare():getS()))
		ISTimedActionQueue.add(HBGSiphonMethane:new(character, homebiogas, tank))
	end
end

local function drainFertilizer (worlobjects,player,homebiogas,bucket)
	local character = getSpecificPlayer(player)
		if luautils.walkAdj(character, homebiogas:getSquare(), true) then
			ISTimedActionQueue.add(HBGDrainFertilizer:new(character, homebiogas, bucket))
		end
end

BioGasMenu.createMenuEntries = function(player, context, worldobjects, test)
	if test and ISWorldObjectContextMenu.Test then return true end

	local homebiogas

	for _,obj in ipairs(worldobjects) do
		local spritename = obj:getSprite() and obj:getSprite():getName()
		if spritename == "biogas_tileset_01_0" then
			homebiogas = obj
		end
	end

	if homebiogas then
		local square = homebiogas:getSquare()
		if test then return ISWorldObjectContextMenu.setTest() end
		local BioGasMenu = context:addOption(getText("ContextMenu_BioGas_BioGasUnit"), worldobjects);
		local BioGasSubMenu = ISContextMenu:getNew(context);
		context:addSubMenu(BioGasMenu, BioGasSubMenu);

		if test then return ISWorldObjectContextMenu.setTest() end
		BioGasSubMenu:addOption(getText("ContextMenu_BioGas_GasUnitStatus"), worldobjects, BioGasStatusWindow.OnOpenPanel, square, player)

		local biowaste = homebiogas:getModData()["biowaste"]

		if biowaste < SandboxVars.BioGas.MaxBiowaste and CBioGasSystem:getIsoObjectOnSquare(square):getContainer():getItems():size() > 0 then
			if test then return ISWorldObjectContextMenu.setTest() end
			BioGasSubMenu:addOption(getText("ContextMenu_BioGas_PlungeFunnel"), worldobjects, plungeBiowaste, player, homebiogas)
		end

		local methane = homebiogas:getModData()["methane"]
		local tank = BioGasUtilities.getPropaneTankNotFull(getSpecificPlayer(player))

		if methane > 0 and tank ~= nil then
			if test then return ISWorldObjectContextMenu.setTest() end
			BioGasSubMenu:addOption(getText("ContextMenu_BioGas_SiphonPropane"), worldobjects, siphonMethane, player, homebiogas, tank)
		end

		local fertilizer = homebiogas:getModData()["fertilizer"]
		local bucket = BioGasUtilities.getBucketNotFull(getSpecificPlayer(player))

		if fertilizer > 0 and bucket ~= nil then
			if test then return ISWorldObjectContextMenu.setTest() end
			BioGasSubMenu:addOption(getText("ContextMenu_BioGas_PickupFertilizer"), worldobjects, drainFertilizer, player, homebiogas, bucket)
		end
	end

end

function BioGasMenu.getRGB()
	return rGood, gGood, bGood, rBad, gBad, bBad
end

function BioGasMenu.getRGBRich()
	return richGood, richBad, richNeutral
end

BioGasFixedGetText = function(getTextString)
	local text = getText(getTextString)
	text = string.gsub(text, '\\n', '\n')
	return text
end


function BioGasMenu.ISInventoryPane_drawItemDetails_patch(drawItemDetails)
	return function(self,item, y, xoff, yoff, red)
		if not item then return end
			local hdrHgt = self.headerHgt
			local top = hdrHgt + y * self.itemHgt + yoff
			local fgBar = {r=0.69, g=0.69, b=0.1, a=1}
			if getCore().getGoodHighlitedColor then --41.78+
				local NewColorInfo = ColorInfo:new()
				getCore():getBadHighlitedColor():interp(getCore():getGoodHighlitedColor(), item:getCondition()/100, NewColorInfo)
				fgBar = {r=NewColorInfo:getR(),g=NewColorInfo:getG(),b=NewColorInfo:getB(),a=1}
			end
			local fgText = {r=0.6, g=0.8, b=0.5, a=0.6}
			if red then fgText = {r=0.0, g=0.0, b=0.5, a=0.7} end
			self:drawTextAndProgressBar(getText("Tooltip_weapon_Condition") .. ":", item:getCondition()/100, xoff, top, fgText, fgBar)
		--end
	end
end


function BioGasMenu.DoTooltip_patch(DoTooltip)
	return function(item,tooltip)
			local lineHeight = tooltip:getLineSpacing()
			local font = tooltip:getFont()
			local y = 5
			--tooltip:render()
			tooltip:DrawText(font, item:getName(), 5, 5, 1, 1, 0.8, 1)
			y = y + lineHeight + 5
			--adjustWidth(5, name;
			local layout = tooltip:beginLayout()
			--setminwidth
			local option
			if tooltip:getWeightOfStack() > 0 then
				option = layout:addItem()
				option:setLabel(getText("Tooltip_item_StackWeight")..":",1,1,0.8,1)
				option:setValueRightNoPlus(tooltip:getWeightOfStack())
			else
				option = layout:addItem()
				option:setLabel(getText("Tooltip_item_Weight")..":",1,1,0.8,1)
				if item:isEquipped() or item:getAttachedSlot() > -1 then
					option:setValue(string.format("%.2f    (%.2f %s) ",item:getEquippedWeight(),item:getUnequippedWeight(),getText("Tooltip_item_Unequipped")),1,1,0.8,1)
				else
					option:setValue(string.format("%.2f    (%.2f %s) ",item:getUnequippedWeight(),item:getEquippedWeight(),getText("Tooltip_item_Equipped")),1,1,0.8,1)
				end
				option = layout:addItem()
				option:setLabel(getText("IGUI_invpanel_Remaining")..":",1,1,0.8,1)
				option:setValue(string.format("%d%%",item:getUsedDelta()*100),1,1,0.8,1)
				option = layout:addItem()
				option:setLabel(getText("Tooltip_weapon_Condition")..":",1,1,0.8,1)
				option:setValue(string.format("%d%%",item:getCondition()),1,1,0.8,1)
				option = layout:addItem()
				option:setLabel(getText("Tooltip_container_Capacity")..":",1,1,0.8,1)
				--option:setValue(string.format("%d / %d",max * (1 - math.pow((1 - (item:getCondition()/100)),6)),max),1,1,0.8,1)
			end
			y = layout:render(5,y,tooltip)
			tooltip:endLayout(layout)
			--tooltip:setWidth(tooltip:getWidth())
			tooltip:setHeight(y+5)
		--end
	end
end

Events.OnFillWorldObjectContextMenu.Add(BioGasMenu.createMenuEntries)