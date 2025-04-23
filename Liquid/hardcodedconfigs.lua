local _n, ns = ...
LiquidAPI = {}

ns.isDragonflight = select(4, GetBuildInfo()) < 110000
if GetCurrentRegion() == 72 then -- beta
  ns.isTestRealm = true
elseif PTR_IssueReporter or IsTestBuild() then -- ptr
  ns.isTestRealm = true
end
ns.configs = {
  lootTracking = true,
  cacheCharacters = true,
  importWeakAuras = true,
}