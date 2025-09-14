local Players = game:GetService("Players")

local questDefinitions = {
    KillEnemies = {
        description = "Defeat 5 BasicEnemies",
        type = "Kill",
        target = "BasicEnemy",
        required = 5,
        rewardCoins = 100
    },
    PlayTime = {
        description = "Play for 2 minutes",
        type = "Time",
        required = 120,
        rewardCoins = 20
    },
    FindItems = {
        description = "Collect 3 QuestItems",
        type = "Collect",
        target = "Key",
        required = 3,
        rewardCoins = 30
    }
}

local activeQuests = {}

local function giveCoins(player, amount)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local coinsStat = leaderstats:FindFirstChild("Coins")
        if coinsStat then
            coinsStat.Value += amount
        end
    end
end

local function completeQuest(player, questId)
    local quest = questDefinitions[questId]
    if not quest then return end

    print(player.Name .. " completed quest: " .. questId)
    giveCoins(player, quest.rewardCoins)

    activeQuests[player][questId] = { progress = 0 }
end

local function onPlayerAdded(player)
    activeQuests[player] = {}
    for questId in pairs(questDefinitions) do
        activeQuests[player][questId] = { progress = 0 }
    end

    task.spawn(function()
        while player.Parent do
            local quest = questDefinitions.PlayTime
            if quest and activeQuests[player]["PlayTime"] then
                local data = activeQuests[player]["PlayTime"]
                data.progress += 1
                if data.progress >= quest.required then
                    completeQuest(player, "PlayTime")
                end
            end
            task.wait(1)
        end
    end)
end

local function onPlayerRemoving(player)
    activeQuests[player] = nil
end

local QuestManager = {}

function QuestManager:RecordKill(player, enemyName)
    for questId, quest in pairs(questDefinitions) do
        if quest.type == "Kill" and quest.target == enemyName then
            local data = activeQuests[player] and activeQuests[player][questId]
            if data then
                data.progress += 1
                print(player.Name .. " progress for " .. questId .. ": " .. data.progress .. "/" .. quest.required)
                if data.progress >= quest.required then
                    completeQuest(player, questId)
                end
            end
        end
    end
end

function QuestManager:RecordItemFound(player, itemName)
    for questId, quest in pairs(questDefinitions) do
        if quest.type == "Collect" and quest.target == itemName then
            local data = activeQuests[player] and activeQuests[player][questId]
            if data then
                data.progress += 1
                print(player.Name .. " progress for " .. questId .. ": " .. data.progress .. "/" .. quest.required)
                if data.progress >= quest.required then 
                    completeQuest(player, questId)
                end
            else
                warn("No active quest data for " .. player.Name .. " on quest " .. questId)
            end
        end
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

return QuestManager