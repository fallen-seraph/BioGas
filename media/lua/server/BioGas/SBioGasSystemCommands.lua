if isClient() then
    return
end
require "BioGas/SBioGasSystem"

local Commands = {}

--local function print(message) SBioGasSystem.instance:print(message) end

local function getLuaBioGas(args)
    return SBioGasSystem.instance:getLuaObjectAt(args.x, args.y, args.z)
end

local function getIsoBioGas(luaObject)
    return luaObject:getIsoObject()
end

function Commands.plungeBiowaste(player,args)
    local waste = 0
    local maxWaste = SandboxVars.BioGas.MaxBiowaste
    local hbg = getLuaBioGas(args[1])
    local isohbg = getIsoBioGas(hbg)
    
    if isohbg then
        if not (hbg.biowaste == maxWaste) then
            local biowastecontainer = isohbg:getContainer()
            local foodList = biowastecontainer:getAllCategory("Food")
            
            if foodList:size() > 0 then
                for v=1,foodList:size() do
                    local item = foodList:get(v-1)
                    if hbg.biowaste < maxWaste then
                        hbg.biowaste = hbg.biowaste + item:getCalories()
                        if item:getReplaceOnUse() then biowastecontainer:AddItem(item:getReplaceOnUse()) end
                        biowastecontainer:Remove(item)
                    end
                end

                if hbg.biowaste > maxWaste then
                    hbg.biowaste = maxWaste
                end

                isohbg:sendObjectChange("containers")
                hbg:saveData(true)
            end
        end
    end
end

function Commands.siphonMethane(player, args)
    local hbg = getLuaBioGas(args[1])
    local isohbg = getIsoBioGas(hbg)

    if isohbg then
        hbg.methane = hbg.methane - args[2]
        if hbg.methane < 0 then
            hbg.methane = 0
        end
        
        hbg:saveData(true)
    end
end


function Commands.drainFertilizer(player, args)
    local hbg = getLuaBioGas(args[1])
    local isohbg = getIsoBioGas(hbg)

    if isohbg then
        hbg.fertilizer = hbg.fertilizer - args[2]
        if hbg.fertilizer < 0 then
            hbg.fertilizer = 0
        end
        
        hbg:saveData(true)
    end
end

SBioGasSystemCommands = Commands
