---| Module contains code to update the already selected spells in tabs
local TOCNAME, BOM = ...
local L = setmetatable(
        {},
        {
          __index = function(_t, k)
            if BOM.L and BOM.L[k] then
              return BOM.L[k]
            else
              return "[" .. k .. "]"
            end
          end
        })

local SpellSettingsFrames = {}
BOM.SpellSettingsFrames = SpellSettingsFrames -- group settings buttons after the spell list

---Add some clickable elements to Spell Tab row with all classes
---@param isHorde boolean - whether we are horde
---@param spell table - the spell currently being displayed
---@param dx number - offset by x
---@param prev_control table - previous reference control for positioning
local function add_row_of_class_buttons(isHorde, spell, dx, prev_control)
  if spell.frames.SelfCast == nil then
    spell.frames.SelfCast = BOM.CreateMyButton(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_SELF_CAST_ON,
            BOM.ICON_SELF_CAST_OFF)
  end

  spell.frames.SelfCast:SetPoint("TOPLEFT", prev_control, "TOPRIGHT", dx, 0)
  spell.frames.SelfCast:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "SelfCast")
  spell.frames.SelfCast:SetOnClick(BOM.MyButtonOnClick)
  BOM.Tool.TooltipText(
          spell.frames.SelfCast,
          BOM.FormatTexture(BOM.ICON_SELF_CAST_ON) .. " - " .. L.TooltipSelfCastCheckbox_Self .. "|n"
                  .. BOM.FormatTexture(BOM.ICON_SELF_CAST_OFF) .. " - " .. L.TooltipSelfCastCheckbox_Party)

  prev_control = spell.frames.SelfCast
  dx = 2

  --------------------------------------
  -- Class-Cast checkboxes one per class
  --------------------------------------
  for ci, class in ipairs(BOM.Tool.Classes) do
    if spell.frames[class] == nil then
      spell.frames[class] = BOM.CreateMyButton(
              BomC_SpellTab_Scroll_Child,
              BOM.CLASS_ICONS_ATLAS,
              BOM.ICON_EMPTY,
              BOM.ICON_DISABLED,
              BOM.CLASS_ICONS_ATLAS_TEX_COORD[class])
    end

    spell.frames[class]:SetPoint("TOPLEFT", prev_control, "TOPRIGHT", dx, 0)
    spell.frames[class]:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID].Class, class)
    spell.frames[class]:SetOnClick(BOM.DoBlessingOnClick)

    BOM.Tool.TooltipText(
            spell.frames[class],
            BOM.Tool.IconClass[class] .. " - " .. L.TooltipCastOnClass .. ": " .. BOM.Tool.ClassName[class] .. "|n"
                    .. BOM.FormatTexture(BOM.ICON_EMPTY) .. " - " .. L.TabDoNotBuff .. ": " .. BOM.Tool.ClassName[class] .. "|n"
                    .. BOM.FormatTexture(BOM.ICON_DISABLED) .. " - " .. L.TabBuffOnlySelf)

    if (isHorde and class == "PALADIN")
            or (not isHorde and class == "SHAMAN") then
      spell.frames[class]:Hide()
    else
      prev_control = spell.frames[class]
    end
  end -- for each class in class_sort_order

  if spell.frames["tank"] == nil then
    spell.frames["tank"] = BOM.CreateMyButton(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_TANK,
            BOM.ICON_EMPTY,
            BOM.ICON_DISABLED,
            BOM.ICON_TANK_COORD)
  end

  spell.frames["tank"]:SetPoint("TOPLEFT", prev_control, "TOPRIGHT", dx, 0)
  spell.frames["tank"]:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID].Class, "tank")
  spell.frames["tank"]:SetOnClick(BOM.DoBlessingOnClick)
  BOM.Tool.TooltipText(spell.frames["tank"], BOM.FormatTexture(BOM.ICON_TANK) .. " - " .. L.TooltipCastOnTank)

  prev_control = spell.frames["tank"]

  if spell.frames["pet"] == nil then
    spell.frames["pet"] = BOM.CreateMyButton(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_PET,
            BOM.ICON_EMPTY,
            BOM.ICON_DISABLED,
            BOM.ICON_PET_COORD)
  end

  spell.frames["pet"]:SetPoint("TOPLEFT", prev_control, "TOPRIGHT", dx, 0)
  spell.frames["pet"]:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID].Class, "pet")
  spell.frames["pet"]:SetOnClick(BOM.DoBlessingOnClick)
  BOM.Tool.TooltipText(spell.frames["pet"], BOM.FormatTexture(BOM.ICON_PET) .. " - " .. L.TooltipCastOnPet)
  prev_control = spell.frames["pet"]

  dx = 7

  if spell.frames.target == nil then
    spell.frames.target = BOM.CreateMyButton(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_TARGET_ON,
            BOM.ICON_TARGET_OFF,
            BOM.ICON_DISABLED)
  end

  spell.frames.target:SetPoint("TOPLEFT", prev_control, "TOPRIGHT", dx, 0)
  spell.frames.target:SetOnClick(BOM.MyButtonOnClick)
  BOM.Tool.Tooltip(spell.frames.target, "TooltipForceCastOnTarget")

  prev_control = spell.frames.target
  dx = 7

  return dx, prev_control
