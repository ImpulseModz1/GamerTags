GamerTagsModule = setmetatable({}, GamerTagsModule)

GamerTagsModule.__call = function()
    return "GamerTagsModule"
end

GamerTagsModule.__index = GamerTagsModule

function GamerTagsModule.Load()
    return setmetatable({
        disableHeadTag = false
    }, GamerTagsModule)
end

function GamerTagsModule:DrawHeadTagText(position, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(position.x, position.y, position.z + 0.35)
    local pCoords = GetGameplayCamCoords()
    local dist = #(pCoords - position)

    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    if onScreen then
        SetTextScale(0.0 * scale, 0.55 * scale)
        SetTextFont(4)
        SetTextProportional(true)
        SetTextColour(255, 255, 255, 255) -- Default color
        SetTextDropshadow(50, 210, 210, 210, 255)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

function GamerTagsModule:Run()
    local clientPed = PlayerPedId() -- Get local player's ped
    local clientPosition = GetEntityCoords(clientPed)

    for _, ply in ipairs(GetActivePlayers()) do 
        local ped = GetPlayerPed(ply)
        local position = GetEntityCoords(ped)
        local serverId = GetPlayerServerId(ply)
        local disableHeadTag = Player(serverId).state.disableHeadTag
        local isStaff = Player(serverId).state.staffHeadTag
        local customHeadTag = Player(serverId).state.customHeadTag

        if not disableHeadTag then
            local dist = #(clientPosition - position)

            if dist < 18 and HasEntityClearLosToEntity(clientPed, ped, 17) then 
                local boneCoords = GetPedBoneCoords(ped, 31086, 0, 0, 0)
                local name = GetPlayerName(ply)
                local talking = NetworkIsPlayerTalking(ply) -- Check if the player is talking

                -- Prepare the ID color based on talking state
                local idColor = talking and "~g~" or "~w~"

                if isStaff then
                    self:DrawHeadTagText(boneCoords, string.format("~y~[%s%d~y~] %s ~w~[~r~Staff~w~] ~w~%s", idColor, serverId, (customHeadTag and "~w~["..customHeadTag.."~w~]" or ""), name))
                else
                    self:DrawHeadTagText(boneCoords, string.format("~y~[%s%d~y~] %s ~w~%s", idColor, serverId, (customHeadTag and "~w~["..customHeadTag.."~w~]" or ""), name))
                end
            end
        end
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        GamerTagsModule:Run()
    end
end)
