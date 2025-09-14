local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local QuestManager = require(script.Parent:WaitForChild("QuestManager"))

local enemyFolder = ReplicatedStorage:WaitForChild("Enemies")
local spawnFolder = Workspace:WaitForChild("SpawnPoints")
local mobsFolder = workspace:WaitForChild("Mobs")

local spawnedEnemies = {}

local function giveCoins(player, amount)
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then return end
    local coinsStat = leaderstats:FindFirstChild("Coins")
    if not coinsStat then return end
    coinsStat.Value += amount
end

local function removeEnemyFromList(enemy)
    for i = #spawnedEnemies, 1, -1 do
        if spawnedEnemies[i] == enemy then
            table.remove(spawnedEnemies, i)
            return
        end
    end
end

local function connectEnemy(enemyClone)
    local humanoid = enemyClone:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    humanoid.Died:Connect(function()
        local deathCFrame = enemyClone:GetPivot()

        local creatorTag = humanoid:FindFirstChild("creator")
        if creatorTag and creatorTag.Value and creatorTag.Value:IsA("Player") then
            local player = creatorTag.Value
            giveCoins(player, 5)
            QuestManager:RecordKill(player, enemyClone.Name)
        end

        task.delay(0.5, function()
            enemyClone.Parent = nil
            removeEnemyFromList(enemyClone)

            task.delay(1.5, function()
                local enemyTemplate = enemyFolder:FindFirstChild(enemyClone.Name)
                if not enemyTemplate then return end

                local newEnemy = enemyTemplate:Clone()
                newEnemy.Parent = mobsFolder
                newEnemy:PivotTo(deathCFrame)

                table.insert(spawnedEnemies, newEnemy)
                connectEnemy(newEnemy)
            end)
        end)
    end)
end

local function spawnEnemyAtPoint(spawnPoint)
    local enemyTemplate = enemyFolder:FindFirstChild(spawnPoint.Name)
    if not enemyTemplate then return end

    local enemyClone = enemyTemplate:Clone()
    enemyClone.Parent = mobsFolder
    if enemyClone.PrimaryPart then
        enemyClone:SetPrimaryPartCFrame(spawnPoint.CFrame)
    else
        enemyClone:PivotTo(spawnPoint.CFrame)
    end

    table.insert(spawnedEnemies, enemyClone)
    connectEnemy(enemyClone)
end

for _, spawnPoint in ipairs(spawnFolder:GetChildren()) do
    if spawnPoint:IsA("BasePart") then
        spawnEnemyAtPoint(spawnPoint)
    end
end

task.spawn(function()
    while true do
        for _, enemy in ipairs(spawnedEnemies) do
            if enemy.Parent and (enemy.PrimaryPart or enemy:FindFirstChild("HumanoidRootPart")) then
                local enemyPos = (enemy.PrimaryPart or enemy:FindFirstChild("HumanoidRootPart")).Position
                for _, player in ipairs(Players:GetPlayers()) do
                    local character = player.Character
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    if humanoid and rootPart then
                        local distance = (enemyPos - rootPart.Position).Magnitude
                        if distance <= 2 then
                            humanoid:TakeDamage(5)
                        end
                    end
                end
            end
        end
        task.wait(1)
    end
end)