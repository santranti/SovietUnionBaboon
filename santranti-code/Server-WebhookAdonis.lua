local WEBHOOK_URL: string = "YOUR_WEBHOOK_URL" -- Your webhook URL

local IGNORE_PLAYER_COMMANDS: boolean = true -- Whether player-level commands won't be logged to the webhook

local IGNORED_COMMANDS: {string} = {}

return function(Vargs)
	local server, service = Vargs.Server, Vargs.Service
	local Admin = server.Admin
	local HttpService = service.HttpService

	service.Events.CommandRan:Connect(function(player, data)
		local cmd = data.Message

		if IGNORE_PLAYER_COMMANDS and (not cmd or cmd.AdminLevel == 0) then
			return
		end

		local args = data.Args or {}
		local formattedCommand: string = cmd  

		local playerName = player.Name

		local discordMessage = string.format("Command Executed: `%s` by `%s`", formattedCommand, playerName)

		print("Formatted Command:", formattedCommand)  -- Debug print

		if not table.find(IGNORED_COMMANDS, data.Index) and
			not table.find(IGNORED_COMMANDS, data.Matched) and
			not table.find(IGNORED_COMMANDS, data.Matched:sub(#(cmd and cmd.Prefix or "") + 1)) then
			local success, err = pcall(HttpService.PostAsync, HttpService, WEBHOOK_URL, HttpService:JSONEncode({
				content = discordMessage
			}))

			if success then
				print("Webhook command log posted successfully.")
			else
				warn("Webhook command log failed to post:", err)
			end
		end
	end)
end