end

---Add a row with spell cancel buttons
---@param spell table - The spell to be canceled
---@param dx number - the horizontal offset
---@param dy number - the vertical offset
---@param prev_control table - the reference UI control to offset from
local function add_spell_cancel_buttons(spell, dx, dy, prev_control, last)
  spell.frames = spell.frames or {}

  if spell.frames.info == nil then
    -- Create spell tooltip button
    spell.frames.info = BOM.CreateMyButton(
            BomC_SpellTab_Scroll_Child,
            spell.Icon,
            nil,
            nil,
            { 0.1, 0.9, 0.1, 0.9 })
    BOM.Tool.TooltipLink(spell.frames.info, "spell:" .. spell.singleId)
  end

  if last then
    spell.frames.info:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -dy)
  else
    spell.frames.info:SetPoint("TOPLEFT")
  end

  last = spell.frames.info

  if spell.frames.Enable == nil then
    spell.frames.Enable = BOM.CreateMyButton(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_OPT_ENABLED,
            BOM.ICON_OPT_DISABLED)
  end

  spell.frames.Enable:SetPoint("LEFT", spell.frames.info, "RIGHT", 7, 0)
  spell.frames.Enable:SetVariable(BOM.CurrentProfile.CancelBuff[spell.ConfigID], "Enable")
  spell.frames.Enable:SetOnClick(BOM.MyButtonOnClick)
  BOM.Tool.Tooltip(spell.frames.Enable, "TooltipEnableBuffCancel")

  --Add "Only before combat" text label
  spell.frames.OnlyCombat = bom_create_smalltext_label(
          spell.frames.OnlyCombat,
          BomC_SpellTab_Scroll_Child,
          function(ctrl)
            if spell.OnlyCombat then
              ctrl:SetText(L.HintCancelThisBuff .. ": " .. L.HintCancelThisBuff_Combat)
            else
              ctrl:SetText(L.HintCancelThisBuff .. ": " .. L.HintCancelThisBuff_Always)
            end
            ctrl:SetPoint("TOPLEFT", spell.frames.Enable, "TOPRIGHT", 7, -3)
          end)

  spell.frames.info:Show()
  spell.frames.Enable:Show()
  if spell.frames.OnlyCombat then
    spell.frames.OnlyCombat:Show()
  end

  return dy, prev_control, last
end

