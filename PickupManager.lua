local Workspace = game:GetService("Workspace")

local QuestManager = require(script.Parent:WaitForChild("QuestManager"))

local questItemsFolder = Workspace:WaitForChild("QuestItems")

local function onItemClicked(player, itemModel)

    QuestManager:RecordItemFound(player, itemModel.Name)
    print(player.Name .. " picked up " .. itemModel.Name)

    itemModel.Parent = nil

    task.delay(10, function()
        local clone = itemModel:Clone()
        clone.Parent = questItemsFolder
        clone:PivotTo(itemModel:GetPivot())
        setupItem(clone) 
    end)
end

function setupItem(itemModel)

    local clickDetector
    if itemModel:IsA("Model") then
        clickDetector = itemModel:FindFirstChildWhichIsA("ClickDetector", true)
    elseif itemModel:IsA("BasePart") then
        clickDetector = itemModel:FindFirstChildOfClass("ClickDetector")
    end

    if not clickDetector then
        warn("No ClickDetector found in quest item: " .. itemModel.Name)
        return
    end

    clickDetector.MouseClick:Connect(function(player)
        onItemClicked(player, itemModel)
    end)
end

for _, item in ipairs(questItemsFolder:GetChildren()) do
    setupItem(item)
end

questItemsFolder.ChildAdded:Connect(setupItem)