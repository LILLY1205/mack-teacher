local RSGCore = exports['rsg-core']:GetCoreObject()
local PlayerData = {}
local isLoggedIn = false
local isClockedIn = false
local isSeated = false
local isInClass = false
local seatedStoolIndex = nil
local startingCoords = nil

-- Initialize PlayerData on resource start
CreateThread(function()
    Wait(500)
    if not PlayerData or not PlayerData.job then
        PlayerData = RSGCore.Functions.GetPlayerData()
    end
end)

-- Player loaded/unloaded
AddEventHandler('RSGCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    PlayerData = RSGCore.Functions.GetPlayerData()
end)

RegisterNetEvent('RSGCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
    PlayerData = {}
    isClockedIn = false
    isSeated = false
    isInClass = false
end)

RegisterNetEvent('RSGCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

-- Helper functions
local function IsTeacher()
    return PlayerData.job and PlayerData.job.name == Config.TeacherJob
end

-- ============================================================================
-- OX_TARGET SETUP
-- ============================================================================

CreateThread(function()
    Wait(2000) -- Wait for ox_target to load

    local school = Config.School

    -- Create Blip
    local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, school.blipCoords.x, school.blipCoords.y, school.blipCoords.z)
    SetBlipSprite(blip, GetHashKey('blip_ambient_hunting'), true)
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, school.name)

    -- Teacher Desk Target (on p_desk04x model)
    exports.ox_target:addModel(Config.DeskModel, {
        -- Clock In (Teacher only)
        {
            name = 'teacher_clock_in',
            icon = 'fas fa-sign-in-alt',
            label = Lang:t('label.target_clock_in'),
            onSelect = function()
                TriggerServerEvent('mack-teacher:server:clockIn')
            end,
            canInteract = function()
                return IsTeacher() and not isClockedIn
            end,
            distance = 2.5
        },
        -- Clock Out (Teacher only)
        {
            name = 'teacher_clock_out',
            icon = 'fas fa-sign-out-alt',
            label = Lang:t('label.target_clock_out'),
            onSelect = function()
                TriggerServerEvent('mack-teacher:server:clockOut')
            end,
            canInteract = function()
                return IsTeacher() and isClockedIn
            end,
            distance = 2.5
        },
        -- Start Class (Teacher only, must be clocked in)
        {
            name = 'teacher_start_class',
            icon = 'fas fa-book-open',
            label = Lang:t('label.target_start_class'),
            onSelect = function()
                TriggerServerEvent('mack-teacher:server:startClass')
            end,
            canInteract = function()
                return IsTeacher() and isClockedIn and not isInClass
            end,
            distance = 2.5
        },
        -- Top of Class / Leaderboard (Anyone)
        {
            name = 'teacher_leaderboard',
            icon = 'fas fa-trophy',
            label = Lang:t('label.target_top_of_class'),
            onSelect = function()
                TriggerServerEvent('mack-teacher:server:getLeaderboard')
            end,
            canInteract = function()
                return true
            end,
            distance = 2.5
        },
    })

    -- Student Stool Targets (on p_stool02x model)
    exports.ox_target:addModel(Config.StoolModel, {
        {
            name = 'student_sit',
            icon = 'fas fa-chair',
            label = Lang:t('label.target_sit_down'),
            onSelect = function(data)
                if isSeated then return end
                SitOnStool(data.entity)
            end,
            canInteract = function()
                return not isSeated and not IsTeacher()
            end,
            distance = 2.0
        },
    })
end)

-- ============================================================================
-- SEATING SYSTEM
-- ============================================================================

function SitOnStool(entity)
    if isSeated then return end

    local ped = PlayerPedId()
    local stoolCoords = GetEntityCoords(entity)
    local stoolHeading = GetEntityHeading(entity)

    -- Store starting position so we can return player here on stand up
    startingCoords = GetEntityCoords(ped)

    -- Calculate offset position relative to the stool (from phils-interactions)
    -- Offsets: x=0.0, y=0.0, z=0.5, heading=180.0 (for generic chairs/stools)
    local offsetX = 0.0
    local offsetY = 0.0
    local offsetZ = 0.5
    local offsetHeading = 180.0

    local r = math.rad(stoolHeading)
    local cosr = math.cos(r)
    local sinr = math.sin(r)
    local sitX = offsetX * cosr - offsetY * sinr + stoolCoords.x
    local sitY = offsetY * cosr + offsetX * sinr + stoolCoords.y
    local sitZ = offsetZ + stoolCoords.z
    local sitHeading = offsetHeading + stoolHeading

    -- Find the closest stool from config (for tracking)
    local closestIndex = nil
    local closestDist = 999.0
    for i, stool in ipairs(Config.StoolLocations) do
        local dist = #(stoolCoords - stool.coords)
        if dist < closestDist then
            closestDist = dist
            closestIndex = i
        end
    end
    if closestIndex and closestDist < 3.0 then
        seatedStoolIndex = closestIndex
    end

    -- Clear any current tasks and freeze player in place
    ClearPedTasksImmediately(ped)
    FreezeEntityPosition(ped, true)

    -- Use scenario-based seating (from phils-interactions)
    TaskStartScenarioAtPosition(ped, GetHashKey('PROP_HUMAN_SEAT_CHAIR'), sitX, sitY, sitZ, sitHeading, -1, false, true)

    isSeated = true
    TriggerServerEvent('mack-teacher:server:studentSeated', true)

    TriggerEvent('bln_notify:send', {
        title = Lang:t('success.seated'),
        description = Lang:t('success.seated_desc'),
        icon = 'tick',
        placement = 'top-right',
        duration = 4000
    })
