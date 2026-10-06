local RSGCore = exports['rsg-core']:GetCoreObject()

-- In-memory state
local clockedInTeachers = {} -- { [src] = { citizenid, name, clockInTime } }
local seatedStudents = {}    -- { [src] = true }
local classInProgress = false
local lastClassTime = 0
local LEADERBOARD_FILE = 'leaderboard.json'
local leaderboardData = {}
local STORIES_FILE = 'stories.json'
local storiesData = {}

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

local function SendWebhook(webhookUrl, title, message, color)
    if not Config.Webhook.Enabled or webhookUrl == '' then return end

    local embed = {{
        ['title'] = title,
        ['description'] = message,
        ['color'] = color or 3447003,
        ['footer'] = { ['text'] = os.date('%c') }
    }}

    PerformHttpRequest(webhookUrl, function(err, text, headers) end, 'POST', json.encode({
        username = 'School System',
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

local function IsTeacher(src)
    local Player = RSGCore.Functions.GetPlayer(src)
    return Player and Player.PlayerData.job.name == Config.TeacherJob
end

local function IsClockedIn(src)
    return clockedInTeachers[src] ~= nil
end

-- ============================================================================
-- LEADERBOARD JSON MANAGEMENT
-- ============================================================================

local function LoadLeaderboard()
    local file = LoadResourceFile(GetCurrentResourceName(), LEADERBOARD_FILE)
    if file then
        local decoded = json.decode(file)
        if decoded then
            leaderboardData = decoded
        else
            leaderboardData = {}
        end
    else
        leaderboardData = {}
    end
end

local function SaveLeaderboard()
    SaveResourceFile(GetCurrentResourceName(), LEADERBOARD_FILE, json.encode(leaderboardData, {indent = true}), -1)
end

local function UpdateLeaderboard(citizenid, name, xpAmount, role)
    -- Find existing entry
    local found = false
    for i, entry in ipairs(leaderboardData) do
        if entry.citizenid == citizenid then
            leaderboardData[i].totalXP = (leaderboardData[i].totalXP or 0) + xpAmount
            leaderboardData[i].name = name -- Update name in case it changed
            leaderboardData[i].role = role or entry.role or 'student'
            leaderboardData[i].lastClass = os.date('%Y-%m-%d %H:%M:%S')
            found = true
            break
        end
    end

    if not found then
        table.insert(leaderboardData, {
            citizenid = citizenid,
            name = name,
            role = role or 'student',
            totalXP = xpAmount,
            lastClass = os.date('%Y-%m-%d %H:%M:%S')
        })
    end

    -- Sort by XP descending
    table.sort(leaderboardData, function(a, b)
        return (a.totalXP or 0) > (b.totalXP or 0)
    end)

    SaveLeaderboard()
end

-- ============================================================================
-- STORIES JSON MANAGEMENT
-- ============================================================================

local function LoadStories()
    local file = LoadResourceFile(GetCurrentResourceName(), STORIES_FILE)
    if file then
        local decoded = json.decode(file)
        if decoded then
            storiesData = decoded
        else
            storiesData = {}
        end
    else
        storiesData = {}
    end
end

local function SaveStories()
    SaveResourceFile(GetCurrentResourceName(), STORIES_FILE, json.encode(storiesData, {indent = true}), -1)
end

-- ============================================================================
-- CONTENT GENERATION
-- ============================================================================

local function GenerateBookContent()
    math.randomseed(os.time())

    -- Generate new stories for this class
    local newStories = {}

    -- Pick 2 "Ways to Die" stories
    for i = 1, 2 do
        local story = Config.WaysToDie[math.random(1, #Config.WaysToDie)]
        table.insert(newStories, {
            type = 'story',
            category = 'Ways to Die',
            content = story
        })
    end

    -- Pick 2 silly facts
    for i = 1, 2 do
        local fact = Config.SillyFacts[math.random(1, #Config.SillyFacts)]
        table.insert(newStories, {
            type = 'fact',
            category = 'Frontier Facts',
            content = fact
        })
    end

    -- Save new class to stories.json (prepend so newest is first)
    local classEntry = {
        date = os.date('%Y-%m-%d %H:%M:%S'),
        stories = newStories
    }
    table.insert(storiesData, 1, classEntry)

    -- Keep a maximum of 20 class entries to prevent file growing forever
    while #storiesData > 20 do
        table.remove(storiesData, #storiesData)
    end

    SaveStories()

    -- Build pages for the book: newest class first, older classes further back
    local pages = {}

    for classIdx, classData in ipairs(storiesData) do
        -- Title page for this class
        local isNewest = (classIdx == 1)
        local dieTitle = Config.BookTitles.waysToDie[math.random(1, #Config.BookTitles.waysToDie)]
        local factTitle = Config.BookTitles.sillyFacts[math.random(1, #Config.BookTitles.sillyFacts)]

        -- "Ways to Die" section title
        table.insert(pages, {
            type = 'title',
            content = dieTitle,
            category = isNewest and 'Today\'s Lesson' or ('Class - ' .. (classData.date or 'Unknown'))
        })

        -- Add the stories from this class
        for _, story in ipairs(classData.stories) do
            table.insert(pages, story)
        end
    end

    -- If no stories at all (shouldn't happen), add a fallback
    if #pages == 0 then
        table.insert(pages, {
            type = 'title',
            content = 'School Book',
            category = 'No lessons yet...'
        })
    end

    return { pages = pages }
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

CreateThread(function()
    Wait(2000)
    LoadLeaderboard()
    LoadStories()
    print('^2[Mack-Teacher]^7 Loaded leaderboard with ' .. #leaderboardData .. ' entries')
    print('^2[Mack-Teacher]^7 Loaded stories with ' .. #storiesData .. ' class entries')
end)

-- ============================================================================
-- CLOCK IN / CLOCK OUT
-- ============================================================================

RegisterServerEvent('mack-teacher:server:clockIn', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)

    if not Player or not IsTeacher(src) then
        TriggerClientEvent('bln_notify:send', src, {
            title = 'Error',
            description = 'You must be a teacher to clock in',
            icon = 'awards_set_n_008',
            placement = 'top-right',
            duration = 4000
        }, 'ERROR')
        return
    end

    if IsClockedIn(src) then
        TriggerClientEvent('bln_notify:send', src, {
            title = 'Error',
            description = 'You are already clocked in!',
            icon = 'awards_set_n_008',
            placement = 'top-right',
            duration = 4000
        }, 'ERROR')
        return
    end

    local charName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname

    clockedInTeachers[src] = {
        citizenid = Player.PlayerData.citizenid,
        name = charName,
        clockInTime = os.time()
    }

    TriggerClientEvent('mack-teacher:client:setClockedIn', src, true)

    TriggerClientEvent('bln_notify:send', src, {
        title = 'Clocked In',
        description = 'You are now teaching at ~#4CAF50~' .. Config.School.name .. '~e~!',
        icon = 'tick',
        placement = 'top-right',
        duration = 5000
    })

    -- Discord webhook
    SendWebhook(Config.Webhook.ClockInOut,
        Config.School.name .. ' is OPEN - Teacher on Duty!',
        string.format('🔔 **%s** is now open for business!\n\nTeacher: **%s**', Config.School.name, charName),
        3066993
    )
end)

RegisterServerEvent('mack-teacher:server:clockOut', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)

    if not Player or not IsTeacher(src) then
        TriggerClientEvent('bln_notify:send', src, {
            title = 'Error',
            description = 'You must be a teacher to clock out',
            icon = 'awards_set_n_008',
            placement = 'top-right',
            duration = 4000
        }, 'ERROR')
        return
    end

    if not IsClockedIn(src) then
        TriggerClientEvent('bln_notify:send', src, {
            title = 'Error',
            description = 'You are not clocked in!',
            icon = 'awards_set_n_008',
            placement = 'top-right',
            duration = 4000
        }, 'ERROR')
        return
    end

    local charName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname

    clockedInTeachers[src] = nil
    TriggerClientEvent('mack-teacher:client:setClockedIn', src, false)

    TriggerClientEvent('bln_notify:send', src, {
        title = 'Clocked Out',
        description = 'You have finished your shift at ~#4CAF50~' .. Config.School.name .. '~e~.',
        icon = 'tick',
        placement = 'top-right',
        duration = 5000
    })

    -- Discord webhook
    SendWebhook(Config.Webhook.ClockInOut,
        Config.School.name .. ' is CLOSED - No Teacher Available',
        string.format('🔕 **%s** is now closed.\n\nTeacher **%s** has finished their shift.', Config.School.name, charName),
        15158332
    )
end)

-- ============================================================================
-- STUDENT SEATING
-- ============================================================================

RegisterServerEvent('mack-teacher:server:studentSeated', function(seated)
    local src = source
    if seated then
        seatedStudents[src] = true
    else
        seatedStudents[src] = nil
    end
end)

-- ============================================================================
-- CLASS SYSTEM
-- ============================================================================

RegisterServerEvent('mack-teacher:server:startClass', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)

    if not Player or not IsTeacher(src) then
        TriggerClientEvent('bln_notify:send', src, {
            title = 'Error',
            description = 'You must be a teacher',
            icon = 'awards_set_n_008',
            placement = 'top-right',
            duration = 4000
        }, 'ERROR')
        return
    end

    if not IsClockedIn(src) then
        TriggerClientEvent('bln_notify:send', src, {
            title = 'Error',
            description = 'You must be clocked in first!',
            icon = 'awards_set_n_008',
            placement = 'top-right',
            duration = 4000
        }, 'ERROR')
        return
    end

    if classInProgress then
        TriggerClientEvent('bln_notify:send', src, {
            title = 'Error',
            description = 'A class is already in progress!',
            icon = 'awards_set_n_008',
            placement = 'top-right',
            duration = 4000
        }, 'ERROR')
        return
    end

    -- Check cooldown
    local timeSinceLastClass = os.time() - lastClassTime
    if timeSinceLastClass < Config.ClassCooldown then
        local remaining = Config.ClassCooldown - timeSinceLastClass
        TriggerClientEvent('bln_notify:send', src, {
            title = 'Error',
            description = string.format('You must wait %d seconds before starting another class', remaining),
            icon = 'awards_set_n_008',
            placement = 'top-right',
            duration = 4000
        }, 'ERROR')
        return
    end

    -- Check if any students are seated
    local studentCount = 0
    for _ in pairs(seatedStudents) do
        studentCount = studentCount + 1
    end

    if studentCount == 0 then
        TriggerClientEvent('bln_notify:send', src, {
            title = 'Error',
            description = 'No students are seated! Wait for students to sit down first.',
            icon = 'awards_set_n_008',
            placement = 'top-right',
            duration = 4000
        }, 'ERROR')
        return
    end

    classInProgress = true
    lastClassTime = os.time()

    -- Generate book content
    local bookData = GenerateBookContent()

    -- Send class start to all seated students
    for studentSrc, _ in pairs(seatedStudents) do
        TriggerClientEvent('mack-teacher:client:startClass', studentSrc, bookData)
    end

    -- Also send to the teacher
    TriggerClientEvent('mack-teacher:client:startClass', src, bookData)

    -- Notify teacher
    TriggerClientEvent('bln_notify:send', src, {
        title = 'Class Started',
        description = string.format('Teaching %d student(s)!', studentCount),
        icon = 'tick',
        placement = 'top-right',
        duration = 4000
    })

    if Config.Debug then
        print('^2[Mack-Teacher]^7 Class started by ' .. (clockedInTeachers[src] and clockedInTeachers[src].name or 'Unknown') .. ' with ' .. studentCount .. ' students')
    end

    -- Wait for class duration then mark as done
    SetTimeout(Config.ClassDuration + 2000, function()
        classInProgress = false
    end)
end)

-- ============================================================================
-- CLASS COMPLETE (called by each client when their progress bar finishes)
-- ============================================================================

RegisterServerEvent('mack-teacher:server:classComplete', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    local citizenid = Player.PlayerData.citizenid
    local charName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    local xpAmount = Config.XP.StudentAmount
    local role = 'student'

    -- If this is the teacher, give teacher XP amount
    if IsTeacher(src) and IsClockedIn(src) then
        xpAmount = Config.XP.TeacherAmount
        role = 'teacher'
    end

    -- Award XP via mack-xplevels-v3
    TriggerEvent('mack-levels:addXP', citizenid, xpAmount)

    -- Update leaderboard
    UpdateLeaderboard(citizenid, charName, xpAmount, role)

    -- Notify player
    TriggerClientEvent('mack-teacher:client:xpAwarded', src, xpAmount)

    if Config.Debug then
        print('^2[Mack-Teacher]^7 Awarded ' .. xpAmount .. ' XP to ' .. charName .. ' (' .. citizenid .. ')')
    end
end)

-- ============================================================================
-- LEADERBOARD
-- ============================================================================

RegisterServerEvent('mack-teacher:server:getLeaderboard', function()
    local src = source

    -- Separate students and teachers
    local students = {}
    local teachers = {}
    for _, entry in ipairs(leaderboardData) do
        if entry.role == 'teacher' then
            table.insert(teachers, entry)
        else
            table.insert(students, entry)
        end
    end

    -- Send separated leaderboard data to client
    TriggerClientEvent('mack-teacher:client:showLeaderboard', src, {
        students = students,
        teachers = teachers
    })
end)

-- ============================================================================
-- PLAYER DISCONNECT CLEANUP
-- ============================================================================

AddEventHandler('playerDropped', function(reason)
    local src = source
    -- Clean up clocked in teacher
    if clockedInTeachers[src] then
        clockedInTeachers[src] = nil
    end
    -- Clean up seated student
    if seatedStudents[src] then
        seatedStudents[src] = nil
    end
end)