local function fill_last_section(last)
  -------------------------
  -- Add settings frame with icon, icon is not clickable
  -------------------------
  if SpellSettingsFrames.Settings == nil then
    SpellSettingsFrames.Settings = BOM.CreateMyButton(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_GEAR,
            nil,
            nil,
            { 0.1, 0.9, 0.1, 0.9 })
  end

  BOM.Tool.Tooltip(SpellSettingsFrames.Settings, "TooltipRaidGroupsSettings")
  SpellSettingsFrames.Settings:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -12)

  last = SpellSettingsFrames.Settings
  local dx = 7
  local l = last

  if SpellSettingsFrames[0] == nil then
    SpellSettingsFrames[0] = BOM.CreateMyButton(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_GROUP,
            nil,
            nil,
            { 0.1, 0.9, 0.1, 0.9 })
  end
  BOM.Tool.Tooltip(SpellSettingsFrames[0], "HeaderWatchGroup")
  SpellSettingsFrames[0]:SetPoint("TOPLEFT", l, "TOPRIGHT", dx, 0)

  l = SpellSettingsFrames[0]
  dx = 7

  ------------------------------
  -- Add "Watch Group #" buttons
  ------------------------------
  for i = 1, 8 do
    if SpellSettingsFrames[i] == nil then
      SpellSettingsFrames[i] = BOM.CreateMyButton(
              BomC_SpellTab_Scroll_Child,
              BOM.ICON_GROUP_ITEM,
              BOM.ICON_GROUP_NONE)
    end

    SpellSettingsFrames[i]:SetPoint("TOPLEFT", l, "TOPRIGHT", dx, 0)
    SpellSettingsFrames[i]:SetVariable(BomCharacterState.WatchGroup, i)
    SpellSettingsFrames[i]:SetText(i)
    BOM.Tool.TooltipText(SpellSettingsFrames[i], string.format(L.TooltipGroup, i))

    -- Let the MyButton library function handle the data update, and update the tab text too
    SpellSettingsFrames[i]:SetOnClick(function()
      BOM.MyButtonOnClick(self)
      BOM.UpdateBuffTabText()
    end)

    l = SpellSettingsFrames[i]
    dx = 2
  end

  last = SpellSettingsFrames[0]

  --for i, set in ipairs(BOM.BehaviourSettings) do
  --  local key = set[1]
  --
  --  if BOM["Icon" .. key .. "On"] then
  --    if SpellSettingsFrames[key] == nil then
  --      SpellSettingsFrames[key] = BOM.CreateMyButton(
  --              BomC_SpellTab_Scroll_Child,
  --              BOM["Icon" .. key .. "On"],
  --              BOM["Icon" .. key .. "Off"],
  --              nil,
  --              BOM["Icon" .. key .. "OnCoord"],
  --              BOM["Icon" .. key .. "OffCoord"])
  --    end
  --
  --    SpellSettingsFrames[key]:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -2)
  --    SpellSettingsFrames[key]:SetVariable(BOM.SharedState, key)
  --    SpellSettingsFrames[key]:SetTooltip(L["Cbox" .. key])
  --    SpellSettingsFrames[key]:SetOnClick(BOM.MyButtonOnClick)
  --    l = SpellSettingsFrames[key]
  --    dx = 2
  --
  --    if SpellSettingsFrames[key .. "txt"] == nil then
  --      SpellSettingsFrames[key .. "txt"] = BomC_SpellTab_Scroll_Child:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  --    end
  --
  --    SpellSettingsFrames[key .. "txt"]:SetText(L["Cbox" .. key])
  --    SpellSettingsFrames[key .. "txt"]:SetPoint("TOPLEFT", l, "TOPRIGHT", 7, -1)
  --    l = SpellSettingsFrames[key .. "txt"]
  --    dx = 7
  --
  --    last = SpellSettingsFrames[key]
  --    dx = 0
  --  end
  --end


  --for i, set in ipairs(BOM.BehaviourSettings) do
  --  local key = set[1]
  --
  --  if not BOM["Icon" .. key .. "On"] then
  --    if SpellSettingsFrames[key] == nil then
  --      SpellSettingsFrames[key] = BOM.CreateMyButton(
  --              BomC_SpellTab_Scroll_Child,
  --              BOM.ICON_SETTING_ON,
  --              BOM.ICON_SETTING_OFF,
  --              nil,
  --              nil,
  --              nil)
  --    end
  --
  --    SpellSettingsFrames[key]:SetPoint("TOPLEFT", last, "BOTTOMLEFT", dx, -2)
  --    SpellSettingsFrames[key]:SetVariable(BOM.SharedState, key)
  --    SpellSettingsFrames[key]:SetTooltip(L["Cbox" .. key])
  --    SpellSettingsFrames[key]:SetOnClick(BOM.MyButtonOnClick)
  --    l = SpellSettingsFrames[key]
  --    dx = 2
  --
  --    if SpellSettingsFrames[key .. "txt"] == nil then
  --      SpellSettingsFrames[key .. "txt"] = BomC_SpellTab_Scroll_Child:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  --    end
  --    SpellSettingsFrames[key .. "txt"]:SetText(L["Cbox" .. key])
  --    SpellSettingsFrames[key .. "txt"]:SetPoint("TOPLEFT", l, "TOPRIGHT", 7, -1)
  --    l = SpellSettingsFrames[key .. "txt"]
  --    dx = 7
  --
  --    last = SpellSettingsFrames[key]
  --    dx = 0
  --  end
  --end

  SpellSettingsFrames.Settings:Show()

  for i = 0, 8 do
    SpellSettingsFrames[i]:Show()
  end

  for i, set in ipairs(BOM.BehaviourSettings) do
    if SpellSettingsFrames[set[1]] then
      SpellSettingsFrames[set[1]]:Show()
    end
    if SpellSettingsFrames[set[1] .. "txt"] then
      SpellSettingsFrames[set[1] .. "txt"]:Show()
    end
  end

  last = SpellSettingsFrames.Settings
  return last
