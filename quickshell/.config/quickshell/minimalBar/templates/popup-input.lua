-- Observe presses without grabbing, replaying, or consuming the app's input.
-- Loaded by PopupInput.qml; no permanent Hyprland config changes are needed.
return function(config_path)
	if _G.minimalBarPopupInput and _G.minimalBarPopupInput.version == 2 then
		return
	end
	if _G.minimalBarPopupInput then
		for _, binding in ipairs(_G.minimalBarPopupInput) do
			binding:remove()
		end
	end
	local observer = { version = 2 }

	local function shell_quote(value)
		return "'" .. value:gsub("'", "'\\''") .. "'"
	end

	local command = "quickshell ipc -p " .. shell_quote(config_path) .. " call -- popupInput outsideClick "

	local function observe_press()
		local popup_open = false
		for _, layer in ipairs(hl.get_layers({ namespace = "minimalbar-popup" })) do
			if layer.mapped then
				popup_open = true
				break
			end
		end
		if not popup_open then
			return
		end

		local pos = hl.get_cursor_pos()
		local card = observer.card
		if not card then
			return
		end
		local x, y = pos.x - card[1], pos.y - card[2]
		if x >= 0 and y >= 0 and x < card[3] and y < card[4] then
			local radius = math.min(card[5], card[3] / 2, card[4] / 2)
			local dx = x - math.max(radius, math.min(card[3] - radius, x))
			local dy = y - math.max(radius, math.min(card[4] - radius, y))
			if dx * dx + dy * dy <= radius * radius then
				return
			end
		end
		for _, bar in ipairs(hl.get_layers({ namespace = "minimalbar-bar" })) do
			local origin = bar.monitor and bar.monitor.position or { x = 0, y = 0 }
			local bx, by = bar.x + origin.x, bar.y + origin.y
			if bar.mapped and pos.x >= bx and pos.x < bx + bar.w and pos.y >= by and pos.y < by + bar.h then
				return
			end
		end

		hl.exec_cmd(command .. math.floor(pos.x) .. " " .. math.floor(pos.y) .. " " .. observer.serial)
	end

	for button = 272, 279 do
		observer[#observer + 1] = hl.bind("mouse:" .. button, observe_press, {
			non_consuming = true,
			ignore_mods = true,
			submap_universal = true,
			bypass = true,
			description = "Dismiss an open minimalBar menu after an outside press",
		})
	end
	_G.minimalBarPopupInput = observer
end
