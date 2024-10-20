local Caches = {}

local ARMOR = ARMOR or "Armor"
local WEAPON = WEAPON or "Weapon"
local MOUNTS = MOUNTS or "Mount"
local RELICSLOT = RELICSLOT or "Relic"

---@diagnostic disable-next-line: deprecated
local GetItemInfo = C_Item.GetItemInfo or GetItemInfo

local function ChatItemSlot(Hyperlink)
  if (Caches[Hyperlink]) then
    return Caches[Hyperlink]
  end
  local slot
  local link = string.match(Hyperlink, "|H(.-)|h")
  local name, _, quality, level, _, class, subclass, _, equipSlot = GetItemInfo(link)

  -- links need to be skipped
  if (equipSlot == "INVTYPE_NON_EQUIP_IGNORE"
        or equipSlot == "INVTYPE_NON_EQUIP"
        or equipSlot == "INVTYPE_BAG") then
    slot = subclass
  elseif (equipSlot == "INVTYPE_CLOAK"
        or equipSlot == "INVTYPE_TRINKET"
        or equipSlot == "INVTYPE_FINGER"
        or equipSlot == "INVTYPE_NECK") then
    slot = _G[equipSlot] or equipSlot
  elseif (equipSlot == "INVTYPE_RANGEDRIGHT") then
    slot = subclass
  elseif (equipSlot and string.find(equipSlot, "INVTYPE_")) then
    slot = format("%s-%s", subclass or "", _G[equipSlot] or equipSlot)
  elseif (class == ARMOR) then
    slot = format("%s-%s", subclass or "", class)
  elseif (subclass and string.find(subclass, RELICSLOT)) then
    slot = RELICSLOT
  elseif (subclass and subclass == MOUNTS) then
    slot = MOUNTS
  end

  if (slot) then
    Hyperlink = Hyperlink:gsub("|h%[(.-)%]|h", "|h[(" .. slot .. "):" .. name .. "]|h")
    Caches[Hyperlink] = Hyperlink
  end
  return Hyperlink
end

local function filter(self, event, msg, ...)
  msg = msg:gsub("(|Hitem:%d+:.-|h.-|h)", ChatItemSlot)
  return false, msg, ...
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", filter)