end

---create_tab_row
---@param isHorde boolean - whether we're horde
---@param spell void - spell we're adding now
---@param dy number - Y offset
---@param last void - some previous control or something
---@param section string - section name for spell type
---@param self_class string - Character class
local function bom_create_tab_row(isHorde, spell, dy, last, section, self_class)
  spell.frames = spell.frames or {}

  --------------------------------
  -- Create buff icon with tooltip
  --------------------------------
  if spell.frames.info == nil then
    spell.frames.info = BOM.CreateMyButton(
            BomC_SpellTab_Scroll_Child,
            spell.Icon,
            nil,
            nil,
            { 0.1, 0.9, 0.1, 0.9 })
  end

  if spell.isBuff then
    --spell.frames.info:SetTooltipLink("item:" .. spell.item)
    BOM.Tool.TooltipLink(spell.frames.info, "item:" .. spell.item)
  else
    --spell.frames.info:SetTooltipLink("spell:" .. spell.singleId)
    BOM.Tool.TooltipLink(spell.frames.info, "spell:" .. spell.singleId)
  end
  --<<----------------------------

  dy = 12

  if spell.isOwn and section ~= "isOwn" then
    section = "isOwn"
  elseif spell.isTracking and section ~= "isTracking" then
    section = "isTracking"
  elseif spell.isResurrection and section ~= "isResurrection" then
    section = "isResurrection"
  elseif spell.isSeal and section ~= "isSeal" then
    section = "isSeal"
  elseif spell.isAura and section ~= "isAura" then
    section = "isAura"
  elseif spell.isBlessing and section ~= "isBlessing" then
    section = "isBlessing"
  elseif spell.isInfo and section ~= "isInfo" then
    section = "isInfo"
  elseif spell.isBuff and section ~= "isBuff" then
    section = "isBuff"
  else
    dy = 2
  end

  if last then
    spell.frames.info:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -dy)
  else
    spell.frames.info:SetPoint("TOPLEFT")
  end

  local prev_control = spell.frames.info
  local dx = 7

  if spell.frames.Enable == nil then
    spell.frames.Enable = BOM.CreateMyButton(
            BomC_SpellTab_Scroll_Child,
            BOM.ICON_OPT_ENABLED,
            BOM.ICON_OPT_DISABLED)
  end

  spell.frames.Enable:SetPoint("TOPLEFT", prev_control, "TOPRIGHT", dx, 0)
  spell.frames.Enable:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "Enable")
  spell.frames.Enable:SetOnClick(BOM.MyButtonOnClick)
  BOM.Tool.Tooltip(spell.frames.Enable, "TooltipEnableSpell")

  prev_control = spell.frames.Enable
  dx = 7

  if BOM.SpellHasClasses(spell) then
    -- Create checkboxes one per class
    dx, prev_control = add_row_of_class_buttons(isHorde, spell, dx, prev_control)
  end

  if (spell.isTracking
          or spell.isAura
          or spell.isSeal)
          and spell.needForm == nil then
    if spell.frames.Set == nil then
      spell.frames.Set = BOM.CreateMyButtonSecure(
              BomC_SpellTab_Scroll_Child,
              BOM.ICON_CHECKED,
              BOM.ICON_CHECKED_OFF)
    end

    spell.frames.Set:SetPoint("TOPLEFT", prev_control, "TOPRIGHT", dx, 0)
    spell.frames.Set:SetSpell(spell.singleId)

    prev_control = spell.frames.Set
    dx = 7
  end

  if spell.isInfo and spell.allowWhisper then
    if spell.frames.Whisper == nil then
      spell.frames.Whisper = BOM.CreateMyButton(
              BomC_SpellTab_Scroll_Child,
              BOM.ICON_WHISPER_ON,
              BOM.ICON_WHISPER_OFF)
    end

    spell.frames.Whisper:SetPoint("TOPLEFT", prev_control, "TOPRIGHT", dx, 0)
    spell.frames.Whisper:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "Whisper")
    spell.frames.Whisper:SetOnClick(BOM.MyButtonOnClick)
    BOM.Tool.Tooltip(spell.frames.Whisper, "TooltipWhisperWhenExpired")
    prev_control = spell.frames.Whisper
    dx = 2
  end

  if spell.isWeapon then
    if spell.frames.MainHand == nil then
      spell.frames.MainHand = BOM.CreateMyButton(
              BomC_SpellTab_Scroll_Child,
              BOM.IconMainHandOn,
              BOM.IconMainHandOff,
              BOM.ICON_DISABLED,
              BOM.IconMainHandOnCoord)
    end

    spell.frames.MainHand:SetPoint("TOPLEFT", prev_control, "TOPRIGHT", dx, 0)
    spell.frames.MainHand:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "MainHandEnable")
    spell.frames.MainHand:SetOnClick(BOM.MyButtonOnClick)
    BOM.Tool.Tooltip(spell.frames.MainHand, "TooltipMainHand")
    prev_control = spell.frames.MainHand
    dx = 2

    if spell.frames.OffHand == nil then
      spell.frames.OffHand = BOM.CreateMyButton(
              BomC_SpellTab_Scroll_Child,
              BOM.IconSecondaryHandOn,
              BOM.IconSecondaryHandOff,
              BOM.ICON_DISABLED,
              BOM.IconSecondaryHandOnCoord)
    end

    spell.frames.OffHand:SetPoint("TOPLEFT", prev_control, "TOPRIGHT", dx, 0)
    spell.frames.OffHand:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "OffHandEnable")
    spell.frames.OffHand:SetOnClick(BOM.MyButtonOnClick)
    BOM.Tool.Tooltip(spell.frames.OffHand, "TooltipOffHand")
    prev_control = spell.frames.OffHand
    dx = 2
  end

  if spell.frames.buff == nil then
    spell.frames.buff = BomC_SpellTab_Scroll_Child:CreateFontString(
            nil, "OVERLAY", "GameFontNormalSmall")
  end

  if spell.isWeapon then
    spell.frames.buff:SetText((spell.single or "-")
            .. " (" .. L.TooltipIncludesAllRanks .. ")")
  else
    spell.frames.buff:SetText(spell.single or "-")
  end

  spell.frames.buff:SetPoint("TOPLEFT", prev_control, "TOPRIGHT", 7, -1)
  prev_control = spell.frames.buff
  dx = 7

  spell.frames.info:Show()
  spell.frames.Enable:Show()

  if BOM.SpellHasClasses(spell) then
    spell.frames.SelfCast:Show()
    spell.frames.target:Show()

    for ci, class in ipairs(BOM.Tool.Classes) do
      if (isHorde and class == "PALADIN")
              or (not isHorde and class == "SHAMAN") then
        spell.frames[class]:Hide()
      else
        spell.frames[class]:Show()
      end
    end

    spell.frames["tank"]:Show()
    spell.frames["pet"]:Show()
  end

  if spell.frames.Set then
    spell.frames.Set:Show()
  end

  if spell.frames.buff then
    spell.frames.buff:Show()
  end

  if spell.frames.Whisper then
    spell.frames.Whisper:Show()
  end

  if spell.frames.MainHand then
    spell.frames.MainHand:Show()
  end

  if spell.frames.OffHand then
    spell.frames.OffHand:Show()
  end

  last = spell.frames.info
  return dy, last, section
