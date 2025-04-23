local addonName, ns = ...

local sformat = string.format
local function addonPrint(msg)
  print(sformat("LiquidWeakAuras: %s", msg))
end

--#region Serializer stuff 
--all of these libs are loaded by WA, and we don't use them outside of WA imports, so we don't need to include them
local Compresser = LibStub:GetLibrary("LibCompress")
local LibDeflate = LibStub:GetLibrary("LibDeflate")
local Serializer = LibStub:GetLibrary("AceSerializer-3.0")
local LibSerialize = LibStub("LibSerialize")
-- Because we want to duplicate behaviour from WeakAuras, most of these are yoinked from WeakAuras/Transmission.lua


local configForDeflate = {level = 9}
local configForLS = {
  errorOnUnserializableType =  false
}

local tooltipLoading;
local receivedData;

local bytetoB64 = {
  [0]="a","b","c","d","e","f","g","h",
  "i","j","k","l","m","n","o","p",
  "q","r","s","t","u","v","w","x",
  "y","z","A","B","C","D","E","F",
  "G","H","I","J","K","L","M","N",
  "O","P","Q","R","S","T","U","V",
  "W","X","Y","Z","0","1","2","3",
  "4","5","6","7","8","9","(",")"
}

local B64tobyte = {
  a =  0,  b =  1,  c =  2,  d =  3,  e =  4,  f =  5,  g =  6,  h =  7,
  i =  8,  j =  9,  k = 10,  l = 11,  m = 12,  n = 13,  o = 14,  p = 15,
  q = 16,  r = 17,  s = 18,  t = 19,  u = 20,  v = 21,  w = 22,  x = 23,
  y = 24,  z = 25,  A = 26,  B = 27,  C = 28,  D = 29,  E = 30,  F = 31,
  G = 32,  H = 33,  I = 34,  J = 35,  K = 36,  L = 37,  M = 38,  N = 39,
  O = 40,  P = 41,  Q = 42,  R = 43,  S = 44,  T = 45,  U = 46,  V = 47,
  W = 48,  X = 49,  Y = 50,  Z = 51,["0"]=52,["1"]=53,["2"]=54,["3"]=55,
  ["4"]=56,["5"]=57,["6"]=58,["7"]=59,["8"]=60,["9"]=61,["("]=62,[")"]=63
}

-- This code is based on the Encode7Bit algorithm from LibCompress
-- Credit goes to Galmok (galmok@gmail.com)
local decodeB64Table = {}

local function decodeB64(str)
  local bit8 = decodeB64Table;
  local decoded_size = 0;
  local ch;
  local i = 1;
  local bitfield_len = 0;
  local bitfield = 0;
  local l = #str;
  while true do
    if bitfield_len >= 8 then
      decoded_size = decoded_size + 1;
      bit8[decoded_size] = string_char(bit_band(bitfield, 255));
      bitfield = bit_rshift(bitfield, 8);
      bitfield_len = bitfield_len - 8;
    end
    ch = B64tobyte[str:sub(i, i)];
    bitfield = bitfield + bit_lshift(ch or 0, bitfield_len);
    bitfield_len = bitfield_len + 6;
    if i > l then
      break;
    end
    i = i + 1;
  end
  return table.concat(bit8, "", 1, decoded_size)
end

local function StringToTable(inString, fromChat)
  -- encoding format:
  -- version 0: simple b64 string, compressed with LC and serialized with AS
  -- version 1: b64 string prepended with "!", compressed with LD and serialized with AS
  -- version 2+: b64 string prepended with !WA:N! (where N is encode version)
  --   compressed with LD and serialized with LS
  local _, _, encodeVersion, encoded = inString:find("^(!WA:%d+!)(.+)$")
  if encodeVersion then
    encodeVersion = tonumber(encodeVersion:match("%d+"))
  else
    encoded, encodeVersion = inString:gsub("^%!", "")
  end

  local decoded
  if(fromChat) then
    if encodeVersion > 0 then
      decoded = LibDeflate:DecodeForPrint(encoded)
    else
      decoded = decodeB64(encoded)
    end
  else
    decoded = LibDeflate:DecodeForWoWAddonChannel(encoded)
  end

  if not decoded then
    return false, "Error decoding."
  end

  local decompressed
  if encodeVersion > 0 then
    decompressed = LibDeflate:DecompressDeflate(decoded)
    if not(decompressed) then
      return false, "Error decompressing"
    end
  else
    -- We ignore the error message, since it's more likely not a weakaura.
    decompressed = Compresser:Decompress(decoded)
    if not(decompressed) then
      return false, "Error decompressing. This doesn't look like a WeakAuras import."
    end
  end


  local success, deserialized
  if encodeVersion < 2 then
    success, deserialized = Serializer:Deserialize(decompressed)
  else
    success, deserialized = LibSerialize:Deserialize(decompressed)
  end
  if not(success) then
    return false, "Error deserializing"
  end
  return deserialized
end
--#endregion

LiquidWeakAurasAPI = {}

do
  local alreadySetuped = false
  local function setupWAData()
    if alreadySetuped then return end
    for k,v in pairs(ns.data) do
      local t, e = StringToTable(v.dataString, true)
      if t then
        v.waTable = t
      else
        addonPrint(e)
      end
    end
    alreadySetuped = true
  end
  function LiquidWeakAurasAPI:GetData()
    setupWAData()
    return ns.data
  end
end
function LiquidWeakAurasAPI:GetDeleteData()
  return ns.deleteData
end
do
	local _v = C_AddOns.GetAddOnMetadata(addonName, "version")
	local _major,_minor,_patch = _v:match("^(%d-)%.(%d-)%.(%d-)$")
	LiquidWeakAurasAPI.Version = {
		str = _v,
		major = tonumber(_major),
		minor = tonumber(_minor),
		patch = tonumber(_patch),
	}
end