end

-- Stand up from stool
function StandUp()
    if not isSeated then return end

    local ped = PlayerPedId()
    ClearPedTasksImmediately(ped)
    FreezeEntityPosition(ped, false)

    -- Return player to their starting position
    if startingCoords then
        SetEntityCoordsNoOffset(ped, startingCoords.x, startingCoords.y, startingCoords.z)
        startingCoords = nil
    end

    isSeated = false
    isInClass = false
    seatedStoolIndex = nil
    TriggerServerEvent('mack-teacher:server:studentSeated', false)
end

-- Allow standing up with a key (Backspace)
CreateThread(function()
    while true do
        Wait(0)
        if isSeated and not isInClass then
            if IsControlJustPressed(0, 0x156F7119) then -- Backspace
                StandUp()
            end
        else
            Wait(500)
        end
    end
end)

-- ============================================================================
-- CLOCK IN/OUT EVENTS
-- ============================================================================

RegisterNetEvent('mack-teacher:client:setClockedIn', function(state)
    isClockedIn = state
end)

-- ============================================================================
-- CLASS SYSTEM
-- ============================================================================

RegisterNetEvent('mack-teacher:client:startClass', function(bookData)
    if not isSeated and not IsTeacher() then return end

    isInClass = true

    -- Open book NUI
    SendNUIMessage({
        action = 'openBook',
        bookData = bookData
    })
    SetNuiFocus(true, true)

    -- Start progress bar
    exports['progressbar']:Progress({
        name = "reading_class",
        duration = Config.ClassDuration,
        label = Lang:t('label.reading'),
        useWhileDead = false,
        canCancel = false,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
    }, function(cancelled)
        -- Class complete - close book
        SendNUIMessage({ action = 'closeBook' })
        SetNuiFocus(false, false)

        -- Stand the player up and end the seated state
        if isSeated then
            StandUp()
        end

        isInClass = false

        if not cancelled then
            TriggerServerEvent('mack-teacher:server:classComplete')
        end
    end)
end)

-- XP notification
RegisterNetEvent('mack-teacher:client:xpAwarded', function(amount)
    TriggerEvent('bln_notify:send', {
        title = Lang:t('success.xp_increased'),
        description = Lang:t('success.xp_increased_desc', {xp = amount}),
        icon = 'tick',
        placement = 'top-right',
        duration = 5000
    })
end)

-- ============================================================================
-- LEADERBOARD
-- ============================================================================

RegisterNetEvent('mack-teacher:client:showLeaderboard', function(leaderboardData)
    SendNUIMessage({
        action = 'openLeaderboard',
        leaderboard = leaderboardData,
        playerCitizenId = PlayerData.citizenid or ''
    })
    SetNuiFocus(true, true)
end)

-- ============================================================================
-- TEACHER MENU (Clipboard NUI)
-- ============================================================================

RegisterNetEvent('mack-teacher:client:openTeacherMenu', function()
    if not IsTeacher() then return end

    SendNUIMessage({
        action = 'openTeacherMenu',
        school = Config.School,
        isClockedIn = isClockedIn,
        lang = {
            teacher_menu = Lang:t('label.teacher_menu'),
            clock_in = Lang:t('label.clock_in'),
            clock_out = Lang:t('label.clock_out'),
            start_class = Lang:t('label.start_class'),
            top_of_class = Lang:t('label.top_of_class'),
            close = Lang:t('label.close'),
        }
    })
    SetNuiFocus(true, true)
end)

-- ============================================================================
-- NUI CALLBACKS
-- ============================================================================

RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('closeBook', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('clockIn', function(data, cb)
    TriggerServerEvent('mack-teacher:server:clockIn')
    cb('ok')
end)

RegisterNUICallback('clockOut', function(data, cb)
    TriggerServerEvent('mack-teacher:server:clockOut')
    cb('ok')
end)

RegisterNUICallback('startClass', function(data, cb)
    TriggerServerEvent('mack-teacher:server:startClass')
    cb('ok')
end)

RegisterNUICallback('viewLeaderboard', function(data, cb)
    TriggerServerEvent('mack-teacher:server:getLeaderboard')
    cb('ok')
end)

-- ============================================================================
-- CLEANUP
-- ============================================================================

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if isSeated then
            local ped = PlayerPedId()
            ClearPedTasksImmediately(ped)
        end
        SendNUIMessage({ action = 'closeAll' })
        SetNuiFocus(false, false)
    end
end)
