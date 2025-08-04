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
    if not guiPath then return 0 end
    rawText = guiPath.Text or ""
    cleaned = rawText:gsub("[^%d%-]", "")
    return tonumber(cleaned) or 0
end

function waitForCash(minAmount)
    while getCash() < minAmount do
        task.wait(1)
    end
end

-- --- Safe Remote Invocation Helpers ---
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

-- --- Lobby Actions (After Game Join / Teleport) ---
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
    vector.create(16.38364601135254, 9.824828147888184, 58.03911209106445)
})
task.wait(1)

-- Vote Ready
safeInvoke({
    "LobbyVoting",
    "Ready"
})

task.wait(5)

-- Send the 'Skip' vote once.
game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunction"):InvokeServer("Voting", "Skip")
task.wait(1)

-- --- In-Match Tower Placement (Simplicity - Brawler & Accelerator) ---
placementSequence = {
    -- The first brawler is placed immediately to beat the first wave
    { args = { "Troops", "Pl\208\176ce", { Rotation = CFrame.new(0, 0, 0, 1, -0, 0, 0, 1, -0, 0, 0, 1), Position = vector.create(-20.368831634521484, 0.9999852180480957, -12.301240921020508) }, "Brawler" }, cost = 600 },
    -- Remaining Brawlers
    { args = { "Troops", "Pl\208\176ce", { Rotation = CFrame.new(0, 0, 0, 1, -0, 0, 0, 1, -0, 0, 0, 1), Position = vector.create(-17.884721755981445, 0.9999923706054688, -11.87646198272705) }, "Brawler" }, cost = 600 },
    { args = { "Troops", "Pl\208\176ce", { Rotation = CFrame.new(0, 0,
