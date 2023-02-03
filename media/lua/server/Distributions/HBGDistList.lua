--fixme SandboxVars are default value at this stage, MP are loaded already OnPreDistributionMerge, SP are not

require 'Items/Distributions'
require 'Items/ProceduralDistributions'


local function registerAsLoot(item, chance, allocation)
  table.insert(ProceduralDistributions.list[allocation].items, item);
  table.insert(ProceduralDistributions.list[allocation].items, chance);
end

local iReg = "";

-- IBC
iReg = "Biofuel.IBCEmpty";
registerAsLoot(iReg, 0.25, "ArmyHangarTools");
registerAsLoot(iReg, 1.00, "ArmySurplusTools");
registerAsLoot(iReg, 1.00, "CrateFarming");
registerAsLoot(iReg, 0.25, "CrateRandomJunk");
registerAsLoot(iReg, 0.25, "GardenStoreTools");
registerAsLoot(iReg, 1.00, "ToolStoreFarming");
registerAsLoot(iReg, 0.25, "ToolStoreMisc");
registerAsLoot(iReg, 5.00, "Homesteading");
registerAsLoot(iReg, 0.05, "MechanicSpecial");


iReg = "Biofuel.BacteriaStarter";
registerAsLoot(iReg, 1.00, "GigamartBakingMisc");
registerAsLoot(iReg, 1.00, "GigamartDryGoods");
registerAsLoot(iReg, 0.50, "GroceryStorageCrate1");
registerAsLoot(iReg, 0.50, "GardenStoreMisc");
registerAsLoot(iReg, 0.50, "CrateCanning");
registerAsLoot(iReg, 3.00, "Homesteading");

if SandboxVars.BioGas.spawnIndustrialTanks then
  iReg = "Biofuel.IndustrialPropaneTank";
  registerAsLoot(iReg, 0.15, "CrateMetalwork");
  registerAsLoot(iReg, 0.20, "CratePropane");
  registerAsLoot(iReg, 0.10, "MetalShopTools");
end