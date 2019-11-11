AutoRecast = CreateFrame('Button', "AutoRecast", UIParent) -- need a frame to use OnUpdate

function AutoRecast:BuildRecastFrame()
    local f = CreateFrame('Button', "RecastFrame", UIParent, "SecureActionButtonTemplate")
    f:SetAttribute("type", "spell")
    f:SetAttribute("spell", "Fishing")
    f:SetWidth(40)
    f:SetHeight(40)
    f:SetPoint("CENTER", UIParent)
    f:RegisterForClicks("RightButtonDown")
    return f
end
RecastFrame = AutoRecast:BuildRecastFrame()

AutoRecast_PrintFormat = "|c00f7f26c%s|r"

AutoRecast.TimeSinceLastUpdate = 0
AutoRecast.WasFishing = false

function AutoRecast:SendMessage(msg)
    local msg = string.format(AutoRecast_PrintFormat, msg)
    DEFAULT_CHAT_FRAME:AddMessage(string.format(AutoRecast_PrintFormat, "AutoRecast: ") .. msg)
end

function AutoRecast:HasValue(tab, val)
    for i, value in ipairs(tab) do
        if value == val then
            return true, i
        end
    end
    return false, i
end

function AutoRecast:FrameOnCursor()
    RecastFrame:Show()
    RecastFrame:ClearAllPoints()
    local scale, x, y = RecastFrame:GetEffectiveScale(), GetCursorPosition()
    RecastFrame:SetPoint("CENTER", nil, "BOTTOMLEFT", x/scale, y/scale)
end

function AutoRecast_OnEvent(event, arg1)
    if arg1 == "BAG_UPDATE" and AutoRecast.WasFishing then
        AutoRecast.WasFishing = false
        AutoRecast:FrameOnCursor()
    end
end
AutoRecast:SetScript("OnEvent", AutoRecast_OnEvent)
AutoRecast:RegisterEvent("BAG_UPDATE")

function AutoRecast:Init()
    if AutoRecast_Config == nil then
        AutoRecast_Config = {}
        table.insert(AutoRecast_Config, "on")
    end
    AutoRecast:SendMessage("Init Successful")
end
AutoRecast:Init()

function AutoRecast:IsFishing()
    local castbarShowing = false
    if CastingBarFrame:IsShown() then
        castbarShowing = true
    elseif LUFUnitplayer.castBar and LUFUnitplayer.castBar:IsShown() then
        castbarShowing = true
    end
    local mainhandLink = GetInventoryItemLink("player", 16)
    if mainhandLink == nil then
        return false
    end
    if castbarShowing and string.find(mainhandLink, "Fishing") then
        return true
    end
end

function AutoRecast_OnUpdate(self, elapsed)
    AutoRecast.TimeSinceLastUpdate = AutoRecast.TimeSinceLastUpdate + elapsed
    if AutoRecast.TimeSinceLastUpdate > 0.5 then
        AutoRecast.TimeSinceLastUpdate = 0

        if not AutoRecast.Off then
            if AutoRecast:IsFishing() then
                AutoRecast.WasFishing = true
                RecastFrame:Hide()
            end
        end
    end
end
AutoRecast:SetScript("OnUpdate", AutoRecast_OnUpdate)

function AutoRecast:TurnOff()
    AutoRecast.Off = true
    RecastFrame:Hide()
end

SLASH_AUTORECAST1 = "/ar"
SLASH_AUTORECAST2 = "/autorecast"
function SlashCmdList.AUTORECAST(args)
    words = {}
    for word in args:gmatch("%w+") do table.insert(words, word) end

    if words[1] == "off" then
        AutoRecast:TurnOff()
    else
        AutoRecast:SendMessage("Unknown command")
    end
end