end

---Filter all known spells through current player spellbook.
---Called below from BOM.UpdateSpellsTab()
local function create_tab(isHorde)
  local last
  local dy = 0
  local section
  -- className, classFilename, classId
  local _, selfClassName, _ = UnitClass("player")

  for i, spell in ipairs(BOM.SelectedSpells) do
    if type(spell.onlyUsableFor) == "table"
            and not tContains(spell.onlyUsableFor, selfClassName) then
      -- skip
    else
      dy, last, section = bom_create_tab_row(isHorde, spell, dy, last, section, selfClassName)
    end

  end

  dy = 12

  --
  -- Add spell cancel buttons for all spells in CancelBuffs
  -- (and CustomCancelBuffs which user can add manually in the config file)
  --
  for i, spell in ipairs(BOM.CancelBuffs) do
    dy, prev_control, last = add_spell_cancel_buttons(spell, 2, dy, prev_control, last)
    dy = 2
  end

  if last then
    last = fill_last_section(last)
  end
end

local function update_selected_spell(spell)
  spell.frames.Enable:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "Enable")

  if BOM.SpellHasClasses(spell) then
    spell.frames.SelfCast:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "SelfCast")

    for ci, class in ipairs(BOM.Tool.Classes) do
      spell.frames[class]:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID].Class, class)

      if BOM.CurrentProfile.Spell[spell.ConfigID].SelfCast then
        spell.frames[class]:Disable()
      else
        spell.frames[class]:Enable()
      end
    end

    spell.frames["tank"]:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID].Class, "tank")
    spell.frames["pet"]:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID].Class, "pet")

    if BOM.CurrentProfile.Spell[spell.ConfigID].SelfCast then
      spell.frames["tank"]:Disable()
      spell.frames["pet"]:Disable()
    else
      spell.frames["tank"]:Enable()
      spell.frames["pet"]:Enable()
    end

    if BOM.lastTarget ~= nil then
      spell.frames.target:Enable()
      BOM.Tool.TooltipText(spell.frames.target, L.TooltipForceCastOnTarget .. "|n" .. BOM.lastTarget)
      if spell.isBlessing then
        spell.frames.target:SetVariable(BOM.CurrentProfile.Spell[BOM.BLESSING_ID], BOM.lastTarget, spell.ConfigID)
      else
        spell.frames.target:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID].ForcedTarget, BOM.lastTarget, true)
      end

    else
      spell.frames.target:Disable()
      BOM.Tool.TooltipText(spell.frames.target, L.TooltipForceCastOnTarget .. "|n" .. L.TooltipSelectTarget)
      spell.frames.target:SetVariable()
    end
  end

  if spell.isInfo and spell.allowWhisper then
    spell.frames.Whisper:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "Whisper")
  end

  if spell.isWeapon then
    spell.frames.MainHand:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "MainHandEnable")
    spell.frames.OffHand:SetVariable(BOM.CurrentProfile.Spell[spell.ConfigID], "OffHandEnable")
  end

  if (spell.isTracking or spell.isAura or spell.isSeal) and spell.needForm == nil then
    if (spell.isTracking and BOM.CharacterState.LastTracking == spell.TrackingIcon) or
            (spell.isAura and spell.ConfigID == BOM.CurrentProfile.LastAura) or
            (spell.isSeal and spell.ConfigID == BOM.CurrentProfile.LastSeal) then
      spell.frames.Set:SetState(true)
    else
      spell.frames.Set:SetState(false)
    end
  end
