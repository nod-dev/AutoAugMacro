local function PIMGPrint(txt,color)
    local color = color or "FFFFFF"
    print("\124cffFFD700PIMG: \124r\124cff"..color..txt.."\124r")
end

local function formattedLog(txt)
    local prefix = "\124cffFFD700[AutoAugMacro]: \124r"
    print(prefix .. txt)
end

SLASH_AutoAugMacro1, SLASH_AutoAugMacro2  = "/aam", "/AutoAugMacro"
SlashCmdList["AutoAugMacro"] = function(msg) 
    -- Ensure the player is not in combat
    if InCombatLockdown() then
        formattedLog("Macros cannot be created or updated whilst in combat.")
    end

    -- Ensure the macro frame is not open
    if MacroFrame and MacroFrame:IsShown() then
        formattedLog("Macros cannot be updated whilst the macro panel is open.")
    end

    -- Ensure current class is Evoker
    local currentClass = select(2, UnitClass("player"))
    if currentClass ~= "EVOKER" then
        formattedLog("You must be an Evoker to use this command.")
        return
    end

    -- Ensure that the current spec is Augmentation
    local currentSpec = GetSpecialization()
    if currentSpec ~= 3 then
        formattedLog("You must playing Augmentation to use this command.")
        return
    end

    -- Ensure that there are 5 party members
    if GetNumGroupMembers() ~= 5 then
        formattedLog("You must be in a party of 5 to use this command.")
        return
    end

    -- Check if macros exist and get indexes
    local globalMacroCount = GetNumMacros()
    local prescienceMacro1Exists, prescienceMacro2Exists
    local scalesMacroExists
    if GetMacroIndexByName("AAMPrescience1") == 0 then
        prescienceMacro1Exists = false
    else
        prescienceMacro1Exists = true
    end
    if GetMacroIndexByName("AAMPrescience2") == 0 then
        prescienceMacro2Exists = false
    else
        prescienceMacro2Exists = true
    end

    if GetMacroIndexByName("AAMScales") == 0 then
        scalesMacroExists = false
    else
        scalesMacroExists = true
    end

    if (globalMacroCount > 117 and not prescienceMacro1Exists and not prescienceMacro2Exists and not scalesMacroExists) then
        formattedLog("Too many global macros already exist. Ensure you have enough free macro slots for 3 macros to be created.")
        return
    end

    local tank, dps1, dps2, tankName, dps1Name, dps2Name

    -- Identify roles in the party and assign them to variables ensuring that the current player is not included
    for i = 1, 5 do
        local unit = "party"..i
        if UnitGroupRolesAssigned(unit) == "TANK" then
            tank = unit
            tankName = tank and UnitName(tank) or "None"
        elseif UnitGroupRolesAssigned(unit) == "DAMAGER" then
            if not dps1 then
                dps1 = unit
                dps1Name = dps1 and UnitName(dps1) or "None"
            else
                dps2 = unit
                dps2Name = dps2 and UnitName(dps2) or "None"
            end
        end
    end

    -- Create Blistering Scales Macro
    local bsSpellInfo = C_Spell.GetSpellInfo(360827)
    local bsLocalizedSpellName = bsSpellInfo.name
    local bsMacroText = "#showtooltip\n/cast [@"..tankName..",help,nodead][] "..bsLocalizedSpellName .. "\n/cast [@player] " .. bsLocalizedSpellName
    if not scalesMacroExists then
        CreateMacro("AAMScales", 5199621, bsMacroText)
        formattedLog("Blistering Scales macro target: " .. tankName)
    else
        EditMacro("AAMScales", "AAMScales", 5199621, bsMacroText)
        formattedLog("Blistering Scales macro target: " .. tankName)
    end

    -- Create Prescience Macro
    local prescienceSpellInfo = C_Spell.GetSpellInfo(409311)
    local prescienceLocalizedSpellName = prescienceSpellInfo.name
    local prescienceMacro1Text = "#showtooltip\n/cast [@"..dps1Name..",help,nodead][] " .. prescienceLocalizedSpellName
    local prescienceMacro2Text = "#showtooltip\n/cast [@"..dps2Name..",help,nodead][] " .. prescienceLocalizedSpellName
    if not prescienceMacro1Exists then
        CreateMacro("AAMPrescience1", 5199639, prescienceMacro1Text)
        formattedLog("Prescience macro 1 target: " .. dps1Name)
    else
        EditMacro("AAMPrescience1", "AAMPrescience1", 5199639, prescienceMacro1Text)
        formattedLog("Prescience macro 1 target: " .. dps1Name)
    end
    if not prescienceMacro2Exists then
        CreateMacro("AAMPrescience2", 5199639, prescienceMacro2Text)
        formattedLog("Prescience macro 2 target: " .. dps2Name)
    else
        EditMacro("AAMPrescience2", "AAMPrescience2", 5199639, prescienceMacro2Text)
        formattedLog("Prescience macro 2 target: " .. dps2Name)
    end
end