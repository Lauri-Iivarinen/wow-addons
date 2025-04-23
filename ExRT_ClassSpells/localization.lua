local GlobalAddonName, ExRT = ...

local L = ExRT.L

if ExRT.locale == "ruRU" then
	L.scspells = "Классы"
elseif ExRT.locale == "zhCN" then
	L.scspells = "职业技能"
elseif ExRT.locale == "deDE" then
	L.scspells = "Klassen"
elseif ExRT.locale == "koKR" then
	L.scspells = "직업"
elseif ExRT.locale == "zhTW" then
	L.scspells = "職業法術預覽"
else
	L.scspells = "Classes"
end