end

---UpdateTab - update spells in one of the spell tabs
---BOM.SelectedSpells: table - Spells which were selected for display in Scan function, their
---state will be displayed in a spell tab
function BOM.UpdateSpellsTab()
  -- InCombat Protection is checked by the caller (Update***Tab)
  if BOM.SelectedSpells == nil then
    return
  end

  if InCombatLockdown() then
    return
  end

  if not BOM.SpellTabsCreatedFlag then
    BOM.MyButtonHideAll()
    local isHorde = (UnitFactionGroup("player")) == "Horde"

    create_tab(isHorde)

    BOM.SpellTabsCreatedFlag = true
  end

  local _className, selfClassName, _classId = UnitClass("player")

  for i, spell in ipairs(BOM.SelectedSpells) do
    if type(spell.onlyUsableFor) == "table"
            and not tContains(spell.onlyUsableFor, selfClassName) then
      -- skip
    else
      update_selected_spell(spell)
    end
  end

  for _i, spell in ipairs(BOM.CancelBuffs) do
    spell.frames.Enable:SetVariable(BOM.CurrentProfile.CancelBuff[spell.ConfigID], "Enable")
  end

  --Create small toggle button to the right of [Cast <spell>] button
  BOM.CreateSingleBuffButton(BomC_ListTab) --maybe not created yet?
end
