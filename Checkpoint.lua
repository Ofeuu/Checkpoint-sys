local Players = game:GetService("Players")
local MPS = game:GetService("MarketplaceService")
local SKIP_CHECKPOINT_ID = --ID da gamepass

local player = Players.PlayerAdded:Wait()
local leaderstats = player:WaitForChild("leaderstats")
local character = player.Character or player.CharacterAdded:Wait()

-- Conecta todos os checkpoints
for _, checkpoint in pairs(workspace.MAP.CHECKPOINTS:GetChildren()) do
	if checkpoint:IsA("Part") then
		checkpoint.Touched:Connect(function(hit)
			local humanoid = hit.Parent:FindFirstChild("Humanoid")
			if humanoid then
				if leaderstats.stage.Value ~= checkpoint.Name then
					leaderstats.stage.Value = checkpoint.Name
				end
			end
		end)
	end
end

-- Função para teleportar
local function teleport(plr, char)
	local stage = plr.leaderstats.stage
	for _, checkpoint in pairs(workspace.MAP.CHECKPOINTS:GetChildren()) do
		if checkpoint:IsA("Part") and checkpoint.Name == stage.Value then
			if char:FindFirstChild("HumanoidRootPart") then
				print("Teletransportando para o checkpoint: " .. checkpoint.Name)
				char:MoveTo(checkpoint.Position)
			end
			break
		end
	end
end

-- Processamento de produto (skip checkpoint)
MPS.ProcessReceipt = function(receipt)
	local userId = receipt.PlayerId
	local productId = receipt.ProductId
	local plr = Players:GetPlayerByUserId(userId)

	if not plr then return Enum.ProductPurchaseDecision.NotProcessedYet end

	local char = plr.Character or plr.CharacterAdded:Wait()
	local stage = plr:WaitForChild("leaderstats"):WaitForChild("stage")

	if productId == SKIP_CHECKPOINT_ID then
		-- Tenta converter o valor do stage para número
		local currentStageNumber = tonumber(stage.Value)
		if currentStageNumber then
			stage.Value = tostring(currentStageNumber + 1)
			teleport(plr, char)
		else
			warn("Stage atual não é número: " .. tostring(stage.Value))
		end
	end

	return Enum.ProductPurchaseDecision.PurchaseGranted
end


