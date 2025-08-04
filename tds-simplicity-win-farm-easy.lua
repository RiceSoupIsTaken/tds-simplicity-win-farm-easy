ReplicatedStorage = game:GetService("ReplicatedStorage")
TeleportService = game:GetService("TeleportService")
remoteFunction = ReplicatedStorage:WaitForChild("RemoteFunction")
player = game.Players.LocalPlayer

remoteEvent = ReplicatedStorage:WaitForChild("RemoteEvent")

-- --- Initial Game Entry / Lobby Check ---
if workspace:FindFirstChild("Elevators") then
    args = {
        [1] = "Multiplayer",
        [2] = "v2:start",
        [3] = {
            ["difficulty"] = "Easy",
            ["mode"] = "survival",
            ["count"] = 1
        }
    }
    remoteFunction:InvokeServer(unpack(args))
    task.wait(3)
else
    remoteFunction:InvokeServer("Voting", "Skip")
    task.wait(1)
end

-- --- Cash Retrieval Functions ---
guiPath = player:WaitForChild("PlayerGui")
    :WaitForChild("ReactUniversalHotbar")
    :WaitForChild("Frame")
    :WaitForChild("values")
    :WaitForChild("cash")
    :WaitForChild("amount")

function getCash()
    rawText = guiPath.Text or ""
    cleaned = rawText:gsub("[^%d%-]", "")
    return tonumber(cleaned) or 0
end

function waitForCash(minAmount)
    while getCash() < minAmount do
        task.wait(1)
    end
end

-- --- Safe Remote Invocation Helpers (No console output from these) ---
function safeInvoke(args, cost)
    if cost then
        waitForCash(cost)
    end
    pcall(function()
        remoteFunction:InvokeServer(unpack(args))
    end)
    task.wait(1)
end

function safeFire(args)
    pcall(function()
        remoteEvent:FireServer(unpack(args))
    end)
    task.wait(1)
end

-- --- Lobby Actions (After Game Join / Teleport to Pre-Match Lobby) ---
task.wait(5)

-- Map Override
safeInvoke({
    "LobbyVoting",
    "Override",
    "Simplicity"
})
task.wait(1)

-- Vote for Simplicity
safeFire({
    "LobbyVoting",
    "Vote",
    "Simplicity",
    Vector3.new(16.38364601135254, 9.824828147888184, 58.03911209106445)
})
task.wait(1)

-- Vote Ready
safeInvoke({
    "LobbyVoting",
    "Ready"
})
task.wait(10)
-- NEW: This is the new ready button you found.
safeInvoke({
	"Voting",
	"Skip"
})


-- Ensure character is loaded and get necessary parts
character = player.Character or player.CharacterAdded:Wait()
humanoidRootPart = character:WaitForChild("HumanoidRootPart")
humanoid = character:WaitForChild("Humanoid")
task.wait(1)

-- --- In-Match Tower Placement (Simplicity - Brawler & Accelerator) ---
placementSequence = {
    -- Brawlers (Cost 600 each)
    { args = { "Troops", "Place", { Rotation = CFrame.new(0, 0, 0, 1, -0, 0, 0, 1, -0, 0, 0, 1), Position = Vector3.new(-20.368831634521484, 0.9999852180480957, -12.301240921020508) }, "Brawler" }, cost = 600 },
    { args = { "Troops", "Place", { Rotation = CFrame.new(0, 0, 0, 1, -0, 0, 0, 1, -0, 0, 0, 1), Position = Vector3.new(-17.884721755981445, 0.9999923706054688, -11.87646198272705) }, "Brawler" }, cost = 600 },
    { args = { "Troops", "Place", { Rotation = CFrame.new(0, 0, 0, 1, -0, 0, 0, 1, -0, 0, 0, 1), Position = Vector3.new(-18.509071350097656, 0.9999880790710449, -9.548937797546387) }, "Brawler" }, cost = 600 },
    { args = { "Troops", "Place", { Rotation = CFrame.new(0, 0, 0, 1, -0, 0, 0, 1, -0, 0, 0, 1), Position = Vector3.new(-18.355854034423828, 1.0000011920928955, -7.118582725524902) }, "Brawler" }, cost = 600 },
    { args = { "Troops", "Place", { Rotation = CFrame.new(0, 0, 0, 1, -0, 0, 0, 1, -0, 0, 0, 1), Position = Vector3.new(-18.39682388305664, 1.0000007152557373, -4.743110656738281) }, "Brawler" }, cost = 600 },
    { args = { "Troops", "Place", { Rotation = CFrame.new(0, 0, 0, 1, -0, 0, 0, 1, -0, 0, 0, 1), Position = Vector3.new(-17.87398910522461, 1.0000003576278687, -2.154684066772461) }, "Brawler" }, cost = 600 },
    -- Accelerator (Cost 4500)
    { args = { "Troops", "Place", { Rotation = CFrame.new(0, 0, 0, 1, -0, 0, 0, 1, -0, 0, 0, 1), Position = Vector3.new(-6.117673873901367, 0.9999880790710449, -3.684736728668213) }, "Accelerator" }, cost = 4500 },
}

for _, step in ipairs(placementSequence) do
    safeInvoke(step.args, step.cost)
end

-- --- Parallel Upgrade Loop and Main Gameplay Timer ---
upgradeDone = false
task.spawn(function()
    towerFolder = workspace:WaitForChild("Towers", 600)
    if not towerFolder then return end
    maxedTowers = {}

    while not upgradeDone do
        towers = towerFolder:GetChildren()
        for i, tower in ipairs(towers) do
            if not maxedTowers[tower] then
                args = {
                    "Troops",
                    "Upgrade",
                    "Set",
                    {
                        Troop = tower,
                        Path = 1
                    }
                }
                success, err = pcall(function()
                    remoteFunction:InvokeServer(unpack(args))
                end)
                if not success and string.find(tostring(err), "Max Level", 1, true) then
                    maxedTowers[tower] = true
                end
            end
        end
        task.wait(1)
    end
end)

-- Main gameplay timer set to 600 seconds (10 minutes) as requested
task.wait(600)

upgradeDone = true
task.wait(1)

-- --- End of Round: Teleport ---
TeleportService:Teleport(3260590327)
