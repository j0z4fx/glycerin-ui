local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Scale = 1.2

local function px(value)
	return math.round(value * Scale)
end

local NunitoBoldFace = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)

local function getPointerPosition()
	return UserInputService:GetMouseLocation()
end

local function colorFromHex(hex)
	hex = hex:gsub("#", "")

	return Color3.fromRGB(
		tonumber(hex:sub(1, 2), 16),
		tonumber(hex:sub(3, 4), 16),
		tonumber(hex:sub(5, 6), 16)
	)
end

-- These tokens were derived in OKLCH first, then converted back to hex.
local ThemeHex = {
	surface0 = "#060607",
	surface1 = "#0d0d0f",
	surface2 = "#141517",
	surface3 = "#1b1c1f",
	surface4 = "#242528",
	surface5 = "#2e2f33",
	surface6 = "#3b3d41",
	surface7 = "#494b50",
	textMain = "#eff0f2",
	textSecondary = "#c7c8cb",
	textTertiary = "#a0a2a6",
	textMuted = "#797b80",
	success = "#74c878",
	error = "#f66d67",
	info = "#65b2f1",
	accent = "#4278f5",
	accentSoft = "#7da3e8",
	accentSurface = "#1a2a4a",
	background = "#0d0d0f",
	surface = "#1b1c1f",
	surfaceElevated = "#242528",
	stroke = "#3b3d41",
	text = "#eff0f2",
}

local Theme = {}

for name, hex in pairs(ThemeHex) do
	Theme[name] = colorFromHex(hex)
end

-- Lucide icon library (spritesheet-based)
local Lucide = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/deividcomsono/lucide-roblox-direct/refs/heads/main/source.lua"
))()

local player = Players.LocalPlayer

if not player then
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	player = Players.LocalPlayer
end

local playerGui = player:WaitForChild("PlayerGui")

local function makeWindowDraggable(window, dragZones)
	local dragState = {
		active = false,
		startPosition = nil,
		startInputPosition = nil,
	}

	local function beginDrag(input)
		dragState.active = true
		dragState.startPosition = window.Position
		dragState.startInputPosition = input.Position
	end

	local function endDrag()
		dragState.active = false
	end

	local function updateDrag(input)
		if not dragState.active then
			return
		end

		local delta = input.Position - dragState.startInputPosition
		window.Position = UDim2.new(
			dragState.startPosition.X.Scale,
			dragState.startPosition.X.Offset + delta.X,
			dragState.startPosition.Y.Scale,
			dragState.startPosition.Y.Offset + delta.Y
		)
	end

	for _, dragZone in ipairs(dragZones) do
		dragZone.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				beginDrag(input)
			end
		end)

		dragZone.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				endDrag()
			end
		end)
	end

	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			updateDrag(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			endDrag()
		end
	end)
end

local function createPartialCornerMask(parent, backgroundColor, size, position, zIndex)
	local mask = Instance.new("Frame")
	mask.Name = "CornerMask"
	mask.BackgroundColor3 = backgroundColor
	mask.BorderSizePixel = 0
	mask.Size = size
	mask.Position = position
	mask.ZIndex = zIndex or (parent.ZIndex + 1)
	mask.Parent = parent

	return mask
end

local function createGroupBox(parent, title, width)
	local titleBarHeight = px(30)

	local groupBox = Instance.new("Frame")
	groupBox.Name = title:gsub("%s+", "") .. "GroupBox"
	groupBox:SetAttribute("IsGroupBox", true)
	groupBox.BackgroundTransparency = 1
	groupBox.BorderSizePixel = 0
	groupBox.Size = UDim2.fromOffset(width, titleBarHeight)
	groupBox.AutomaticSize = Enum.AutomaticSize.Y
	groupBox.Parent = parent

	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Active = true
	titleBar.BackgroundTransparency = 1
	titleBar.BorderSizePixel = 0
	titleBar.Size = UDim2.fromOffset(width, titleBarHeight)
	titleBar.Parent = groupBox

	local titleBarFill = Instance.new("Frame")
	titleBarFill.Name = "Fill"
	titleBarFill.BackgroundColor3 = Theme.surface4
	titleBarFill.BorderSizePixel = 0
	titleBarFill.Size = UDim2.fromScale(1, 1)
	titleBarFill.Parent = titleBar

	local titleBarCorner = Instance.new("UICorner")
	titleBarCorner.CornerRadius = UDim.new(0, px(10))
	titleBarCorner.Parent = titleBarFill

	createPartialCornerMask(
		titleBar,
		Theme.surface4,
		UDim2.new(1, 0, 0, px(10)),
		UDim2.new(0, 0, 1, -px(10)),
		2
	)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.BackgroundTransparency = 1
	titleLabel.BorderSizePixel = 0
	titleLabel.Size = UDim2.fromScale(1, 1)
	titleLabel.FontFace = NunitoBoldFace
	titleLabel.Text = title
	titleLabel.TextColor3 = Theme.textMain
	titleLabel.TextSize = px(14)
	titleLabel.TextStrokeTransparency = 1
	titleLabel.TextXAlignment = Enum.TextXAlignment.Center
	titleLabel.TextYAlignment = Enum.TextYAlignment.Center
	titleLabel.ZIndex = 3
	titleLabel.Parent = titleBar

	local body = Instance.new("Frame")
	body.Name = "Body"
	body.BackgroundTransparency = 1
	body.BorderSizePixel = 0
	body.Position = UDim2.fromOffset(0, titleBarHeight)
	body.Size = UDim2.fromOffset(width, 0)
	body.AutomaticSize = Enum.AutomaticSize.Y
	body.Parent = groupBox

	local bodyFill = Instance.new("Frame")
	bodyFill.Name = "Fill"
	bodyFill.BackgroundColor3 = Theme.surface2
	bodyFill.BorderSizePixel = 0
	bodyFill.Size = UDim2.new(1, 0, 1, 0)
	bodyFill.AutomaticSize = Enum.AutomaticSize.Y
	bodyFill.Parent = body

	local bodyCorner = Instance.new("UICorner")
	bodyCorner.CornerRadius = UDim.new(0, px(10))
	bodyCorner.Parent = bodyFill

	createPartialCornerMask(
		body,
		Theme.surface2,
		UDim2.new(1, 0, 0, px(10)),
		UDim2.fromOffset(0, 0),
		2
	)

	local contentInset = Instance.new("Frame")
	contentInset.Name = "ContentInset"
	contentInset.BackgroundTransparency = 1
	contentInset.BorderSizePixel = 0
	contentInset.Size = UDim2.new(1, 0, 0, 0)
	contentInset.AutomaticSize = Enum.AutomaticSize.Y
	contentInset.ZIndex = 3
	contentInset.Parent = body

	local contentInsetPadding = Instance.new("UIPadding")
	contentInsetPadding.PaddingTop = UDim.new(0, px(3))
	contentInsetPadding.PaddingBottom = UDim.new(0, px(2))
	contentInsetPadding.PaddingLeft = UDim.new(0, px(2))
	contentInsetPadding.PaddingRight = UDim.new(0, px(2))
	contentInsetPadding.Parent = contentInset

	local contentContainer = Instance.new("Frame")
	contentContainer.Name = "ContentContainer"
	contentContainer.BackgroundTransparency = 1
	contentContainer.BorderSizePixel = 0
	contentContainer.Size = UDim2.new(1, 0, 0, 0)
	contentContainer.AutomaticSize = Enum.AutomaticSize.Y
	contentContainer.ZIndex = 3
	contentContainer.Parent = contentInset

	local contentLayout = Instance.new("UIListLayout")
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.Padding = UDim.new(0, px(2))
	contentLayout.Parent = contentContainer

	local function updateBodyVisibility()
		local contentCount = 0

		for _, child in ipairs(contentContainer:GetChildren()) do
			if not child:IsA("UIListLayout") then
				contentCount += 1
			end
		end

		body.Visible = contentCount > 0
	end

	contentContainer.ChildAdded:Connect(updateBodyVisibility)
	contentContainer.ChildRemoved:Connect(updateBodyVisibility)

	updateBodyVisibility()

	return {
		root = groupBox,
		titleBar = titleBar,
		titleLabel = titleLabel,
		body = body,
		content = contentContainer,
	}
end

local function getOrderedGroupBoxRoots(container, exclude)
	local groupBoxes = {}

	for _, child in ipairs(container:GetChildren()) do
		if child:GetAttribute("IsGroupBox") and child ~= exclude then
			table.insert(groupBoxes, child)
		end
	end

	table.sort(groupBoxes, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)

	return groupBoxes
end

local function normalizeGroupBoxOrders(container)
	local orderedGroupBoxes = getOrderedGroupBoxRoots(container)

	for index, groupBox in ipairs(orderedGroupBoxes) do
		groupBox.LayoutOrder = index
	end
end

local function createDropIndicator(width, height)
	local indicator = Instance.new("Frame")
	indicator.Name = "DropIndicator"
	indicator.BackgroundTransparency = 1
	indicator.BorderSizePixel = 0
	indicator.Size = UDim2.fromOffset(width, height)

	local inset = px(2)

	local outline = Instance.new("Frame")
	outline.Name = "Outline"
	outline.AnchorPoint = Vector2.new(0.5, 0.5)
	outline.BackgroundTransparency = 1
	outline.BorderSizePixel = 0
	outline.Position = UDim2.fromScale(0.5, 0.5)
	outline.Size = UDim2.new(1, -(inset * 2), 1, -(inset * 2))
	outline.Parent = indicator

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, px(10))
	corner.Parent = outline

	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Theme.accent
	stroke.Thickness = px(2)
	stroke.Transparency = 0.25
	stroke.Parent = outline

	return indicator
end

local function enableGroupBoxDragAndDrop(screenGui, columns)
	local columnList = {
		columns.left,
		columns.middle,
		columns.right,
	}

	local dragState = {
		active = false,
		group = nil,
		sourceParent = nil,
		sourceSize = nil,
		sourceAutomaticSize = nil,
		startInputPosition = nil,
		startAbsolutePosition = nil,
		dragVisual = nil,
	}

	local dropIndicator = nil

	local function resolveTargetColumn(mousePosition)
		local bestColumn = columnList[1]
		local bestDistance = math.huge

		for _, column in ipairs(columnList) do
			local columnCenterX = column.AbsolutePosition.X + (column.AbsoluteSize.X / 2)
			local distance = math.abs(mousePosition.X - columnCenterX)

			if distance < bestDistance then
				bestDistance = distance
				bestColumn = column
			end
		end

		return bestColumn
	end

	local function applyDropIndicator(targetColumn, mousePositionY)
		local orderedGroupBoxes = getOrderedGroupBoxRoots(targetColumn, dragState.group.root)
		local insertIndex = #orderedGroupBoxes + 1

		for index, groupBoxRoot in ipairs(orderedGroupBoxes) do
			local centerY = groupBoxRoot.AbsolutePosition.Y + (groupBoxRoot.AbsoluteSize.Y / 2)

			if mousePositionY < centerY then
				insertIndex = index
				break
			end
		end

		-- Capture positions of all groupboxes BEFORE reorder
		local oldPositions = {}
		for _, groupBoxRoot in ipairs(orderedGroupBoxes) do
			oldPositions[groupBoxRoot] = groupBoxRoot.AbsolutePosition
		end
		if dropIndicator then
			oldPositions[dropIndicator] = dropIndicator.AbsolutePosition
		end

		dropIndicator.Parent = targetColumn

		local orderedItems = {}

		for index, groupBoxRoot in ipairs(orderedGroupBoxes) do
			if index == insertIndex then
				table.insert(orderedItems, dropIndicator)
			end

			table.insert(orderedItems, groupBoxRoot)
		end

		if insertIndex == (#orderedGroupBoxes + 1) then
			table.insert(orderedItems, dropIndicator)
		end

		for index, item in ipairs(orderedItems) do
			item.LayoutOrder = index
		end

		-- After layout recalculates, animate from old to new positions
		local layoutTweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		task.defer(function()
			for _, groupBoxRoot in ipairs(orderedGroupBoxes) do
				local oldPos = oldPositions[groupBoxRoot]
				if oldPos then
					local newPos = groupBoxRoot.AbsolutePosition
					local deltaY = oldPos.Y - newPos.Y

					if math.abs(deltaY) > 1 then
						local layoutPos = groupBoxRoot.Position
						groupBoxRoot.Position = UDim2.new(
							layoutPos.X.Scale, layoutPos.X.Offset,
							layoutPos.Y.Scale, layoutPos.Y.Offset + deltaY
						)
						TweenService:Create(groupBoxRoot, layoutTweenInfo, {
							Position = layoutPos,
						}):Play()
					end
				end
			end
		end)
	end

	local function beginGroupBoxDrag(groupBox, input)
		if dragState.active then
			return
		end

		local absolutePosition = groupBox.root.AbsolutePosition
		local absoluteSize = groupBox.root.AbsoluteSize
		local mousePosition = getPointerPosition()

		-- AbsolutePosition and input.Position are in CoreUISafeInsets space
		-- (origin below the Roblox top bar), but the ScreenGui uses
		-- IgnoreGuiInset = true (origin at the true screen top-left).
		-- Shift by the GUI inset so the drag visual lands at the correct spot.
		local guiInset = GuiService:GetGuiInset()
		local correctedPosition = Vector2.new(
			absolutePosition.X + guiInset.X,
			absolutePosition.Y + guiInset.Y
		)

		dragState.active = true
		dragState.group = groupBox
		dragState.sourceParent = groupBox.root.Parent
		dragState.sourceSize = groupBox.root.Size
		dragState.sourceAutomaticSize = groupBox.root.AutomaticSize
		dragState.startInputPosition = input.Position
		dragState.startAbsolutePosition = correctedPosition

		dropIndicator = createDropIndicator(absoluteSize.X, absoluteSize.Y)
		dropIndicator.LayoutOrder = groupBox.root.LayoutOrder
		dropIndicator.Parent = dragState.sourceParent
		screenGui:SetAttribute("IsDraggingGroupBox", true)

		dragState.dragVisual = groupBox.root:Clone()
		dragState.dragVisual.Parent = screenGui
		dragState.dragVisual.AutomaticSize = Enum.AutomaticSize.None
		dragState.dragVisual.Size = UDim2.fromOffset(absoluteSize.X, absoluteSize.Y)
		dragState.dragVisual.Position = UDim2.fromOffset(correctedPosition.X, correctedPosition.Y)
		dragState.dragVisual.ZIndex = 20

		groupBox.root.Parent = screenGui
		groupBox.root.AutomaticSize = Enum.AutomaticSize.None
		groupBox.root.Size = UDim2.fromOffset(absoluteSize.X, absoluteSize.Y)
		groupBox.root.Position = UDim2.fromOffset(correctedPosition.X, correctedPosition.Y)
		groupBox.root.Visible = false

		applyDropIndicator(dragState.sourceParent, mousePosition.Y)
	end

	local function updateGroupBoxDrag(input)
		if not dragState.active then
			return
		end

		if not input.Position or not dragState.startInputPosition or not dragState.startAbsolutePosition then
			return
		end

		local targetColumn = resolveTargetColumn(input.Position)
		local delta = input.Position - dragState.startInputPosition

		dragState.dragVisual.Position = UDim2.fromOffset(
			dragState.startAbsolutePosition.X + delta.X,
			dragState.startAbsolutePosition.Y + delta.Y
		)

		applyDropIndicator(targetColumn, input.Position.Y)
	end

	local function endGroupBoxDrag()
		if not dragState.active then
			return
		end

		local targetColumn = (dropIndicator and dropIndicator.Parent) or dragState.sourceParent

		if not dragState.group or not targetColumn then
			if dropIndicator then
				dropIndicator:Destroy()
				dropIndicator = nil
			end

			if dragState.dragVisual then
				dragState.dragVisual:Destroy()
				dragState.dragVisual = nil
			end

			screenGui:SetAttribute("IsDraggingGroupBox", false)
			dragState.active = false
			dragState.group = nil
			dragState.sourceParent = nil
			dragState.sourceSize = nil
			dragState.sourceAutomaticSize = nil
			dragState.startInputPosition = nil
			dragState.startAbsolutePosition = nil
			return
		end

		if dragState.dragVisual then
			dragState.dragVisual:Destroy()
			dragState.dragVisual = nil
		end

		dragState.group.root.Parent = targetColumn
		dragState.group.root.LayoutOrder = dropIndicator and dropIndicator.LayoutOrder or dragState.group.root.LayoutOrder
		dragState.group.root.AutomaticSize = dragState.sourceAutomaticSize
		dragState.group.root.Size = dragState.sourceSize
		dragState.group.root.Position = UDim2.fromOffset(0, 0)
		dragState.group.root.Visible = true

		if dropIndicator then
			dropIndicator:Destroy()
			dropIndicator = nil
		end
		screenGui:SetAttribute("IsDraggingGroupBox", false)

		normalizeGroupBoxOrders(targetColumn)

		if dragState.sourceParent ~= targetColumn then
			normalizeGroupBoxOrders(dragState.sourceParent)
		end

		dragState.active = false
		dragState.group = nil
		dragState.sourceParent = nil
		dragState.sourceSize = nil
		dragState.sourceAutomaticSize = nil
		dragState.startInputPosition = nil
		dragState.startAbsolutePosition = nil
		dragState.dragVisual = nil
	end

	local connectedGroupBoxes = {}

	local function registerGroupBox(groupBox)
		if not groupBox or connectedGroupBoxes[groupBox] then
			return groupBox
		end

		connectedGroupBoxes[groupBox] = true

		groupBox.titleBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				beginGroupBoxDrag(groupBox, input)
			end
		end)
	end

	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			updateGroupBoxDrag(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			endGroupBoxDrag()
		end
	end)

	return registerGroupBox
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- Dependency & Locked State Systems
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

local function applyDependency(controlTable, depConfig)
	if not depConfig then return end

	local function evaluate()
		local val
		if depConfig.control then
			val = depConfig.control.getValue()
		elseif depConfig.getValue then
			val = depConfig.getValue()
		end

		local visible = true
		if depConfig.condition then
			visible = depConfig.condition(val)
		else
			visible = val == true
		end

		controlTable.root.Visible = visible
	end

	-- Connect to control's onChange if available
	if depConfig.control and depConfig.control.onChange then
		depConfig.control.onChange(function()
			evaluate()
		end)
	end

	-- Connect to custom signal
	if depConfig.signal then
		depConfig.signal:Connect(function()
			evaluate()
		end)
	end

	-- Initial evaluation
	evaluate()
end

local function applyLocked(controlTable, lockConfig)
	if not lockConfig then return end

	local overlay = Instance.new("Frame")
	overlay.Name = "LockedOverlay"
	overlay.BackgroundColor3 = Theme.surface3
	overlay.BackgroundTransparency = 0.5
	overlay.BorderSizePixel = 0
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.ZIndex = 50
	overlay.Visible = false
	overlay.Parent = controlTable.root

	local overlayCorner = Instance.new("UICorner")
	overlayCorner.CornerRadius = UDim.new(0, px(8))
	overlayCorner.Parent = overlay

	-- Block clicks on the overlay
	local blocker = Instance.new("TextButton")
	blocker.Name = "Blocker"
	blocker.BackgroundTransparency = 1
	blocker.Text = ""
	blocker.Size = UDim2.fromScale(1, 1)
	blocker.ZIndex = 51
	blocker.Parent = overlay

	local function evaluate()
		local locked
		if type(lockConfig) == "function" then
			locked = lockConfig()
		else
			locked = lockConfig == true
		end
		overlay.Visible = locked
	end

	controlTable.setLocked = function(val)
		if type(lockConfig) ~= "function" then
			lockConfig = val
		end
		evaluate()
	end

	controlTable.isLocked = function()
		return overlay.Visible
	end

	evaluate()
end

local function createToggle(parent, text, defaultValue, options)
	options = options or {}
	local rowHeight = px(25)
	local switchWidth = px(34)
	local switchHeight = px(18)
	local knobSize = px(14)
	local horizontalInset = px(4)
	local labelInset = px(6)
	local value = defaultValue == true
	local tweenInfo = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local callbacks = {}
	local knobPadding = px(2)
	local knobYOffset = math.floor((switchHeight - knobSize) / 2)
	local knobOnPosition = UDim2.fromOffset(switchWidth - knobSize - knobPadding, knobYOffset)
	local knobOffPosition = UDim2.fromOffset(knobPadding, knobYOffset)

	local container = Instance.new("Frame")
	container.Name = text:gsub("%s+", "") .. "Toggle"
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Size = UDim2.new(1, 0, 0, rowHeight)
	container.Parent = parent

	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, px(8))
	containerCorner.Parent = container

	local containerStroke = Instance.new("UIStroke")
	containerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	containerStroke.Color = Theme.accent
	containerStroke.Thickness = px(2)
	containerStroke.Transparency = 1
	containerStroke.Parent = container

	local isHovered = false

	local function refreshHoverStroke()
		local owningScreenGui = container:FindFirstAncestorWhichIsA("ScreenGui")
		local isDraggingGroupBox = owningScreenGui and owningScreenGui:GetAttribute("IsDraggingGroupBox")
		containerStroke.Transparency = (isHovered and not isDraggingGroupBox) and 0 or 1
	end

	local hitbox = Instance.new("TextButton")
	hitbox.Name = "Hitbox"
	hitbox.BackgroundTransparency = 1
	hitbox.BorderSizePixel = 0
	hitbox.AutoButtonColor = false
	hitbox.Text = ""
	hitbox.Size = UDim2.fromScale(1, 1)
	hitbox.ZIndex = 1
	hitbox.Parent = container

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Position = UDim2.fromOffset(labelInset, 0)
	label.Size = UDim2.new(1, -(switchWidth + labelInset + px(8)), 1, 0)
	label.FontFace = NunitoBoldFace
	label.Text = text
	label.TextColor3 = Theme.textMain
	label.TextSize = px(14)
	label.TextStrokeTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.ZIndex = 2
	label.Parent = container

	local switchButton = Instance.new("TextButton")
	switchButton.Name = "Switch"
	switchButton.AnchorPoint = Vector2.new(1, 0.5)
	switchButton.AutoButtonColor = false
	switchButton.Text = ""
	switchButton.BackgroundColor3 = value and Theme.accent or Theme.surface6
	switchButton.BorderSizePixel = 0
	switchButton.Position = UDim2.new(1, -horizontalInset, 0.5, 0)
	switchButton.Size = UDim2.fromOffset(switchWidth, switchHeight)
	switchButton.ZIndex = 3
	switchButton.Parent = container

	local switchCorner = Instance.new("UICorner")
	switchCorner.CornerRadius = UDim.new(1, 0)
	switchCorner.Parent = switchButton

	local knob = Instance.new("Frame")
	knob.Name = "Knob"
	knob.AnchorPoint = Vector2.new(0, 0)
	knob.BackgroundColor3 = Theme.textMain
	knob.BorderSizePixel = 0
	knob.Position = value and knobOnPosition or knobOffPosition
	knob.Size = UDim2.fromOffset(knobSize, knobSize)
	knob.ZIndex = 4
	knob.Parent = switchButton

	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob

	local function renderToggle()
		local trackTween = TweenService:Create(switchButton, tweenInfo, {
			BackgroundColor3 = value and Theme.accent or Theme.surface6,
		})
		local knobTween = TweenService:Create(knob, tweenInfo, {
			Position = value and knobOnPosition or knobOffPosition,
		})
		trackTween:Play()
		knobTween:Play()
	end

	local function setHovered(nextHovered)
		isHovered = nextHovered
		refreshHoverStroke()
	end

	local function toggle()
		value = not value
		renderToggle()
		for _, cb in callbacks do
			task.spawn(cb, value)
		end
	end

	hitbox.MouseButton1Click:Connect(toggle)
	switchButton.MouseButton1Click:Connect(toggle)

	hitbox.MouseEnter:Connect(function()
		setHovered(true)
	end)

	hitbox.MouseLeave:Connect(function()
		setHovered(false)
	end)

	local owningScreenGui = container:FindFirstAncestorWhichIsA("ScreenGui")

	if owningScreenGui then
		owningScreenGui:GetAttributeChangedSignal("IsDraggingGroupBox"):Connect(refreshHoverStroke)
	end

	renderToggle()
	refreshHoverStroke()

	local api = {
		root = container,
		label = label,
		switch = switchButton,
		knob = knob,
		getValue = function()
			return value
		end,
		setValue = function(nextValue)
			value = nextValue == true
			renderToggle()
		end,
		onChange = function(callback)
			table.insert(callbacks, callback)
		end,
	}

	applyDependency(api, options.dependency)
	applyLocked(api, options.locked)

	return api
end

local function createCheckbox(parent, text, defaultValue, options)
	options = options or {}
	local rowHeight = px(25)
	local boxSize = px(16)
	local horizontalInset = px(4)
	local labelInset = px(6)
	local value = defaultValue == true
	local tweenInfo = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local callbacks = {}

	local container = Instance.new("Frame")
	container.Name = text:gsub("%s+", "") .. "Checkbox"
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Size = UDim2.new(1, 0, 0, rowHeight)
	container.Parent = parent

	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, px(8))
	containerCorner.Parent = container

	local containerStroke = Instance.new("UIStroke")
	containerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	containerStroke.Color = Theme.accent
	containerStroke.Thickness = px(2)
	containerStroke.Transparency = 1
	containerStroke.Parent = container

	local isHovered = false

	local function refreshHoverStroke()
		local owningScreenGui = container:FindFirstAncestorWhichIsA("ScreenGui")
		local isDraggingGroupBox = owningScreenGui and owningScreenGui:GetAttribute("IsDraggingGroupBox")
		containerStroke.Transparency = (isHovered and not isDraggingGroupBox) and 0 or 1
	end

	local hitbox = Instance.new("TextButton")
	hitbox.Name = "Hitbox"
	hitbox.BackgroundTransparency = 1
	hitbox.BorderSizePixel = 0
	hitbox.AutoButtonColor = false
	hitbox.Text = ""
	hitbox.Size = UDim2.fromScale(1, 1)
	hitbox.ZIndex = 1
	hitbox.Parent = container

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Position = UDim2.fromOffset(labelInset, 0)
	label.Size = UDim2.new(1, -(boxSize + labelInset + px(8)), 1, 0)
	label.FontFace = NunitoBoldFace
	label.Text = text
	label.TextColor3 = Theme.textMain
	label.TextSize = px(14)
	label.TextStrokeTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.ZIndex = 2
	label.Parent = container

	local box = Instance.new("TextButton")
	box.Name = "Box"
	box.AnchorPoint = Vector2.new(1, 0.5)
	box.AutoButtonColor = false
	box.Text = ""
	box.BackgroundColor3 = Theme.surface6
	box.BorderSizePixel = 0
	box.Position = UDim2.new(1, -horizontalInset, 0.5, 0)
	box.Size = UDim2.fromOffset(boxSize, boxSize)
	box.ZIndex = 3
	box.Parent = container

	local boxCorner = Instance.new("UICorner")
	boxCorner.CornerRadius = UDim.new(0, px(4))
	boxCorner.Parent = box

	box.ClipsDescendants = true

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.AnchorPoint = Vector2.new(0.5, 0.5)
	fill.BackgroundColor3 = Theme.accent
	fill.BorderSizePixel = 0
	fill.Position = UDim2.fromScale(0.5, 0.5)
	fill.Size = value and UDim2.fromOffset(boxSize, boxSize) or UDim2.fromOffset(0, 0)
	fill.ZIndex = 4
	fill.Parent = box

	local function renderCheckbox()
		local fillTween = TweenService:Create(fill, tweenInfo, {
			Size = value and UDim2.fromOffset(boxSize, boxSize) or UDim2.fromOffset(0, 0),
		})
		fillTween:Play()
	end

	local function setHovered(nextHovered)
		isHovered = nextHovered
		refreshHoverStroke()
	end

	local function toggle()
		value = not value
		renderCheckbox()
		for _, cb in callbacks do
			task.spawn(cb, value)
		end
	end

	hitbox.MouseButton1Click:Connect(toggle)
	box.MouseButton1Click:Connect(toggle)

	hitbox.MouseEnter:Connect(function()
		setHovered(true)
	end)

	hitbox.MouseLeave:Connect(function()
		setHovered(false)
	end)

	local owningScreenGui = container:FindFirstAncestorWhichIsA("ScreenGui")

	if owningScreenGui then
		owningScreenGui:GetAttributeChangedSignal("IsDraggingGroupBox"):Connect(refreshHoverStroke)
	end

	renderCheckbox()
	refreshHoverStroke()

	local api = {
		root = container,
		label = label,
		box = box,
		fill = fill,
		getValue = function()
			return value
		end,
		setValue = function(nextValue)
			value = nextValue == true
			renderCheckbox()
		end,
		onChange = function(callback)
			table.insert(callbacks, callback)
		end,
	}

	applyDependency(api, options.dependency)
	applyLocked(api, options.locked)

	return api
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- Label
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

local function createLabel(parent, text, options)
	options = options or {}
	local rowHeight = px(20)

	local container = Instance.new("Frame")
	container.Name = "Label"
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Size = UDim2.new(1, 0, 0, rowHeight)
	container.Parent = parent

	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Position = UDim2.fromOffset(px(6), 0)
	label.Size = UDim2.new(1, -px(12), 1, 0)
	label.FontFace = NunitoBoldFace
	label.Text = text
	label.TextColor3 = options.color or Theme.textSecondary
	label.TextSize = px(13)
	label.TextStrokeTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.ZIndex = 2
	label.Parent = container

	local api = {
		root = container,
		label = label,
		getValue = function() return label.Text end,
		setValue = function(v) label.Text = v end,
		onChange = function() end,
	}

	applyDependency(api, options.dependency)
	applyLocked(api, options.locked)

	return api
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- Wrapping Label
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

local function createWrappingLabel(parent, text, options)
	options = options or {}

	local container = Instance.new("Frame")
	container.Name = "WrappingLabel"
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Size = UDim2.new(1, 0, 0, 0)
	container.AutomaticSize = Enum.AutomaticSize.Y
	container.Parent = parent

	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Position = UDim2.fromOffset(px(6), px(2))
	label.Size = UDim2.new(1, -px(12), 0, 0)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.FontFace = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	label.Text = text
	label.TextColor3 = options.color or Theme.textTertiary
	label.TextSize = px(12)
	label.TextStrokeTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.TextWrapped = true
	label.RichText = true
	label.ZIndex = 2
	label.Parent = container

	local bottomPad = Instance.new("UIPadding")
	bottomPad.PaddingBottom = UDim.new(0, px(2))
	bottomPad.Parent = container

	local api = {
		root = container,
		label = label,
		getValue = function() return label.Text end,
		setValue = function(v) label.Text = v end,
		onChange = function() end,
	}

	applyDependency(api, options.dependency)
	applyLocked(api, options.locked)

	return api
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- Divider
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

local function createDivider(parent, options)
	options = options or {}

	local container = Instance.new("Frame")
	container.Name = "Divider"
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Size = UDim2.new(1, 0, 0, px(9))
	container.Parent = parent

	local line = Instance.new("Frame")
	line.Name = "Line"
	line.BackgroundColor3 = Theme.surface5
	line.BorderSizePixel = 0
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.Position = UDim2.new(0.5, 0, 0.5, 0)
	line.Size = UDim2.new(1, -px(8), 0, px(1))
	line.ZIndex = 2
	line.Parent = container

	local api = {
		root = container,
		getValue = function() return nil end,
		setValue = function() end,
		onChange = function() end,
	}

	applyDependency(api, options.dependency)

	return api
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- Text Input (base for all input variants)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

local function createBaseInput(parent, text, defaultValue, options)
	options = options or {}
	local rowHeight = px(25)
	local inputWidth = options.inputWidth or px(80)
	local horizontalInset = px(4)
	local labelInset = px(6)
	local value = defaultValue or ""
	local tweenInfo = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local callbacks = {}

	local container = Instance.new("Frame")
	container.Name = text:gsub("%s+", "") .. "Input"
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Size = UDim2.new(1, 0, 0, rowHeight)
	container.Parent = parent

	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, px(8))
	containerCorner.Parent = container

	local containerStroke = Instance.new("UIStroke")
	containerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	containerStroke.Color = Theme.accent
	containerStroke.Thickness = px(2)
	containerStroke.Transparency = 1
	containerStroke.Parent = container

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Position = UDim2.fromOffset(labelInset, 0)
	label.Size = UDim2.new(1, -(inputWidth + labelInset + px(8)), 1, 0)
	label.FontFace = NunitoBoldFace
	label.Text = text
	label.TextColor3 = Theme.textMain
	label.TextSize = px(14)
	label.TextStrokeTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.ZIndex = 2
	label.Parent = container

	local inputBg = Instance.new("Frame")
	inputBg.Name = "InputBg"
	inputBg.AnchorPoint = Vector2.new(1, 0.5)
	inputBg.BackgroundColor3 = Theme.surface5
	inputBg.BorderSizePixel = 0
	inputBg.Position = UDim2.new(1, -horizontalInset, 0.5, 0)
	inputBg.Size = UDim2.fromOffset(inputWidth, px(19))
	inputBg.ZIndex = 3
	inputBg.Parent = container

	local inputBgCorner = Instance.new("UICorner")
	inputBgCorner.CornerRadius = UDim.new(0, px(5))
	inputBgCorner.Parent = inputBg

	local textBox = Instance.new("TextBox")
	textBox.Name = "TextBox"
	textBox.BackgroundTransparency = 1
	textBox.BorderSizePixel = 0
	textBox.Size = UDim2.new(1, -px(8), 1, 0)
	textBox.Position = UDim2.fromOffset(px(4), 0)
	textBox.FontFace = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
	textBox.Text = tostring(value)
	textBox.TextColor3 = Theme.textMain
	textBox.PlaceholderText = options.placeholder or ""
	textBox.PlaceholderColor3 = Theme.textMuted
	textBox.TextSize = px(12)
	textBox.TextXAlignment = Enum.TextXAlignment.Left
	textBox.TextYAlignment = Enum.TextYAlignment.Center
	textBox.ClearTextOnFocus = false
	textBox.ClipsDescendants = true
	textBox.ZIndex = 4
	textBox.Parent = inputBg

	local isHovered = false

	local function refreshHoverStroke()
		local owningScreenGui = container:FindFirstAncestorWhichIsA("ScreenGui")
		local isDraggingGroupBox = owningScreenGui and owningScreenGui:GetAttribute("IsDraggingGroupBox")
		containerStroke.Transparency = (isHovered and not isDraggingGroupBox) and 0 or 1
	end

	container.MouseEnter:Connect(function()
		isHovered = true
		refreshHoverStroke()
	end)

	container.MouseLeave:Connect(function()
		isHovered = false
		refreshHoverStroke()
	end)

	-- Focus effects
	textBox.Focused:Connect(function()
		TweenService:Create(inputBg, tweenInfo, {
			BackgroundColor3 = Theme.surface6,
		}):Play()
	end)

	textBox.FocusLost:Connect(function()
		TweenService:Create(inputBg, tweenInfo, {
			BackgroundColor3 = Theme.surface5,
		}):Play()
	end)

	return {
		container = container,
		containerStroke = containerStroke,
		label = label,
		inputBg = inputBg,
		textBox = textBox,
		callbacks = callbacks,
		refreshHoverStroke = refreshHoverStroke,
	}
end

local function createTextInput(parent, text, defaultValue, options)
	options = options or {}
	local base = createBaseInput(parent, text, defaultValue, options)
	local value = defaultValue or ""

	base.textBox.FocusLost:Connect(function()
		value = base.textBox.Text
		for _, cb in base.callbacks do
			task.spawn(cb, value)
		end
	end)

	local api = {
		root = base.container,
		label = base.label,
		textBox = base.textBox,
		getValue = function() return value end,
		setValue = function(v)
			value = tostring(v)
			base.textBox.Text = value
		end,
		onChange = function(callback)
			table.insert(base.callbacks, callback)
		end,
	}

	applyDependency(api, options.dependency)
	applyLocked(api, options.locked)

	return api
end

local function createNumberInput(parent, text, defaultValue, options)
	options = options or {}
	local min = options.min or -math.huge
	local max = options.max or math.huge
	local base = createBaseInput(parent, text, tostring(defaultValue or 0), options)
	local value = math.clamp(defaultValue or 0, min, max)

	base.textBox.Text = tostring(value)

	base.textBox.FocusLost:Connect(function()
		local num = tonumber(base.textBox.Text)
		if num then
			value = math.clamp(num, min, max)
		end
		base.textBox.Text = tostring(value)
		for _, cb in base.callbacks do
			task.spawn(cb, value)
		end
	end)

	local api = {
		root = base.container,
		label = base.label,
		textBox = base.textBox,
		getValue = function() return value end,
		setValue = function(v)
			value = math.clamp(tonumber(v) or 0, min, max)
			base.textBox.Text = tostring(value)
		end,
		onChange = function(callback)
			table.insert(base.callbacks, callback)
		end,
	}

	applyDependency(api, options.dependency)
	applyLocked(api, options.locked)

	return api
end

local function createPasswordInput(parent, text, defaultValue, options)
	options = options or {}
	local base = createBaseInput(parent, text, "", options)
	local value = defaultValue or ""
	local showPassword = false

	local function updateDisplay()
		base.textBox.Text = showPassword and value or string.rep("â—", #value)
	end

	updateDisplay()

	base.textBox.Focused:Connect(function()
		base.textBox.Text = value
	end)

	base.textBox.FocusLost:Connect(function()
		value = base.textBox.Text
		updateDisplay()
		for _, cb in base.callbacks do
			task.spawn(cb, value)
		end
	end)

	local api = {
		root = base.container,
		label = base.label,
		textBox = base.textBox,
		getValue = function() return value end,
		setValue = function(v)
			value = tostring(v)
			updateDisplay()
		end,
		onChange = function(callback)
			table.insert(base.callbacks, callback)
		end,
		toggleVisibility = function()
			showPassword = not showPassword
			updateDisplay()
		end,
	}

	applyDependency(api, options.dependency)
	applyLocked(api, options.locked)

	return api
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- KeyPicker
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

local function createKeyPicker(parent, text, defaultKey, options)
	options = options or {}
	local rowHeight = px(25)
	local btnWidth = px(70)
	local horizontalInset = px(4)
	local labelInset = px(6)
	local currentKey = defaultKey -- Enum.KeyCode value or nil
	local listening = false
	local tweenInfo = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local callbacks = {}

	local container = Instance.new("Frame")
	container.Name = text:gsub("%s+", "") .. "KeyPicker"
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Size = UDim2.new(1, 0, 0, rowHeight)
	container.Parent = parent

	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, px(8))
	containerCorner.Parent = container

	local containerStroke = Instance.new("UIStroke")
	containerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	containerStroke.Color = Theme.accent
	containerStroke.Thickness = px(2)
	containerStroke.Transparency = 1
	containerStroke.Parent = container

	local isHovered = false

	local function refreshHoverStroke()
		local owningScreenGui = container:FindFirstAncestorWhichIsA("ScreenGui")
		local isDraggingGroupBox = owningScreenGui and owningScreenGui:GetAttribute("IsDraggingGroupBox")
		containerStroke.Transparency = (isHovered and not isDraggingGroupBox) and 0 or 1
	end

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Position = UDim2.fromOffset(labelInset, 0)
	label.Size = UDim2.new(1, -(btnWidth + labelInset + px(8)), 1, 0)
	label.FontFace = NunitoBoldFace
	label.Text = text
	label.TextColor3 = Theme.textMain
	label.TextSize = px(14)
	label.TextStrokeTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.ZIndex = 2
	label.Parent = container

	local keyBtn = Instance.new("TextButton")
	keyBtn.Name = "KeyButton"
	keyBtn.AnchorPoint = Vector2.new(1, 0.5)
	keyBtn.AutoButtonColor = false
	keyBtn.BackgroundColor3 = Theme.surface5
	keyBtn.BorderSizePixel = 0
	keyBtn.Position = UDim2.new(1, -horizontalInset, 0.5, 0)
	keyBtn.Size = UDim2.fromOffset(btnWidth, px(19))
	keyBtn.ZIndex = 3
	keyBtn.Parent = container

	local keyBtnCorner = Instance.new("UICorner")
	keyBtnCorner.CornerRadius = UDim.new(0, px(5))
	keyBtnCorner.Parent = keyBtn

	local keyLabel = Instance.new("TextLabel")
	keyLabel.Name = "KeyLabel"
	keyLabel.BackgroundTransparency = 1
	keyLabel.Size = UDim2.fromScale(1, 1)
	keyLabel.FontFace = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
	keyLabel.Text = currentKey and currentKey.Name or "None"
	keyLabel.TextColor3 = currentKey and Theme.textMain or Theme.textMuted
	keyLabel.TextSize = px(12)
	keyLabel.ZIndex = 4
	keyLabel.Parent = keyBtn

	local function updateDisplay()
		if listening then
			keyLabel.Text = "..."
			keyLabel.TextColor3 = Theme.accent
			keyBtn.BackgroundColor3 = Theme.accentSurface
		else
			keyLabel.Text = currentKey and currentKey.Name or "None"
			keyLabel.TextColor3 = currentKey and Theme.textMain or Theme.textMuted
			keyBtn.BackgroundColor3 = Theme.surface5
		end
	end

	local inputConn = nil

	local function startListening()
		listening = true
		updateDisplay()

		inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.Escape then
					-- Cancel - don't change
				else
					currentKey = input.KeyCode
				end

				listening = false
				updateDisplay()

				if inputConn then
					inputConn:Disconnect()
					inputConn = nil
				end

				for _, cb in callbacks do
					task.spawn(cb, currentKey)
				end
			end
		end)
	end

	keyBtn.MouseButton1Click:Connect(function()
		if not listening then
			startListening()
		end
	end)

	-- Right click clears
	keyBtn.MouseButton2Click:Connect(function()
		currentKey = nil
		listening = false
		updateDisplay()
		if inputConn then
			inputConn:Disconnect()
			inputConn = nil
		end
		for _, cb in callbacks do
			task.spawn(cb, currentKey)
		end
	end)

	container.MouseEnter:Connect(function()
		isHovered = true
		refreshHoverStroke()
	end)

	container.MouseLeave:Connect(function()
		isHovered = false
		refreshHoverStroke()
	end)

	local api = {
		root = container,
		label = label,
		getValue = function() return currentKey end,
		setValue = function(key)
			currentKey = key
			updateDisplay()
		end,
		onChange = function(callback)
			table.insert(callbacks, callback)
		end,
	}

	applyDependency(api, options.dependency)
	applyLocked(api, options.locked)

	return api
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- Dropdown (Single Select)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

local function createDropdown(parent, text, items, defaultItem, options)
	options = options or {}
	local rowHeight = px(25)
	local dropdownWidth = options.dropdownWidth or px(90)
	local horizontalInset = px(4)
	local labelInset = px(6)
	local itemHeight = px(22)
	local selected = defaultItem or items[1]
	local isOpen = false
	local tweenInfo = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local callbacks = {}

	local container = Instance.new("Frame")
	container.Name = text:gsub("%s+", "") .. "Dropdown"
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Size = UDim2.new(1, 0, 0, rowHeight)
	container.ClipsDescendants = false
	container.Parent = parent

	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, px(8))
	containerCorner.Parent = container

	local containerStroke = Instance.new("UIStroke")
	containerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	containerStroke.Color = Theme.accent
	containerStroke.Thickness = px(2)
	containerStroke.Transparency = 1
	containerStroke.Parent = container

	local isHovered = false

	local function refreshHoverStroke()
		local owningScreenGui = container:FindFirstAncestorWhichIsA("ScreenGui")
		local isDraggingGroupBox = owningScreenGui and owningScreenGui:GetAttribute("IsDraggingGroupBox")
		containerStroke.Transparency = (isHovered and not isDraggingGroupBox) and 0 or 1
	end

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Position = UDim2.fromOffset(labelInset, 0)
	label.Size = UDim2.new(1, -(dropdownWidth + labelInset + px(8)), 1, 0)
	label.FontFace = NunitoBoldFace
	label.Text = text
	label.TextColor3 = Theme.textMain
	label.TextSize = px(14)
	label.TextStrokeTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.ZIndex = 2
	label.Parent = container

	local dropBtn = Instance.new("TextButton")
	dropBtn.Name = "DropButton"
	dropBtn.AnchorPoint = Vector2.new(1, 0.5)
	dropBtn.AutoButtonColor = false
	dropBtn.Text = ""
	dropBtn.BackgroundColor3 = Theme.surface5
	dropBtn.BorderSizePixel = 0
	dropBtn.Position = UDim2.new(1, -horizontalInset, 0.5, 0)
	dropBtn.Size = UDim2.fromOffset(dropdownWidth, px(19))
	dropBtn.ZIndex = 3
	dropBtn.Parent = container

	local dropBtnCorner = Instance.new("UICorner")
	dropBtnCorner.CornerRadius = UDim.new(0, px(5))
	dropBtnCorner.Parent = dropBtn

	local dropLabel = Instance.new("TextLabel")
	dropLabel.Name = "SelectedLabel"
	dropLabel.BackgroundTransparency = 1
	dropLabel.Size = UDim2.new(1, -px(16), 1, 0)
	dropLabel.Position = UDim2.fromOffset(px(6), 0)
	dropLabel.FontFace = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
	dropLabel.Text = selected
	dropLabel.TextColor3 = Theme.textMain
	dropLabel.TextSize = px(12)
	dropLabel.TextXAlignment = Enum.TextXAlignment.Left
	dropLabel.TextTruncate = Enum.TextTruncate.AtEnd
	dropLabel.ZIndex = 4
	dropLabel.Parent = dropBtn

	-- Chevron (+/-)
	local chevron = Instance.new("TextLabel")
	chevron.Name = "Chevron"
	chevron.BackgroundTransparency = 1
	chevron.AnchorPoint = Vector2.new(1, 0.5)
	chevron.Position = UDim2.new(1, -px(4), 0.5, 0)
	chevron.Size = UDim2.fromOffset(px(10), px(10))
	chevron.FontFace = NunitoBoldFace
	chevron.Text = "+"
	chevron.TextColor3 = Theme.textMuted
	chevron.TextSize = px(12)
	chevron.ZIndex = 4
	chevron.Parent = dropBtn

	-- Dropdown list (parented to ScreenGui to avoid ScrollingFrame clipping)
	local dropList = Instance.new("Frame")
	dropList.Name = "DropdownList_" .. text:gsub("%s+", "")
	dropList.BackgroundColor3 = Theme.surface4
	dropList.BorderSizePixel = 0
	dropList.Size = UDim2.fromOffset(dropdownWidth, #items * itemHeight + px(4))
	dropList.ZIndex = 10000
	dropList.Visible = false
	dropList.ClipsDescendants = true

	local dropListCorner = Instance.new("UICorner")
	dropListCorner.CornerRadius = UDim.new(0, px(6))
	dropListCorner.Parent = dropList

	local dropListStroke = Instance.new("UIStroke")
	dropListStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	dropListStroke.Color = Theme.surface6
	dropListStroke.Thickness = px(1)
	dropListStroke.Parent = dropList

	local dropListLayout = Instance.new("UIListLayout")
	dropListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	dropListLayout.Padding = UDim.new(0, 0)
	dropListLayout.Parent = dropList

	local dropListPadding = Instance.new("UIPadding")
	dropListPadding.PaddingTop = UDim.new(0, px(2))
	dropListPadding.PaddingBottom = UDim.new(0, px(2))
	dropListPadding.Parent = dropList

	-- Deferred parenting: attach to ScreenGui once available
	local function ensureDropListParented()
		if dropList.Parent then return end
		local sg = container:FindFirstAncestorWhichIsA("ScreenGui")
		if sg then
			dropList.Parent = sg
		end
	end

	local function positionDropList()
		local absPos = dropBtn.AbsolutePosition
		local absSize = dropBtn.AbsoluteSize
		dropList.Position = UDim2.fromOffset(
			absPos.X + absSize.X - dropdownWidth,
			absPos.Y + absSize.Y + px(2)
		)
	end

	local function closeDropdown()
		isOpen = false
		dropList.Visible = false
		chevron.Text = "+"
	end

	for _, item in ipairs(items) do
		local itemBtn = Instance.new("TextButton")
		itemBtn.Name = item
		itemBtn.AutoButtonColor = false
		itemBtn.Text = ""
		itemBtn.BackgroundColor3 = Theme.surface4
		itemBtn.BackgroundTransparency = 1
		itemBtn.BorderSizePixel = 0
		itemBtn.Size = UDim2.new(1, 0, 0, itemHeight)
		itemBtn.ZIndex = 10001
		itemBtn.Parent = dropList

		local itemLabel = Instance.new("TextLabel")
		itemLabel.BackgroundTransparency = 1
		itemLabel.Size = UDim2.new(1, -px(12), 1, 0)
		itemLabel.Position = UDim2.fromOffset(px(6), 0)
		itemLabel.FontFace = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
		itemLabel.Text = item
		itemLabel.TextColor3 = Theme.textMain
		itemLabel.TextSize = px(12)
		itemLabel.TextXAlignment = Enum.TextXAlignment.Left
		itemLabel.ZIndex = 10002
		itemLabel.Parent = itemBtn

		itemBtn.MouseEnter:Connect(function()
			itemBtn.BackgroundTransparency = 0
			itemBtn.BackgroundColor3 = Theme.surface6
		end)

		itemBtn.MouseLeave:Connect(function()
			itemBtn.BackgroundTransparency = 1
		end)

		itemBtn.MouseButton1Click:Connect(function()
			selected = item
			dropLabel.Text = selected
			closeDropdown()
			for _, cb in callbacks do
				task.spawn(cb, selected)
			end
		end)
	end

	dropBtn.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		if isOpen then
			ensureDropListParented()
			positionDropList()
		end
		dropList.Visible = isOpen
		chevron.Text = isOpen and "-" or "+"
	end)

	container.MouseEnter:Connect(function()
		isHovered = true
		refreshHoverStroke()
	end)

	container.MouseLeave:Connect(function()
		isHovered = false
		refreshHoverStroke()
	end)

	local api = {
		root = container,
		label = label,
		getValue = function() return selected end,
		setValue = function(v)
			if table.find(items, v) then
				selected = v
				dropLabel.Text = selected
			end
		end,
		onChange = function(callback)
			table.insert(callbacks, callback)
		end,
	}

	applyDependency(api, options.dependency)
	applyLocked(api, options.locked)

	return api
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- Multi-Select Dropdown
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

local function createMultiDropdown(parent, text, items, defaultItems, options)
	options = options or {}
	local rowHeight = px(25)
	local dropdownWidth = options.dropdownWidth or px(90)
	local horizontalInset = px(4)
	local labelInset = px(6)
	local itemHeight = px(22)
	local selected = {}
	local isOpen = false
	local tweenInfo = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local callbacks = {}

	-- Init defaults
	if defaultItems then
		for _, v in ipairs(defaultItems) do
			selected[v] = true
		end
	end

	local container = Instance.new("Frame")
	container.Name = text:gsub("%s+", "") .. "MultiDropdown"
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Size = UDim2.new(1, 0, 0, rowHeight)
	container.ClipsDescendants = false
	container.Parent = parent

	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, px(8))
	containerCorner.Parent = container

	local containerStroke = Instance.new("UIStroke")
	containerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	containerStroke.Color = Theme.accent
	containerStroke.Thickness = px(2)
	containerStroke.Transparency = 1
	containerStroke.Parent = container

	local isHovered = false

	local function refreshHoverStroke()
		local owningScreenGui = container:FindFirstAncestorWhichIsA("ScreenGui")
		local isDraggingGroupBox = owningScreenGui and owningScreenGui:GetAttribute("IsDraggingGroupBox")
		containerStroke.Transparency = (isHovered and not isDraggingGroupBox) and 0 or 1
	end

	local function getDisplayText()
		local sel = {}
		for _, item in ipairs(items) do
			if selected[item] then
				table.insert(sel, item)
			end
		end
		if #sel == 0 then return "None" end
		if #sel <= 2 then return table.concat(sel, ", ") end
		return #sel .. " selected"
	end

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Position = UDim2.fromOffset(labelInset, 0)
	label.Size = UDim2.new(1, -(dropdownWidth + labelInset + px(8)), 1, 0)
	label.FontFace = NunitoBoldFace
	label.Text = text
	label.TextColor3 = Theme.textMain
	label.TextSize = px(14)
	label.TextStrokeTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.ZIndex = 2
	label.Parent = container

	local dropBtn = Instance.new("TextButton")
	dropBtn.Name = "DropButton"
	dropBtn.AnchorPoint = Vector2.new(1, 0.5)
	dropBtn.AutoButtonColor = false
	dropBtn.Text = ""
	dropBtn.BackgroundColor3 = Theme.surface5
	dropBtn.BorderSizePixel = 0
	dropBtn.Position = UDim2.new(1, -horizontalInset, 0.5, 0)
	dropBtn.Size = UDim2.fromOffset(dropdownWidth, px(19))
	dropBtn.ZIndex = 3
	dropBtn.Parent = container

	local dropBtnCorner = Instance.new("UICorner")
	dropBtnCorner.CornerRadius = UDim.new(0, px(5))
	dropBtnCorner.Parent = dropBtn

	local dropLabel = Instance.new("TextLabel")
	dropLabel.Name = "SelectedLabel"
	dropLabel.BackgroundTransparency = 1
	dropLabel.Size = UDim2.new(1, -px(16), 1, 0)
	dropLabel.Position = UDim2.fromOffset(px(6), 0)
	dropLabel.FontFace = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
	dropLabel.Text = getDisplayText()
	dropLabel.TextColor3 = Theme.textMain
	dropLabel.TextSize = px(12)
	dropLabel.TextXAlignment = Enum.TextXAlignment.Left
	dropLabel.TextTruncate = Enum.TextTruncate.AtEnd
	dropLabel.ZIndex = 4
	dropLabel.Parent = dropBtn

	local chevron = Instance.new("TextLabel")
	chevron.Name = "Chevron"
	chevron.BackgroundTransparency = 1
	chevron.AnchorPoint = Vector2.new(1, 0.5)
	chevron.Position = UDim2.new(1, -px(4), 0.5, 0)
	chevron.Size = UDim2.fromOffset(px(10), px(10))
	chevron.FontFace = NunitoBoldFace
	chevron.Text = "+"
	chevron.TextColor3 = Theme.textMuted
	chevron.TextSize = px(12)
	chevron.ZIndex = 4
	chevron.Parent = dropBtn

	-- Dropdown list (parented to ScreenGui to avoid ScrollingFrame clipping)
	local dropList = Instance.new("Frame")
	dropList.Name = "DropdownList_" .. text:gsub("%s+", "")
	dropList.BackgroundColor3 = Theme.surface4
	dropList.BorderSizePixel = 0
	dropList.Size = UDim2.fromOffset(dropdownWidth, #items * itemHeight + px(4))
	dropList.ZIndex = 10000
	dropList.Visible = false
	dropList.ClipsDescendants = true

	local dropListCorner = Instance.new("UICorner")
	dropListCorner.CornerRadius = UDim.new(0, px(6))
	dropListCorner.Parent = dropList

	local dropListStroke = Instance.new("UIStroke")
	dropListStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	dropListStroke.Color = Theme.surface6
	dropListStroke.Thickness = px(1)
	dropListStroke.Parent = dropList

	local dropListLayout = Instance.new("UIListLayout")
	dropListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	dropListLayout.Padding = UDim.new(0, 0)
	dropListLayout.Parent = dropList

	local dropListPadding = Instance.new("UIPadding")
	dropListPadding.PaddingTop = UDim.new(0, px(2))
	dropListPadding.PaddingBottom = UDim.new(0, px(2))
	dropListPadding.Parent = dropList

	local function ensureDropListParented()
		if dropList.Parent then return end
		local sg = container:FindFirstAncestorWhichIsA("ScreenGui")
		if sg then
			dropList.Parent = sg
		end
	end

	local function positionDropList()
		local absPos = dropBtn.AbsolutePosition
		local absSize = dropBtn.AbsoluteSize
		dropList.Position = UDim2.fromOffset(
			absPos.X + absSize.X - dropdownWidth,
			absPos.Y + absSize.Y + px(2)
		)
	end

	local itemCheckmarks = {}

	for _, item in ipairs(items) do
		local itemBtn = Instance.new("TextButton")
		itemBtn.Name = item
		itemBtn.AutoButtonColor = false
		itemBtn.Text = ""
		itemBtn.BackgroundTransparency = 1
		itemBtn.BackgroundColor3 = Theme.surface6
		itemBtn.BorderSizePixel = 0
		itemBtn.Size = UDim2.new(1, 0, 0, itemHeight)
		itemBtn.ZIndex = 10001
		itemBtn.Parent = dropList

		local checkMark = Instance.new("Frame")
		checkMark.Name = "Check"
		checkMark.AnchorPoint = Vector2.new(0, 0.5)
		checkMark.BackgroundColor3 = selected[item] and Theme.accent or Theme.surface6
		checkMark.BorderSizePixel = 0
		checkMark.Position = UDim2.new(0, px(6), 0.5, 0)
		checkMark.Size = UDim2.fromOffset(px(10), px(10))
		checkMark.ZIndex = 10002
		checkMark.Parent = itemBtn

		local checkCorner = Instance.new("UICorner")
		checkCorner.CornerRadius = UDim.new(0, px(2))
		checkCorner.Parent = checkMark

		itemCheckmarks[item] = checkMark

		local itemLabel = Instance.new("TextLabel")
		itemLabel.BackgroundTransparency = 1
		itemLabel.Size = UDim2.new(1, -px(24), 1, 0)
		itemLabel.Position = UDim2.fromOffset(px(20), 0)
		itemLabel.FontFace = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
		itemLabel.Text = item
		itemLabel.TextColor3 = Theme.textMain
		itemLabel.TextSize = px(12)
		itemLabel.TextXAlignment = Enum.TextXAlignment.Left
		itemLabel.ZIndex = 10002
		itemLabel.Parent = itemBtn

		itemBtn.MouseEnter:Connect(function()
			itemBtn.BackgroundTransparency = 0
		end)

		itemBtn.MouseLeave:Connect(function()
			itemBtn.BackgroundTransparency = 1
		end)

		itemBtn.MouseButton1Click:Connect(function()
			selected[item] = not selected[item]
			checkMark.BackgroundColor3 = selected[item] and Theme.accent or Theme.surface6
			dropLabel.Text = getDisplayText()
			for _, cb in callbacks do
				task.spawn(cb, selected)
			end
		end)
	end

	dropBtn.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		if isOpen then
			ensureDropListParented()
			positionDropList()
		end
		dropList.Visible = isOpen
		chevron.Text = isOpen and "-" or "+"
	end)

	container.MouseEnter:Connect(function()
		isHovered = true
		refreshHoverStroke()
	end)

	container.MouseLeave:Connect(function()
		isHovered = false
		refreshHoverStroke()
	end)

	local api = {
		root = container,
		label = label,
		getValue = function()
			local result = {}
			for _, item in ipairs(items) do
				if selected[item] then
					table.insert(result, item)
				end
			end
			return result
		end,
		setValue = function(vals)
			selected = {}
			for _, v in ipairs(vals) do
				selected[v] = true
			end
			dropLabel.Text = getDisplayText()
			for item, cm in pairs(itemCheckmarks) do
				cm.BackgroundColor3 = selected[item] and Theme.accent or Theme.surface6
			end
		end,
		onChange = function(callback)
			table.insert(callbacks, callback)
		end,
	}

	applyDependency(api, options.dependency)
	applyLocked(api, options.locked)

	return api
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- Full-Width Dropdown (label above, button spans full width)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

local function createFullWidthDropdown(parent, text, items, defaultItem, options)
	options = options or {}
	local labelHeight = px(18)
	local btnHeight = px(22)
	local totalHeight = labelHeight + px(2) + btnHeight
	local horizontalInset = px(4)
	local labelInset = px(6)
	local itemHeight = px(22)
	local selected = defaultItem or items[1]
	local isOpen = false
	local callbacks = {}

	local container = Instance.new("Frame")
	container.Name = text:gsub("%s+", "") .. "FullDropdown"
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Size = UDim2.new(1, 0, 0, totalHeight)
	container.ClipsDescendants = false
	container.Parent = parent

	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, px(8))
	containerCorner.Parent = container

	local containerStroke = Instance.new("UIStroke")
	containerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	containerStroke.Color = Theme.accent
	containerStroke.Thickness = px(2)
	containerStroke.Transparency = 1
	containerStroke.Parent = container

	local isHovered = false

	local function refreshHoverStroke()
		local owningScreenGui = container:FindFirstAncestorWhichIsA("ScreenGui")
		local isDraggingGroupBox = owningScreenGui and owningScreenGui:GetAttribute("IsDraggingGroupBox")
		containerStroke.Transparency = (isHovered and not isDraggingGroupBox) and 0 or 1
	end

	-- Label on top
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Position = UDim2.fromOffset(labelInset, 0)
	label.Size = UDim2.new(1, -labelInset * 2, 0, labelHeight)
	label.FontFace = NunitoBoldFace
	label.Text = text
	label.TextColor3 = Theme.textMain
	label.TextSize = px(13)
	label.TextStrokeTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.ZIndex = 2
	label.Parent = container

	-- Full-width drop button
	local dropBtn = Instance.new("TextButton")
	dropBtn.Name = "DropButton"
	dropBtn.AutoButtonColor = false
	dropBtn.Text = ""
	dropBtn.BackgroundColor3 = Theme.surface5
	dropBtn.BorderSizePixel = 0
	dropBtn.Position = UDim2.fromOffset(horizontalInset, labelHeight + px(2))
	dropBtn.Size = UDim2.new(1, -horizontalInset * 2, 0, btnHeight)
	dropBtn.ZIndex = 3
	dropBtn.Parent = container

	local dropBtnCorner = Instance.new("UICorner")
	dropBtnCorner.CornerRadius = UDim.new(0, px(5))
	dropBtnCorner.Parent = dropBtn

	local dropLabel = Instance.new("TextLabel")
	dropLabel.Name = "SelectedLabel"
	dropLabel.BackgroundTransparency = 1
	dropLabel.Size = UDim2.new(1, -px(20), 1, 0)
	dropLabel.Position = UDim2.fromOffset(px(6), 0)
	dropLabel.FontFace = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
	dropLabel.Text = selected
	dropLabel.TextColor3 = Theme.textMain
	dropLabel.TextSize = px(12)
	dropLabel.TextXAlignment = Enum.TextXAlignment.Left
	dropLabel.TextTruncate = Enum.TextTruncate.AtEnd
	dropLabel.ZIndex = 4
	dropLabel.Parent = dropBtn

	local chevron = Instance.new("TextLabel")
	chevron.Name = "Chevron"
	chevron.BackgroundTransparency = 1
	chevron.AnchorPoint = Vector2.new(1, 0.5)
	chevron.Position = UDim2.new(1, -px(4), 0.5, 0)
	chevron.Size = UDim2.fromOffset(px(10), px(10))
	chevron.FontFace = NunitoBoldFace
	chevron.Text = "+"
	chevron.TextColor3 = Theme.textMuted
	chevron.TextSize = px(12)
	chevron.ZIndex = 4
	chevron.Parent = dropBtn

	-- Dropdown list (parented to ScreenGui to avoid ScrollingFrame clipping)
	local dropList = Instance.new("Frame")
	dropList.Name = "DropdownList_" .. text:gsub("%s+", "")
	dropList.BackgroundColor3 = Theme.surface4
	dropList.BorderSizePixel = 0
	dropList.ZIndex = 10000
	dropList.Visible = false
	dropList.ClipsDescendants = true

	local dropListCorner = Instance.new("UICorner")
	dropListCorner.CornerRadius = UDim.new(0, px(6))
	dropListCorner.Parent = dropList

	local dropListStroke = Instance.new("UIStroke")
	dropListStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	dropListStroke.Color = Theme.surface6
	dropListStroke.Thickness = px(1)
	dropListStroke.Parent = dropList

	local dropListLayout = Instance.new("UIListLayout")
	dropListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	dropListLayout.Padding = UDim.new(0, 0)
	dropListLayout.Parent = dropList

	local dropListPadding = Instance.new("UIPadding")
	dropListPadding.PaddingTop = UDim.new(0, px(2))
	dropListPadding.PaddingBottom = UDim.new(0, px(2))
	dropListPadding.Parent = dropList

	local function ensureDropListParented()
		if dropList.Parent then return end
		local sg = container:FindFirstAncestorWhichIsA("ScreenGui")
		if sg then
			dropList.Parent = sg
		end
	end

	local function positionDropList()
		local absPos = dropBtn.AbsolutePosition
		local absSize = dropBtn.AbsoluteSize
		dropList.Position = UDim2.fromOffset(absPos.X, absPos.Y + absSize.Y + px(2))
		dropList.Size = UDim2.fromOffset(absSize.X, #items * itemHeight + px(4))
	end

	local function closeDropdown()
		isOpen = false
		dropList.Visible = false
		chevron.Text = "+"
	end

	for _, item in ipairs(items) do
		local itemBtn = Instance.new("TextButton")
		itemBtn.Name = item
		itemBtn.AutoButtonColor = false
		itemBtn.Text = ""
		itemBtn.BackgroundColor3 = Theme.surface4
		itemBtn.BackgroundTransparency = 1
		itemBtn.BorderSizePixel = 0
		itemBtn.Size = UDim2.new(1, 0, 0, itemHeight)
		itemBtn.ZIndex = 10001
		itemBtn.Parent = dropList

		local itemLabel = Instance.new("TextLabel")
		itemLabel.BackgroundTransparency = 1
		itemLabel.Size = UDim2.new(1, -px(12), 1, 0)
		itemLabel.Position = UDim2.fromOffset(px(6), 0)
		itemLabel.FontFace = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
		itemLabel.Text = item
		itemLabel.TextColor3 = Theme.textMain
		itemLabel.TextSize = px(12)
		itemLabel.TextXAlignment = Enum.TextXAlignment.Left
		itemLabel.ZIndex = 10002
		itemLabel.Parent = itemBtn

		itemBtn.MouseEnter:Connect(function()
			itemBtn.BackgroundTransparency = 0
			itemBtn.BackgroundColor3 = Theme.surface6
		end)

		itemBtn.MouseLeave:Connect(function()
			itemBtn.BackgroundTransparency = 1
		end)

		itemBtn.MouseButton1Click:Connect(function()
			selected = item
			dropLabel.Text = selected
			closeDropdown()
			for _, cb in callbacks do
				task.spawn(cb, selected)
			end
		end)
	end

	dropBtn.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		if isOpen then
			ensureDropListParented()
			positionDropList()
		end
		dropList.Visible = isOpen
		chevron.Text = isOpen and "-" or "+"
	end)

	container.MouseEnter:Connect(function()
		isHovered = true
		refreshHoverStroke()
	end)

	container.MouseLeave:Connect(function()
		isHovered = false
		refreshHoverStroke()
	end)

	local api = {
		root = container,
		label = label,
		getValue = function() return selected end,
		setValue = function(v)
			if table.find(items, v) then
				selected = v
				dropLabel.Text = selected
			end
		end,
		onChange = function(callback)
			table.insert(callbacks, callback)
		end,
	}

	applyDependency(api, options.dependency)
	applyLocked(api, options.locked)

	return api
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- Full-Width Multi-Select Dropdown
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

local function createFullWidthMultiDropdown(parent, text, items, defaultItems, options)
	options = options or {}
	local labelHeight = px(18)
	local btnHeight = px(22)
	local totalHeight = labelHeight + px(2) + btnHeight
	local horizontalInset = px(4)
	local labelInset = px(6)
	local itemHeight = px(22)
	local selected = {}
	local isOpen = false
	local callbacks = {}

	if defaultItems then
		for _, v in ipairs(defaultItems) do
			selected[v] = true
		end
	end

	local function getDisplayText()
		local sel = {}
		for _, item in ipairs(items) do
			if selected[item] then
				table.insert(sel, item)
			end
		end
		if #sel == 0 then return "None" end
		if #sel <= 2 then return table.concat(sel, ", ") end
		return #sel .. " selected"
	end

	local container = Instance.new("Frame")
	container.Name = text:gsub("%s+", "") .. "FullMultiDropdown"
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Size = UDim2.new(1, 0, 0, totalHeight)
	container.ClipsDescendants = false
	container.Parent = parent

	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, px(8))
	containerCorner.Parent = container

	local containerStroke = Instance.new("UIStroke")
	containerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	containerStroke.Color = Theme.accent
	containerStroke.Thickness = px(2)
	containerStroke.Transparency = 1
	containerStroke.Parent = container

	local isHovered = false

	local function refreshHoverStroke()
		local owningScreenGui = container:FindFirstAncestorWhichIsA("ScreenGui")
		local isDraggingGroupBox = owningScreenGui and owningScreenGui:GetAttribute("IsDraggingGroupBox")
		containerStroke.Transparency = (isHovered and not isDraggingGroupBox) and 0 or 1
	end

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Position = UDim2.fromOffset(labelInset, 0)
	label.Size = UDim2.new(1, -labelInset * 2, 0, labelHeight)
	label.FontFace = NunitoBoldFace
	label.Text = text
	label.TextColor3 = Theme.textMain
	label.TextSize = px(13)
	label.TextStrokeTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.ZIndex = 2
	label.Parent = container

	local dropBtn = Instance.new("TextButton")
	dropBtn.Name = "DropButton"
	dropBtn.AutoButtonColor = false
	dropBtn.Text = ""
	dropBtn.BackgroundColor3 = Theme.surface5
	dropBtn.BorderSizePixel = 0
	dropBtn.Position = UDim2.fromOffset(horizontalInset, labelHeight + px(2))
	dropBtn.Size = UDim2.new(1, -horizontalInset * 2, 0, btnHeight)
	dropBtn.ZIndex = 3
	dropBtn.Parent = container

	local dropBtnCorner = Instance.new("UICorner")
	dropBtnCorner.CornerRadius = UDim.new(0, px(5))
	dropBtnCorner.Parent = dropBtn

	local dropLabel = Instance.new("TextLabel")
	dropLabel.Name = "SelectedLabel"
	dropLabel.BackgroundTransparency = 1
	dropLabel.Size = UDim2.new(1, -px(20), 1, 0)
	dropLabel.Position = UDim2.fromOffset(px(6), 0)
	dropLabel.FontFace = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
	dropLabel.Text = getDisplayText()
	dropLabel.TextColor3 = Theme.textMain
	dropLabel.TextSize = px(12)
	dropLabel.TextXAlignment = Enum.TextXAlignment.Left
	dropLabel.TextTruncate = Enum.TextTruncate.AtEnd
	dropLabel.ZIndex = 4
	dropLabel.Parent = dropBtn

	local chevron = Instance.new("TextLabel")
	chevron.Name = "Chevron"
	chevron.BackgroundTransparency = 1
	chevron.AnchorPoint = Vector2.new(1, 0.5)
	chevron.Position = UDim2.new(1, -px(4), 0.5, 0)
	chevron.Size = UDim2.fromOffset(px(10), px(10))
	chevron.FontFace = NunitoBoldFace
	chevron.Text = "+"
	chevron.TextColor3 = Theme.textMuted
	chevron.TextSize = px(12)
	chevron.ZIndex = 4
	chevron.Parent = dropBtn

	-- Dropdown list (parented to ScreenGui to avoid ScrollingFrame clipping)
	local dropList = Instance.new("Frame")
	dropList.Name = "DropdownList_" .. text:gsub("%s+", "")
	dropList.BackgroundColor3 = Theme.surface4
	dropList.BorderSizePixel = 0
	dropList.ZIndex = 10000
	dropList.Visible = false
	dropList.ClipsDescendants = true

	local dropListCorner = Instance.new("UICorner")
	dropListCorner.CornerRadius = UDim.new(0, px(6))
	dropListCorner.Parent = dropList

	local dropListStroke = Instance.new("UIStroke")
	dropListStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	dropListStroke.Color = Theme.surface6
	dropListStroke.Thickness = px(1)
	dropListStroke.Parent = dropList

	local dropListLayout = Instance.new("UIListLayout")
	dropListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	dropListLayout.Padding = UDim.new(0, 0)
	dropListLayout.Parent = dropList

	local dropListPadding = Instance.new("UIPadding")
	dropListPadding.PaddingTop = UDim.new(0, px(2))
	dropListPadding.PaddingBottom = UDim.new(0, px(2))
	dropListPadding.Parent = dropList

	local function ensureDropListParented()
		if dropList.Parent then return end
		local sg = container:FindFirstAncestorWhichIsA("ScreenGui")
		if sg then
			dropList.Parent = sg
		end
	end

	local function positionDropList()
		local absPos = dropBtn.AbsolutePosition
		local absSize = dropBtn.AbsoluteSize
		dropList.Position = UDim2.fromOffset(absPos.X, absPos.Y + absSize.Y + px(2))
		dropList.Size = UDim2.fromOffset(absSize.X, #items * itemHeight + px(4))
	end

	local itemCheckmarks = {}

	for _, item in ipairs(items) do
		local itemBtn = Instance.new("TextButton")
		itemBtn.Name = item
		itemBtn.AutoButtonColor = false
		itemBtn.Text = ""
		itemBtn.BackgroundTransparency = 1
		itemBtn.BackgroundColor3 = Theme.surface6
		itemBtn.BorderSizePixel = 0
		itemBtn.Size = UDim2.new(1, 0, 0, itemHeight)
		itemBtn.ZIndex = 10001
		itemBtn.Parent = dropList

		local checkMark = Instance.new("Frame")
		checkMark.Name = "Check"
		checkMark.AnchorPoint = Vector2.new(0, 0.5)
		checkMark.BackgroundColor3 = selected[item] and Theme.accent or Theme.surface6
		checkMark.BorderSizePixel = 0
		checkMark.Position = UDim2.new(0, px(6), 0.5, 0)
		checkMark.Size = UDim2.fromOffset(px(10), px(10))
		checkMark.ZIndex = 10002
		checkMark.Parent = itemBtn

		local checkCorner = Instance.new("UICorner")
		checkCorner.CornerRadius = UDim.new(0, px(2))
		checkCorner.Parent = checkMark

		itemCheckmarks[item] = checkMark

		local itemLabel = Instance.new("TextLabel")
		itemLabel.BackgroundTransparency = 1
		itemLabel.Size = UDim2.new(1, -px(24), 1, 0)
		itemLabel.Position = UDim2.fromOffset(px(20), 0)
		itemLabel.FontFace = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
		itemLabel.Text = item
		itemLabel.TextColor3 = Theme.textMain
		itemLabel.TextSize = px(12)
		itemLabel.TextXAlignment = Enum.TextXAlignment.Left
		itemLabel.ZIndex = 10002
		itemLabel.Parent = itemBtn

		itemBtn.MouseEnter:Connect(function()
			itemBtn.BackgroundTransparency = 0
		end)

		itemBtn.MouseLeave:Connect(function()
			itemBtn.BackgroundTransparency = 1
		end)

		itemBtn.MouseButton1Click:Connect(function()
			selected[item] = not selected[item]
			checkMark.BackgroundColor3 = selected[item] and Theme.accent or Theme.surface6
			dropLabel.Text = getDisplayText()
			for _, cb in callbacks do
				task.spawn(cb, selected)
			end
		end)
	end

	dropBtn.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		if isOpen then
			ensureDropListParented()
			positionDropList()
		end
		dropList.Visible = isOpen
		chevron.Text = isOpen and "-" or "+"
	end)

	container.MouseEnter:Connect(function()
		isHovered = true
		refreshHoverStroke()
	end)

	container.MouseLeave:Connect(function()
		isHovered = false
		refreshHoverStroke()
	end)

	local api = {
		root = container,
		label = label,
		getValue = function()
			local result = {}
			for _, item in ipairs(items) do
				if selected[item] then
					table.insert(result, item)
				end
			end
			return result
		end,
		setValue = function(vals)
			selected = {}
			for _, v in ipairs(vals) do
				selected[v] = true
			end
			dropLabel.Text = getDisplayText()
			for item, cm in pairs(itemCheckmarks) do
				cm.BackgroundColor3 = selected[item] and Theme.accent or Theme.surface6
			end
		end,
		onChange = function(callback)
			table.insert(callbacks, callback)
		end,
	}

	applyDependency(api, options.dependency)
	applyLocked(api, options.locked)

	return api
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- Color Picker
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

local function createColorPicker(parent, text, defaultColor, options)
	options = options or {}
	local rowHeight = px(25)
	local swatchSize = px(19)
	local horizontalInset = px(4)
	local labelInset = px(6)
	local currentColor = defaultColor or Color3.fromRGB(255, 255, 255)
	local isOpen = false
	local tweenInfo = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local callbacks = {}

	-- HSV state
	local h, s, v = currentColor:ToHSV()

	local container = Instance.new("Frame")
	container.Name = text:gsub("%s+", "") .. "ColorPicker"
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Size = UDim2.new(1, 0, 0, rowHeight)
	container.ClipsDescendants = false
	container.Parent = parent

	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, px(8))
	containerCorner.Parent = container

	local containerStroke = Instance.new("UIStroke")
	containerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	containerStroke.Color = Theme.accent
	containerStroke.Thickness = px(2)
	containerStroke.Transparency = 1
	containerStroke.Parent = container

	local isHovered = false

	local function refreshHoverStroke()
		local owningScreenGui = container:FindFirstAncestorWhichIsA("ScreenGui")
		local isDraggingGroupBox = owningScreenGui and owningScreenGui:GetAttribute("IsDraggingGroupBox")
		containerStroke.Transparency = (isHovered and not isDraggingGroupBox) and 0 or 1
	end

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(labelInset, 0)
	label.Size = UDim2.new(1, -(swatchSize + labelInset + px(8)), 1, 0)
	label.FontFace = NunitoBoldFace
	label.Text = text
	label.TextColor3 = Theme.textMain
	label.TextSize = px(14)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.ZIndex = 2
	label.Parent = container

	local swatch = Instance.new("TextButton")
	swatch.Name = "Swatch"
	swatch.AnchorPoint = Vector2.new(1, 0.5)
	swatch.AutoButtonColor = false
	swatch.Text = ""
	swatch.BackgroundColor3 = currentColor
	swatch.BorderSizePixel = 0
	swatch.Position = UDim2.new(1, -horizontalInset, 0.5, 0)
	swatch.Size = UDim2.fromOffset(swatchSize, swatchSize)
	swatch.ZIndex = 3
	swatch.Parent = container

	local swatchCorner = Instance.new("UICorner")
	swatchCorner.CornerRadius = UDim.new(0, px(4))
	swatchCorner.Parent = swatch

	local swatchStroke = Instance.new("UIStroke")
	swatchStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	swatchStroke.Color = Theme.surface6
	swatchStroke.Thickness = px(1)
	swatchStroke.Parent = swatch

	-- Picker panel
	local panelWidth = px(160)
	local panelHeight = px(140)
	local svSize = px(110)
	local hueBarHeight = px(12)

	local panel = Instance.new("Frame")
	panel.Name = "PickerPanel"
	panel.BackgroundColor3 = Theme.surface4
	panel.BorderSizePixel = 0
	panel.AnchorPoint = Vector2.new(1, 0)
	panel.Position = UDim2.new(1, -horizontalInset, 0, rowHeight + px(2))
	panel.Size = UDim2.fromOffset(panelWidth, panelHeight)
	panel.ZIndex = 100
	panel.Visible = false
	panel.ClipsDescendants = true
	panel.Parent = container

	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = UDim.new(0, px(8))
	panelCorner.Parent = panel

	local panelStroke = Instance.new("UIStroke")
	panelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	panelStroke.Color = Theme.surface6
	panelStroke.Thickness = px(1)
	panelStroke.Parent = panel

	-- SV area
	local svPadding = px(6)
	local svArea = Instance.new("TextButton")
	svArea.Name = "SVArea"
	svArea.AutoButtonColor = false
	svArea.Text = ""
	svArea.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
	svArea.BorderSizePixel = 0
	svArea.Position = UDim2.fromOffset(svPadding, svPadding)
	svArea.Size = UDim2.fromOffset(svSize, svSize - px(10))
	svArea.ZIndex = 101
	svArea.Parent = panel

	local svCorner = Instance.new("UICorner")
	svCorner.CornerRadius = UDim.new(0, px(4))
	svCorner.Parent = svArea

	-- White gradient (left to right)
	local whiteGrad = Instance.new("UIGradient")
	whiteGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
	})
	whiteGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	whiteGrad.Parent = svArea

	-- Black overlay (top to bottom)
	local blackOverlay = Instance.new("Frame")
	blackOverlay.Name = "BlackOverlay"
	blackOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	blackOverlay.BorderSizePixel = 0
	blackOverlay.Size = UDim2.fromScale(1, 1)
	blackOverlay.ZIndex = 102
	blackOverlay.Parent = svArea

	local blackOverlayCorner = Instance.new("UICorner")
	blackOverlayCorner.CornerRadius = UDim.new(0, px(4))
	blackOverlayCorner.Parent = blackOverlay

	local blackGrad = Instance.new("UIGradient")
	blackGrad.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
	blackGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 0),
	})
	blackGrad.Rotation = 90
	blackGrad.Parent = blackOverlay

	-- SV cursor
	local svCursor = Instance.new("Frame")
	svCursor.Name = "SVCursor"
	svCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	svCursor.BorderSizePixel = 0
	svCursor.AnchorPoint = Vector2.new(0.5, 0.5)
	svCursor.Size = UDim2.fromOffset(px(8), px(8))
	svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
	svCursor.ZIndex = 104
	svCursor.Parent = svArea

	local svCursorCorner = Instance.new("UICorner")
	svCursorCorner.CornerRadius = UDim.new(1, 0)
	svCursorCorner.Parent = svCursor

	local svCursorStroke = Instance.new("UIStroke")
	svCursorStroke.Color = Color3.fromRGB(0, 0, 0)
	svCursorStroke.Thickness = px(1)
	svCursorStroke.Parent = svCursor

	-- Hue bar
	local hueBar = Instance.new("TextButton")
	hueBar.Name = "HueBar"
	hueBar.AutoButtonColor = false
	hueBar.Text = ""
	hueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	hueBar.BorderSizePixel = 0
	hueBar.Position = UDim2.fromOffset(svPadding, svPadding + svSize - px(10) + px(4))
	hueBar.Size = UDim2.fromOffset(svSize, hueBarHeight)
	hueBar.ZIndex = 101
	hueBar.Parent = panel

	local hueCorner = Instance.new("UICorner")
	hueCorner.CornerRadius = UDim.new(0, px(3))
	hueCorner.Parent = hueBar

	local hueGrad = Instance.new("UIGradient")
	hueGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
		ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
		ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
		ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
		ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
		ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
	})
	hueGrad.Parent = hueBar

	-- Hue cursor
	local hueCursor = Instance.new("Frame")
	hueCursor.Name = "HueCursor"
	hueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	hueCursor.BorderSizePixel = 0
	hueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
	hueCursor.Size = UDim2.fromOffset(px(4), hueBarHeight + px(2))
	hueCursor.Position = UDim2.new(h, 0, 0.5, 0)
	hueCursor.ZIndex = 103
	hueCursor.Parent = hueBar

	local hueCursorCorner = Instance.new("UICorner")
	hueCursorCorner.CornerRadius = UDim.new(0, px(1))
	hueCursorCorner.Parent = hueCursor

	local hueCursorStroke = Instance.new("UIStroke")
	hueCursorStroke.Color = Color3.fromRGB(0, 0, 0)
	hueCursorStroke.Thickness = px(1)
	hueCursorStroke.Parent = hueCursor

	-- Preview + hex input on the right side
	local infoX = svPadding + svSize + px(6)
	local infoWidth = panelWidth - infoX - svPadding

	local previewSwatch = Instance.new("Frame")
	previewSwatch.Name = "Preview"
	previewSwatch.BackgroundColor3 = currentColor
	previewSwatch.BorderSizePixel = 0
	previewSwatch.Position = UDim2.fromOffset(infoX, svPadding)
	previewSwatch.Size = UDim2.fromOffset(infoWidth, infoWidth)
	previewSwatch.ZIndex = 101
	previewSwatch.Parent = panel

	local previewCorner = Instance.new("UICorner")
	previewCorner.CornerRadius = UDim.new(0, px(4))
	previewCorner.Parent = previewSwatch

	local hexInputBg = Instance.new("Frame")
	hexInputBg.Name = "HexBg"
	hexInputBg.BackgroundColor3 = Theme.surface5
	hexInputBg.BorderSizePixel = 0
	hexInputBg.Position = UDim2.fromOffset(infoX, svPadding + infoWidth + px(4))
	hexInputBg.Size = UDim2.fromOffset(infoWidth, px(18))
	hexInputBg.ZIndex = 101
	hexInputBg.Parent = panel

	local hexCorner = Instance.new("UICorner")
	hexCorner.CornerRadius = UDim.new(0, px(3))
	hexCorner.Parent = hexInputBg

	local hexInput = Instance.new("TextBox")
	hexInput.Name = "HexInput"
	hexInput.BackgroundTransparency = 1
	hexInput.Size = UDim2.new(1, -px(4), 1, 0)
	hexInput.Position = UDim2.fromOffset(px(2), 0)
	hexInput.FontFace = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
	hexInput.Text = string.format("#%02X%02X%02X", math.round(currentColor.R * 255), math.round(currentColor.G * 255), math.round(currentColor.B * 255))
	hexInput.TextColor3 = Theme.textMain
	hexInput.TextSize = px(10)
	hexInput.ClearTextOnFocus = false
	hexInput.ZIndex = 102
	hexInput.Parent = hexInputBg

	local function updateColor()
		currentColor = Color3.fromHSV(h, s, v)
		swatch.BackgroundColor3 = currentColor
		previewSwatch.BackgroundColor3 = currentColor
		svArea.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
		hueCursor.Position = UDim2.new(h, 0, 0.5, 0)
		hexInput.Text = string.format("#%02X%02X%02X", math.round(currentColor.R * 255), math.round(currentColor.G * 255), math.round(currentColor.B * 255))
		for _, cb in callbacks do
			task.spawn(cb, currentColor)
		end
	end

	-- SV dragging
	local svDragging = false

	svArea.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			svDragging = true
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not svDragging then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end

		local absPos = svArea.AbsolutePosition
		local absSize = svArea.AbsoluteSize
		s = math.clamp((input.Position.X - absPos.X) / absSize.X, 0, 1)
		v = math.clamp(1 - ((input.Position.Y - absPos.Y) / absSize.Y), 0, 1)
		updateColor()
	end)

	-- Hue dragging
	local hueDragging = false

	hueBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			hueDragging = true
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not hueDragging then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end

		local absPos = hueBar.AbsolutePosition
		local absSize = hueBar.AbsoluteSize
		h = math.clamp((input.Position.X - absPos.X) / absSize.X, 0, 1)
		updateColor()
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			svDragging = false
			hueDragging = false
		end
	end)

	-- Hex input
	hexInput.FocusLost:Connect(function()
		local hex = hexInput.Text:gsub("#", "")
		if #hex == 6 then
			local r = tonumber(hex:sub(1, 2), 16)
			local g = tonumber(hex:sub(3, 4), 16)
			local b = tonumber(hex:sub(5, 6), 16)
			if r and g and b then
				currentColor = Color3.fromRGB(r, g, b)
				h, s, v = currentColor:ToHSV()
				updateColor()
			end
		end
	end)

	-- Toggle
	swatch.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		panel.Visible = isOpen
	end)

	container.MouseEnter:Connect(function()
		isHovered = true
		refreshHoverStroke()
	end)

	container.MouseLeave:Connect(function()
		isHovered = false
		refreshHoverStroke()
	end)

	local api = {
		root = container,
		label = label,
		getValue = function() return currentColor end,
		setValue = function(c)
			currentColor = c
			h, s, v = c:ToHSV()
			updateColor()
		end,
		onChange = function(callback)
			table.insert(callbacks, callback)
		end,
	}

	applyDependency(api, options.dependency)
	applyLocked(api, options.locked)

	return api
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- Slider
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

local function createSlider(parent, text, defaultValue, min, max, options)
	options = options or {}
	local rowHeight = px(38)
	local trackHeight = px(6)
	local knobDiameter = px(14)
	local horizontalInset = px(4)
	local labelInset = px(6)
	local inputWidth = px(40)
	local stepped = options.stepped
	local tweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local callbacks = {}

	local value = math.clamp(defaultValue, min, max)

	local function snap(v)
		if stepped then
			return math.floor(v / stepped + 0.5) * stepped
		end
		return v
	end

	local function toAlpha(v)
		return math.clamp((v - min) / (max - min), 0, 1)
	end

	local container = Instance.new("Frame")
	container.Name = text:gsub("%s+", "") .. "Slider"
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Size = UDim2.new(1, 0, 0, rowHeight)
	container.Parent = parent

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(labelInset, 0)
	label.Size = UDim2.new(1, -(labelInset + inputWidth + px(8)), 0, px(16))
	label.FontFace = NunitoBoldFace
	label.Text = text
	label.TextColor3 = Theme.textMain
	label.TextSize = px(13)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 2
	label.Parent = container

	-- Value text input
	local valInput = Instance.new("TextBox")
	valInput.Name = "ValueInput"
	valInput.AnchorPoint = Vector2.new(1, 0)
	valInput.Position = UDim2.new(1, -horizontalInset, 0, 0)
	valInput.Size = UDim2.fromOffset(inputWidth, px(16))
	valInput.BackgroundColor3 = Theme.surface5
	valInput.BorderSizePixel = 0
	valInput.FontFace = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.SemiBold)
	valInput.Text = stepped and tostring(math.floor(value)) or string.format("%.1f", value)
	valInput.TextColor3 = Theme.textMain
	valInput.TextSize = px(11)
	valInput.ClearTextOnFocus = false
	valInput.ZIndex = 3
	valInput.Parent = container

	local valInputCorner = Instance.new("UICorner")
	valInputCorner.CornerRadius = UDim.new(0, px(4))
	valInputCorner.Parent = valInput

	-- Track
	local trackY = px(20)
	local trackPadding = horizontalInset + knobDiameter / 2

	local track = Instance.new("Frame")
	track.Name = "Track"
	track.BackgroundColor3 = Theme.surface5
	track.BorderSizePixel = 0
	track.Position = UDim2.fromOffset(trackPadding, trackY)
	track.Size = UDim2.new(1, -trackPadding * 2, 0, trackHeight)
	track.ZIndex = 2
	track.Parent = container

	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = track

	-- Fill
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.BackgroundColor3 = Theme.accent
	fill.BorderSizePixel = 0
	fill.Size = UDim2.new(toAlpha(value), 0, 1, 0)
	fill.ZIndex = 3
	fill.Parent = track

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill

	-- Knob
	local knob = Instance.new("Frame")
	knob.Name = "Knob"
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.BackgroundColor3 = Theme.accent
	knob.BorderSizePixel = 0
	knob.Size = UDim2.fromOffset(knobDiameter, knobDiameter)
	knob.Position = UDim2.new(toAlpha(value), 0, 0.5, 0)
	knob.ZIndex = 5
	knob.Parent = track

	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob

	local knobStroke = Instance.new("UIStroke")
	knobStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	knobStroke.Color = Theme.textMain
	knobStroke.Thickness = px(2)
	knobStroke.Parent = knob

	local dragging = false

	local function updateVisuals(alpha)
		TweenService:Create(fill, tweenInfo, {Size = UDim2.new(alpha, 0, 1, 0)}):Play()
		TweenService:Create(knob, tweenInfo, {Position = UDim2.new(alpha, 0, 0.5, 0)}):Play()
	end

	local function setValue(v, fromInput)
		v = math.clamp(v, min, max)
		v = snap(v)
		value = v
		local alpha = toAlpha(v)
		updateVisuals(alpha)
		if not fromInput then
			valInput.Text = stepped and tostring(math.floor(v)) or string.format("%.1f", v)
		end
		for _, cb in callbacks do
			task.spawn(cb, value)
		end
	end

	-- Drag interaction
	local hitbox = Instance.new("TextButton")
	hitbox.Name = "Hitbox"
	hitbox.BackgroundTransparency = 1
	hitbox.Text = ""
	hitbox.Size = UDim2.new(1, 0, 0, knobDiameter + px(4))
	hitbox.Position = UDim2.fromOffset(0, -(knobDiameter - trackHeight) / 2 - px(2))
	hitbox.ZIndex = 6
	hitbox.Parent = track

	hitbox.MouseButton1Down:Connect(function()
		dragging = true
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local absPos = track.AbsolutePosition.X
			local absWidth = track.AbsoluteSize.X
			local mouseX = input.Position.X
			local alpha = math.clamp((mouseX - absPos) / absWidth, 0, 1)
			local v = min + alpha * (max - min)
			setValue(v)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	valInput.FocusLost:Connect(function()
		local n = tonumber(valInput.Text)
		if n then
			setValue(n, true)
		else
			valInput.Text = stepped and tostring(math.floor(value)) or string.format("%.1f", value)
		end
	end)

	local api = {
		root = container,
		label = label,
		getValue = function() return value end,
		setValue = function(v) setValue(v) end,
		onChange = function(callback)
			table.insert(callbacks, callback)
		end,
	}

	applyDependency(api, options.dependency)
	applyLocked(api, options.locked)

	return api
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- Range Slider (min/max with 2 handles)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

local function createRangeSlider(parent, text, defaultMin, defaultMax, min, max, options)
	options = options or {}
	local rowHeight = px(38)
	local trackHeight = px(6)
	local knobDiameter = px(14)
	local horizontalInset = px(4)
	local labelInset = px(6)
	local inputWidth = px(36)
	local stepped = options.stepped
	local tweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local callbacks = {}

	local valMin = math.clamp(defaultMin, min, max)
	local valMax = math.clamp(defaultMax, min, max)

	local function snap(v)
		if stepped then
			return math.floor(v / stepped + 0.5) * stepped
		end
		return v
	end

	local function toAlpha(v)
		return math.clamp((v - min) / (max - min), 0, 1)
	end

	local container = Instance.new("Frame")
	container.Name = text:gsub("%s+", "") .. "RangeSlider"
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Size = UDim2.new(1, 0, 0, rowHeight)
	container.Parent = parent

	-- Min input (left)
	local minInput = Instance.new("TextBox")
	minInput.Name = "MinInput"
	minInput.Position = UDim2.fromOffset(horizontalInset, 0)
	minInput.Size = UDim2.fromOffset(inputWidth, px(16))
	minInput.BackgroundColor3 = Theme.surface5
	minInput.BorderSizePixel = 0
	minInput.FontFace = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.SemiBold)
	minInput.Text = stepped and tostring(math.floor(valMin)) or string.format("%.1f", valMin)
	minInput.TextColor3 = Theme.textMain
	minInput.TextSize = px(11)
	minInput.ClearTextOnFocus = false
	minInput.ZIndex = 3
	minInput.Parent = container

	local minInputCorner = Instance.new("UICorner")
	minInputCorner.CornerRadius = UDim.new(0, px(4))
	minInputCorner.Parent = minInput

	-- Label (center)
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(horizontalInset + inputWidth + px(4), 0)
	label.Size = UDim2.new(1, -(horizontalInset * 2 + inputWidth * 2 + px(8)), 0, px(16))
	label.FontFace = NunitoBoldFace
	label.Text = text
	label.TextColor3 = Theme.textMain
	label.TextSize = px(13)
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.ZIndex = 2
	label.Parent = container

	-- Max input (right)
	local maxInput = Instance.new("TextBox")
	maxInput.Name = "MaxInput"
	maxInput.AnchorPoint = Vector2.new(1, 0)
	maxInput.Position = UDim2.new(1, -horizontalInset, 0, 0)
	maxInput.Size = UDim2.fromOffset(inputWidth, px(16))
	maxInput.BackgroundColor3 = Theme.surface5
	maxInput.BorderSizePixel = 0
	maxInput.FontFace = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.SemiBold)
	maxInput.Text = stepped and tostring(math.floor(valMax)) or string.format("%.1f", valMax)
	maxInput.TextColor3 = Theme.textMain
	maxInput.TextSize = px(11)
	maxInput.ClearTextOnFocus = false
	maxInput.ZIndex = 3
	maxInput.Parent = container

	local maxInputCorner = Instance.new("UICorner")
	maxInputCorner.CornerRadius = UDim.new(0, px(4))
	maxInputCorner.Parent = maxInput

	-- Track
	local trackY = px(20)
	local trackPadding = horizontalInset + knobDiameter / 2

	local track = Instance.new("Frame")
	track.Name = "Track"
	track.BackgroundColor3 = Theme.surface5
	track.BorderSizePixel = 0
	track.Position = UDim2.fromOffset(trackPadding, trackY)
	track.Size = UDim2.new(1, -trackPadding * 2, 0, trackHeight)
	track.ZIndex = 2
	track.Parent = container

	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = track

	-- Fill (between the two knobs)
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.BackgroundColor3 = Theme.accent
	fill.BorderSizePixel = 0
	fill.Position = UDim2.new(toAlpha(valMin), 0, 0, 0)
	fill.Size = UDim2.new(toAlpha(valMax) - toAlpha(valMin), 0, 1, 0)
	fill.ZIndex = 3
	fill.Parent = track

	-- Min knob
	local knobMin = Instance.new("Frame")
	knobMin.Name = "KnobMin"
	knobMin.AnchorPoint = Vector2.new(0.5, 0.5)
	knobMin.BackgroundColor3 = Theme.accent
	knobMin.BorderSizePixel = 0
	knobMin.Size = UDim2.fromOffset(knobDiameter, knobDiameter)
	knobMin.Position = UDim2.new(toAlpha(valMin), 0, 0.5, 0)
	knobMin.ZIndex = 5
	knobMin.Parent = track

	local knobMinCorner = Instance.new("UICorner")
	knobMinCorner.CornerRadius = UDim.new(1, 0)
	knobMinCorner.Parent = knobMin

	local knobMinStroke = Instance.new("UIStroke")
	knobMinStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	knobMinStroke.Color = Theme.textMain
	knobMinStroke.Thickness = px(2)
	knobMinStroke.Parent = knobMin

	-- Max knob
	local knobMax = Instance.new("Frame")
	knobMax.Name = "KnobMax"
	knobMax.AnchorPoint = Vector2.new(0.5, 0.5)
	knobMax.BackgroundColor3 = Theme.accent
	knobMax.BorderSizePixel = 0
	knobMax.Size = UDim2.fromOffset(knobDiameter, knobDiameter)
	knobMax.Position = UDim2.new(toAlpha(valMax), 0, 0.5, 0)
	knobMax.ZIndex = 5
	knobMax.Parent = track

	local knobMaxCorner = Instance.new("UICorner")
	knobMaxCorner.CornerRadius = UDim.new(1, 0)
	knobMaxCorner.Parent = knobMax

	local knobMaxStroke = Instance.new("UIStroke")
	knobMaxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	knobMaxStroke.Color = Theme.textMain
	knobMaxStroke.Thickness = px(2)
	knobMaxStroke.Parent = knobMax

	local draggingMin = false
	local draggingMax = false

	local function updateVisuals()
		local aMin = toAlpha(valMin)
		local aMax = toAlpha(valMax)
		TweenService:Create(knobMin, tweenInfo, {Position = UDim2.new(aMin, 0, 0.5, 0)}):Play()
		TweenService:Create(knobMax, tweenInfo, {Position = UDim2.new(aMax, 0, 0.5, 0)}):Play()
		TweenService:Create(fill, tweenInfo, {
			Position = UDim2.new(aMin, 0, 0, 0),
			Size = UDim2.new(aMax - aMin, 0, 1, 0),
		}):Play()
	end

	local function setValues(newMin, newMax, fromInput)
		newMin = snap(math.clamp(newMin, min, max))
		newMax = snap(math.clamp(newMax, min, max))
		if newMin > newMax then newMin = newMax end
		valMin = newMin
		valMax = newMax
		updateVisuals()
		if not fromInput then
			minInput.Text = stepped and tostring(math.floor(valMin)) or string.format("%.1f", valMin)
			maxInput.Text = stepped and tostring(math.floor(valMax)) or string.format("%.1f", valMax)
		end
		for _, cb in callbacks do
			task.spawn(cb, valMin, valMax)
		end
	end

	-- Hitbox
	local hitbox = Instance.new("TextButton")
	hitbox.Name = "Hitbox"
	hitbox.BackgroundTransparency = 1
	hitbox.Text = ""
	hitbox.Size = UDim2.new(1, 0, 0, knobDiameter + px(4))
	hitbox.Position = UDim2.fromOffset(0, -(knobDiameter - trackHeight) / 2 - px(2))
	hitbox.ZIndex = 6
	hitbox.Parent = track

	hitbox.MouseButton1Down:Connect(function(x)
		local absPos = track.AbsolutePosition.X
		local absWidth = track.AbsoluteSize.X
		local alpha = math.clamp((x - absPos) / absWidth, 0, 1)
		local distMin = math.abs(alpha - toAlpha(valMin))
		local distMax = math.abs(alpha - toAlpha(valMax))
		if distMin <= distMax then
			draggingMin = true
		else
			draggingMax = true
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if (draggingMin or draggingMax) and input.UserInputType == Enum.UserInputType.MouseMovement then
			local absPos = track.AbsolutePosition.X
			local absWidth = track.AbsoluteSize.X
			local alpha = math.clamp((input.Position.X - absPos) / absWidth, 0, 1)
			local v = min + alpha * (max - min)
			if draggingMin then
				setValues(v, valMax)
			else
				setValues(valMin, v)
			end
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingMin = false
			draggingMax = false
		end
	end)

	minInput.FocusLost:Connect(function()
		local n = tonumber(minInput.Text)
		if n then
			setValues(n, valMax, true)
		else
			minInput.Text = stepped and tostring(math.floor(valMin)) or string.format("%.1f", valMin)
		end
	end)

	maxInput.FocusLost:Connect(function()
		local n = tonumber(maxInput.Text)
		if n then
			setValues(valMin, n, true)
		else
			maxInput.Text = stepped and tostring(math.floor(valMax)) or string.format("%.1f", valMax)
		end
	end)

	local api = {
		root = container,
		label = label,
		getValue = function() return valMin, valMax end,
		setValue = function(newMin, newMax) setValues(newMin, newMax) end,
		onChange = function(callback)
			table.insert(callbacks, callback)
		end,
	}

	applyDependency(api, options.dependency)
	applyLocked(api, options.locked)

	return api
end

local function createViewportGroupBox(parent, title, width)
	local titleBarHeight = px(30)
	local viewportHeight = px(160)

	local groupBox = Instance.new("Frame")
	groupBox.Name = title:gsub("%s+", "") .. "GroupBox"
	groupBox:SetAttribute("IsGroupBox", true)
	groupBox.BackgroundTransparency = 1
	groupBox.BorderSizePixel = 0
	groupBox.Size = UDim2.fromOffset(width, titleBarHeight + viewportHeight)
	groupBox.Parent = parent

	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Active = true
	titleBar.BackgroundTransparency = 1
	titleBar.BorderSizePixel = 0
	titleBar.Size = UDim2.fromOffset(width, titleBarHeight)
	titleBar.Parent = groupBox

	local titleBarFill = Instance.new("Frame")
	titleBarFill.Name = "Fill"
	titleBarFill.BackgroundColor3 = Theme.surface4
	titleBarFill.BorderSizePixel = 0
	titleBarFill.Size = UDim2.fromScale(1, 1)
	titleBarFill.Parent = titleBar

	local titleBarCorner = Instance.new("UICorner")
	titleBarCorner.CornerRadius = UDim.new(0, px(10))
	titleBarCorner.Parent = titleBarFill

	createPartialCornerMask(
		titleBar,
		Theme.surface4,
		UDim2.new(1, 0, 0, px(10)),
		UDim2.new(0, 0, 1, -px(10)),
		2
	)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.BackgroundTransparency = 1
	titleLabel.BorderSizePixel = 0
	titleLabel.Size = UDim2.fromScale(1, 1)
	titleLabel.FontFace = NunitoBoldFace
	titleLabel.Text = title
	titleLabel.TextColor3 = Theme.textMain
	titleLabel.TextSize = px(14)
	titleLabel.TextStrokeTransparency = 1
	titleLabel.TextXAlignment = Enum.TextXAlignment.Center
	titleLabel.TextYAlignment = Enum.TextYAlignment.Center
	titleLabel.ZIndex = 3
	titleLabel.Parent = titleBar

	local body = Instance.new("Frame")
	body.Name = "Body"
	body.BackgroundTransparency = 1
	body.BorderSizePixel = 0
	body.Position = UDim2.fromOffset(0, titleBarHeight)
	body.Size = UDim2.fromOffset(width, viewportHeight)
	body.ClipsDescendants = true
	body.Parent = groupBox

	local bodyFill = Instance.new("Frame")
	bodyFill.Name = "Fill"
	bodyFill.BackgroundColor3 = Theme.surface2
	bodyFill.BorderSizePixel = 0
	bodyFill.Size = UDim2.fromScale(1, 1)
	bodyFill.Parent = body

	local bodyCorner = Instance.new("UICorner")
	bodyCorner.CornerRadius = UDim.new(0, px(10))
	bodyCorner.Parent = bodyFill

	createPartialCornerMask(
		body,
		Theme.surface2,
		UDim2.new(1, 0, 0, px(10)),
		UDim2.fromOffset(0, 0),
		2
	)

	local viewport = Instance.new("ViewportFrame")
	viewport.Name = "Viewport"
	viewport.BackgroundTransparency = 1
	viewport.Size = UDim2.fromScale(1, 1)
	viewport.Ambient = Color3.fromRGB(120, 120, 120)
	viewport.LightColor = Color3.fromRGB(200, 200, 200)
	viewport.LightDirection = Vector3.new(-1, -1, -1)
	viewport.ZIndex = 3
	viewport.Parent = body

	-- Build a proper R6 rig programmatically
	-- R6 consists of 6 visible parts: Head, Torso, Left Arm, Right Arm, Left Leg, Right Leg
	-- plus an invisible HumanoidRootPart, connected with Motor6D joints
	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewport

	local accentColor = Theme.accent

	local model = Instance.new("Model")
	model.Name = "Rig"

	-- Create all R6 parts with canonical Roblox sizes
	local function makeR6Part(name, size, cf, transparency)
		local part = Instance.new("Part")
		part.Name = name
		part.Anchored = true
		part.CanCollide = false
		part.Size = size
		part.CFrame = cf
		part.Color = accentColor
		part.Material = Enum.Material.SmoothPlastic
		part.Transparency = transparency or 0
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.Parent = model
		return part
	end

	-- Standard R6 dimensions (studs), centred at Y=3 for the torso
	local humanoidRootPart = makeR6Part("HumanoidRootPart", Vector3.new(2, 2, 1), CFrame.new(0, 3, 0), 1)
	local torso           = makeR6Part("Torso",            Vector3.new(2, 2, 1), CFrame.new(0, 3, 0))
	local head            = makeR6Part("Head",             Vector3.new(2, 1, 1), CFrame.new(0, 4.5, 0))
	local leftArm         = makeR6Part("Left Arm",         Vector3.new(1, 2, 1), CFrame.new(-1.5, 3, 0))
	local rightArm        = makeR6Part("Right Arm",        Vector3.new(1, 2, 1), CFrame.new(1.5, 3, 0))
	local leftLeg         = makeR6Part("Left Leg",         Vector3.new(1, 2, 1), CFrame.new(-0.5, 1, 0))
	local rightLeg        = makeR6Part("Right Leg",        Vector3.new(1, 2, 1), CFrame.new(0.5, 1, 0))

	-- Add a SpecialMesh to the head (cylinder/sphere look like default R6 head)
	local headMesh = Instance.new("SpecialMesh")
	headMesh.MeshType = Enum.MeshType.Head
	headMesh.Scale = Vector3.new(1.25, 1.25, 1.25)
	headMesh.Parent = head

	-- Wire up Motor6D joints so the engine sees this as a real R6 rig
	local function makeMotor(name, parent, part0, part1, c0, c1)
		local motor = Instance.new("Motor6D")
		motor.Name = name
		motor.Part0 = part0
		motor.Part1 = part1
		motor.C0 = c0
		motor.C1 = c1
		motor.Parent = parent
	end

	-- RootJoint: HumanoidRootPart â†’ Torso
	makeMotor("RootJoint", humanoidRootPart, humanoidRootPart, torso,
		CFrame.new(0, 0, 0) * CFrame.Angles(-math.pi / 2, 0, math.pi),
		CFrame.new(0, 0, 0) * CFrame.Angles(-math.pi / 2, 0, math.pi))

	-- Neck: Torso â†’ Head
	makeMotor("Neck", torso, torso, head,
		CFrame.new(0, 1, 0) * CFrame.Angles(-math.pi / 2, 0, math.pi),
		CFrame.new(0, -0.5, 0) * CFrame.Angles(-math.pi / 2, 0, math.pi))

	-- Left Shoulder: Torso â†’ Left Arm
	makeMotor("Left Shoulder", torso, torso, leftArm,
		CFrame.new(-1, 0.5, 0) * CFrame.Angles(0, -math.pi / 2, 0),
		CFrame.new(0.5, 0.5, 0) * CFrame.Angles(0, -math.pi / 2, 0))

	-- Right Shoulder: Torso â†’ Right Arm
	makeMotor("Right Shoulder", torso, torso, rightArm,
		CFrame.new(1, 0.5, 0) * CFrame.Angles(0, math.pi / 2, 0),
		CFrame.new(-0.5, 0.5, 0) * CFrame.Angles(0, math.pi / 2, 0))

	-- Left Hip: Torso â†’ Left Leg
	makeMotor("Left Hip", torso, torso, leftLeg,
		CFrame.new(-1, -1, 0) * CFrame.Angles(0, -math.pi / 2, 0),
		CFrame.new(-0.5, 1, 0) * CFrame.Angles(0, -math.pi / 2, 0))

	-- Right Hip: Torso â†’ Right Leg
	makeMotor("Right Hip", torso, torso, rightLeg,
		CFrame.new(1, -1, 0) * CFrame.Angles(0, math.pi / 2, 0),
		CFrame.new(0.5, 1, 0) * CFrame.Angles(0, math.pi / 2, 0))

	-- Add a Humanoid set to R6 rig type
	local humanoid = Instance.new("Humanoid")
	humanoid.RigType = Enum.HumanoidRigType.R6
	humanoid.Parent = model

	model.PrimaryPart = humanoidRootPart
	model.Parent = worldModel

	local camera = Instance.new("Camera")
	camera.FieldOfView = 40
	camera.CFrame = CFrame.new(Vector3.new(0, 3, 10), Vector3.new(0, 2.5, 0))
	camera.Parent = viewport
	viewport.CurrentCamera = camera

	-- Slow rotation
	local rotationAngle = 0
	local rotationSpeed = 0.4 -- radians per second

	local rotationConnection = RunService.RenderStepped:Connect(function(deltaTime)
		rotationAngle = rotationAngle + (rotationSpeed * deltaTime)

		if model.PrimaryPart then
			model:PivotTo(CFrame.new(0, 3, 0) * CFrame.Angles(0, rotationAngle, 0))
		end
	end)

	return {
		root = groupBox,
		titleBar = titleBar,
		titleLabel = titleLabel,
		body = body,
		viewport = viewport,
		model = model,
		camera = camera,
		destroy = function()
			rotationConnection:Disconnect()
			groupBox:Destroy()
		end,
	}
end

local function createBodyPartSelectorGroupBox(parent, title, width)
	local titleBarHeight = px(30)
	local bodyPadding = px(6)
	-- Proportional R6 sizing â€” half-scale, centered in the body
	-- R6 character is 4 studs wide (1 arm + 2 torso + 1 arm)
	-- and 5 studs tall (1 head + 2 torso + 2 legs)
	local gap = px(2)
	local innerWidth = width - (bodyPadding * 2)
	-- Use half the available width for the figure
	local unit = math.floor((innerWidth - (gap * 3)) / 8)
	-- Total figure dimensions
	local figureW = (unit * 4) + (gap * 3)  -- arm + gap + torso + gap + arm
	local headHeight = math.floor(unit * 1.25)
	local totalHeight = headHeight + gap + (unit * 2) + gap + (unit * 2)  -- head(1.25u) + torso(2u) + legs(2u)
	local gridHeight = totalHeight + (bodyPadding * 2)
	-- Horizontal offset to center the figure
	local offsetX = math.floor((innerWidth - figureW) / 2) + bodyPadding

	local groupBox = Instance.new("Frame")
	groupBox.Name = title:gsub("%s+", "") .. "GroupBox"
	groupBox:SetAttribute("IsGroupBox", true)
	groupBox.BackgroundTransparency = 1
	groupBox.BorderSizePixel = 0
	groupBox.Size = UDim2.fromOffset(width, titleBarHeight + gridHeight)
	groupBox.Parent = parent

	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Active = true
	titleBar.BackgroundTransparency = 1
	titleBar.BorderSizePixel = 0
	titleBar.Size = UDim2.fromOffset(width, titleBarHeight)
	titleBar.Parent = groupBox

	local titleBarFill = Instance.new("Frame")
	titleBarFill.Name = "Fill"
	titleBarFill.BackgroundColor3 = Theme.surface4
	titleBarFill.BorderSizePixel = 0
	titleBarFill.Size = UDim2.fromScale(1, 1)
	titleBarFill.Parent = titleBar

	local titleBarCorner = Instance.new("UICorner")
	titleBarCorner.CornerRadius = UDim.new(0, px(10))
	titleBarCorner.Parent = titleBarFill

	createPartialCornerMask(
		titleBar,
		Theme.surface4,
		UDim2.new(1, 0, 0, px(10)),
		UDim2.new(0, 0, 1, -px(10)),
		2
	)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.BackgroundTransparency = 1
	titleLabel.BorderSizePixel = 0
	titleLabel.Size = UDim2.fromScale(1, 1)
	titleLabel.FontFace = NunitoBoldFace
	titleLabel.Text = title
	titleLabel.TextColor3 = Theme.textMain
	titleLabel.TextSize = px(14)
	titleLabel.TextStrokeTransparency = 1
	titleLabel.TextXAlignment = Enum.TextXAlignment.Center
	titleLabel.TextYAlignment = Enum.TextYAlignment.Center
	titleLabel.ZIndex = 3
	titleLabel.Parent = titleBar

	local body = Instance.new("Frame")
	body.Name = "Body"
	body.BackgroundTransparency = 1
	body.BorderSizePixel = 0
	body.Position = UDim2.fromOffset(0, titleBarHeight)
	body.Size = UDim2.fromOffset(width, gridHeight)
	body.ClipsDescendants = true
	body.Parent = groupBox

	local bodyFill = Instance.new("Frame")
	bodyFill.Name = "Fill"
	bodyFill.BackgroundColor3 = Theme.surface2
	bodyFill.BorderSizePixel = 0
	bodyFill.Size = UDim2.fromScale(1, 1)
	bodyFill.Parent = body

	local bodyCorner = Instance.new("UICorner")
	bodyCorner.CornerRadius = UDim.new(0, px(10))
	bodyCorner.Parent = bodyFill

	createPartialCornerMask(
		body,
		Theme.surface2,
		UDim2.new(1, 0, 0, px(10)),
		UDim2.fromOffset(0, 0),
		2
	)

	-- State: which part is currently selected
	local activePart = "Torso"
	local partButtons = {}
	local tweenInfo = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function refreshAllButtons()
		for name, btn in pairs(partButtons) do
			local isActive = (name == activePart)
			TweenService:Create(btn.fill, tweenInfo, {
				BackgroundColor3 = isActive and Theme.accent or Theme.surface5,
			}):Play()
		end
	end

	local function createPartButton(name, displayText, position, size, hasStroke)
		local btn = Instance.new("TextButton")
		btn.Name = name:gsub("%s+", "") .. "Button"
		btn.AutoButtonColor = false
		btn.Text = ""
		btn.BackgroundTransparency = 1
		btn.BorderSizePixel = 0
		btn.Position = position
		btn.Size = size
		btn.ZIndex = 5
		btn.Parent = body

		local btnFill = Instance.new("Frame")
		btnFill.Name = "Fill"
		btnFill.BackgroundColor3 = (name == activePart) and Theme.accent or Theme.surface5
		btnFill.BorderSizePixel = 0
		btnFill.Size = UDim2.fromScale(1, 1)
		btnFill.ZIndex = 4
		btnFill.Parent = btn

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, px(3))
		btnCorner.Parent = btnFill

		if hasStroke then
			local btnStroke = Instance.new("UIStroke")
			btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			btnStroke.Color = Theme.surface4
			btnStroke.Thickness = px(3)
			btnStroke.Parent = btnFill
		end

		partButtons[name] = {
			button = btn,
			fill = btnFill,
		}

		btn.MouseButton1Click:Connect(function()
			activePart = name
			refreshAllButtons()
		end)

		-- Hover stroke
		local hoverStroke = Instance.new("UIStroke")
		hoverStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		hoverStroke.Color = Theme.accent
		hoverStroke.Thickness = px(2)
		hoverStroke.Transparency = 1
		hoverStroke.Parent = btnFill

		btn.MouseEnter:Connect(function()
			hoverStroke.Transparency = 0
		end)

		btn.MouseLeave:Connect(function()
			hoverStroke.Transparency = 1
		end)

		return btn
	end

	-- Layout with R6 proportions, half-scale, centered
	--
	--            [Head 1.25uÃ—1.25u]
	-- [Arm 1uÃ—2u][ Torso 2uÃ—2u   ][Arm 1uÃ—2u]
	--            [  (HRP 0.5uÂ²)  ]
	--            [L Leg]  [R Leg]
	--             1uÃ—2u    1uÃ—2u

	-- X positions (centered in body)
	local armW = unit
	local torsoW = (unit * 2) + gap
	local leftArmX = offsetX
	local torsoX = offsetX + unit + gap
	local rightArmX = offsetX + unit + gap + torsoW + gap

	-- Head is narrower than torso (~1.25 studs wide)
	local headW = math.floor(unit * 1.25)
	local headX = torsoX + math.floor((torsoW - headW) / 2)

	-- Y positions (head is 1.25u tall)
	local headY = bodyPadding
	local torsoY = bodyPadding + headHeight + gap
	local legsY = torsoY + (unit * 2) + gap

	-- Head: ~1.25u wide Ã— 1.25u tall, centered over torso
	createPartButton("Head", nil,
		UDim2.fromOffset(headX, headY),
		UDim2.fromOffset(headW, headHeight), false)

	-- Left Arm: 1u wide Ã— 2u tall
	createPartButton("Left Arm", nil,
		UDim2.fromOffset(leftArmX, torsoY),
		UDim2.fromOffset(armW, unit * 2), false)

	-- Torso: 2u wide Ã— 2u tall
	createPartButton("Torso", nil,
		UDim2.fromOffset(torsoX, torsoY),
		UDim2.fromOffset(torsoW, unit * 2), false)

	-- Right Arm: 1u wide Ã— 2u tall
	createPartButton("Right Arm", nil,
		UDim2.fromOffset(rightArmX, torsoY),
		UDim2.fromOffset(armW, unit * 2), false)

	-- HRP: 0.5u Ã— 0.5u, centered on top of torso, with stroke
	local hrpSize = math.floor(unit * 0.5)
	local hrpX = torsoX + math.floor((torsoW - hrpSize) / 2)
	local hrpY = torsoY + math.floor(((unit * 2) - hrpSize) / 2)
	createPartButton("HumanoidRootPart", nil,
		UDim2.fromOffset(hrpX, hrpY),
		UDim2.fromOffset(hrpSize, hrpSize), true)

	-- Left Leg: 1u wide Ã— 2u tall, under left side of torso
	local legAreaW = torsoW
	local legW = math.floor((legAreaW - gap) / 2)
	createPartButton("Left Leg", nil,
		UDim2.fromOffset(torsoX, legsY),
		UDim2.fromOffset(legW, unit * 2), false)

	-- Right Leg: 1u wide Ã— 2u tall, under right side of torso
	createPartButton("Right Leg", nil,
		UDim2.fromOffset(torsoX + legW + gap, legsY),
		UDim2.fromOffset(legW, unit * 2), false)

	local callbacks = {}

	return {
		root = groupBox,
		titleBar = titleBar,
		titleLabel = titleLabel,
		body = body,
		getActivePart = function()
			return activePart
		end,
		setActivePart = function(name)
			if partButtons[name] then
				activePart = name
				refreshAllButtons()
			end
		end,
		onChange = function(callback)
			-- hook into selection changes
			local origRefresh = refreshAllButtons
			refreshAllButtons = function()
				origRefresh()
				task.spawn(callback, activePart)
			end
		end,
	}
end

local function createCurveEditorGroupBox(parent, title, width)
	local titleBarHeight = px(30)
	local canvasPadding = px(6)
	local canvasHeight = px(140)
	local gridLines = 4 -- number of internal grid lines per axis
	local pointRadius = px(5)
	local lineThickness = px(2)
	local curveSegments = 120 -- number of segments to approximate the curve
	local tweenInfo = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local groupBox = Instance.new("Frame")
	groupBox.Name = title:gsub("%s+", "") .. "GroupBox"
	groupBox:SetAttribute("IsGroupBox", true)
	groupBox.BackgroundTransparency = 1
	groupBox.BorderSizePixel = 0
	groupBox.Size = UDim2.fromOffset(width, titleBarHeight + canvasHeight + (canvasPadding * 2))
	groupBox.Parent = parent

	-- Title bar (same pattern as other groupboxes)
	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Active = true
	titleBar.BackgroundTransparency = 1
	titleBar.BorderSizePixel = 0
	titleBar.Size = UDim2.fromOffset(width, titleBarHeight)
	titleBar.Parent = groupBox

	local titleBarFill = Instance.new("Frame")
	titleBarFill.Name = "Fill"
	titleBarFill.BackgroundColor3 = Theme.surface4
	titleBarFill.BorderSizePixel = 0
	titleBarFill.Size = UDim2.fromScale(1, 1)
	titleBarFill.Parent = titleBar

	local titleBarCorner = Instance.new("UICorner")
	titleBarCorner.CornerRadius = UDim.new(0, px(10))
	titleBarCorner.Parent = titleBarFill

	createPartialCornerMask(
		titleBar,
		Theme.surface4,
		UDim2.new(1, 0, 0, px(10)),
		UDim2.new(0, 0, 1, -px(10)),
		2
	)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.BackgroundTransparency = 1
	titleLabel.BorderSizePixel = 0
	titleLabel.Size = UDim2.fromScale(1, 1)
	titleLabel.FontFace = NunitoBoldFace
	titleLabel.Text = title
	titleLabel.TextColor3 = Theme.textMain
	titleLabel.TextSize = px(14)
	titleLabel.TextStrokeTransparency = 1
	titleLabel.TextXAlignment = Enum.TextXAlignment.Center
	titleLabel.TextYAlignment = Enum.TextYAlignment.Center
	titleLabel.ZIndex = 3
	titleLabel.Parent = titleBar

	-- Body
	local body = Instance.new("Frame")
	body.Name = "Body"
	body.BackgroundTransparency = 1
	body.BorderSizePixel = 0
	body.Position = UDim2.fromOffset(0, titleBarHeight)
	body.Size = UDim2.fromOffset(width, canvasHeight + (canvasPadding * 2))
	body.ClipsDescendants = true
	body.Parent = groupBox

	local bodyFill = Instance.new("Frame")
	bodyFill.Name = "Fill"
	bodyFill.BackgroundColor3 = Theme.surface2
	bodyFill.BorderSizePixel = 0
	bodyFill.Size = UDim2.fromScale(1, 1)
	bodyFill.Parent = body

	local bodyCorner = Instance.new("UICorner")
	bodyCorner.CornerRadius = UDim.new(0, px(10))
	bodyCorner.Parent = bodyFill

	createPartialCornerMask(
		body,
		Theme.surface2,
		UDim2.new(1, 0, 0, px(10)),
		UDim2.fromOffset(0, 0),
		2
	)

	-- Canvas area (where the curve lives)
	local canvasWidth = width - (canvasPadding * 2)

	local canvas = Instance.new("Frame")
	canvas.Name = "Canvas"
	canvas.BackgroundColor3 = Theme.surface0
	canvas.BorderSizePixel = 0
	canvas.Position = UDim2.fromOffset(canvasPadding, canvasPadding)
	canvas.Size = UDim2.fromOffset(canvasWidth, canvasHeight)
	canvas.ClipsDescendants = true
	canvas.ZIndex = 3
	canvas.Parent = body

	local canvasCorner = Instance.new("UICorner")
	canvasCorner.CornerRadius = UDim.new(0, px(6))
	canvasCorner.Parent = canvas

	local canvasStroke = Instance.new("UIStroke")
	canvasStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	canvasStroke.Color = Theme.surface5
	canvasStroke.Thickness = px(1)
	canvasStroke.Parent = canvas

	-- Grid lines
	for i = 1, gridLines do
		local t = i / (gridLines + 1)

		-- Vertical grid line
		local vLine = Instance.new("Frame")
		vLine.Name = "VGrid" .. i
		vLine.BackgroundColor3 = Theme.surface3
		vLine.BorderSizePixel = 0
		vLine.Position = UDim2.new(t, 0, 0, 0)
		vLine.Size = UDim2.new(0, px(1), 1, 0)
		vLine.ZIndex = 4
		vLine.Parent = canvas

		-- Horizontal grid line
		local hLine = Instance.new("Frame")
		hLine.Name = "HGrid" .. i
		hLine.BackgroundColor3 = Theme.surface3
		hLine.BorderSizePixel = 0
		hLine.Position = UDim2.new(0, 0, t, 0)
		hLine.Size = UDim2.new(1, 0, 0, px(1))
		hLine.ZIndex = 4
		hLine.Parent = canvas
	end

	-- Diagonal reference line (linear, from bottom-left to top-right)
	local diagLine = Instance.new("Frame")
	diagLine.Name = "DiagonalRef"
	diagLine.BackgroundColor3 = Theme.surface4
	diagLine.BorderSizePixel = 0
	diagLine.AnchorPoint = Vector2.new(0.5, 0.5)
	diagLine.ZIndex = 4
	diagLine.Parent = canvas

	local diagLength = math.sqrt(canvasWidth * canvasWidth + canvasHeight * canvasHeight)
	local diagAngle = math.atan2(-canvasHeight, canvasWidth) -- negative because Y is flipped
	diagLine.Size = UDim2.fromOffset(diagLength, px(1))
	diagLine.Position = UDim2.fromScale(0.5, 0.5)
	diagLine.Rotation = math.deg(diagAngle)

	-- Curve rendering: line segments container
	local curveContainer = Instance.new("Frame")
	curveContainer.Name = "CurveContainer"
	curveContainer.BackgroundTransparency = 1
	curveContainer.Size = UDim2.fromScale(1, 1)
	curveContainer.ZIndex = 5
	curveContainer.Parent = canvas

	-- Control points data: {x, y} normalized 0-1, where (0,0) = bottom-left, (1,1) = top-right
	local controlPoints = {
		{ x = 0, y = 0 },       -- start (locked X)
		{ x = 0.12, y = 0.02 },
		{ x = 0.25, y = 0.10 },
		{ x = 0.5, y = 0.5 },
		{ x = 0.75, y = 0.90 },
		{ x = 0.88, y = 0.98 },
		{ x = 1, y = 1 },       -- end (locked X)
	}

	local pointFrames = {}
	local lineSegments = {}

	-- Helper: draw a line segment between two pixel positions
	local function createLineSegment()
		local seg = Instance.new("Frame")
		seg.Name = "Segment"
		seg.BackgroundColor3 = Theme.accent
		seg.BorderSizePixel = 0
		seg.AnchorPoint = Vector2.new(0, 0.5)
		seg.ZIndex = 6
		seg.Parent = curveContainer
		return seg
	end

	local function updateLineSegment(seg, x1, y1, x2, y2)
		local dx = x2 - x1
		local dy = y2 - y1
		local length = math.sqrt(dx * dx + dy * dy)
		local angle = math.deg(math.atan2(dy, dx))

		seg.Size = UDim2.fromOffset(math.max(length, 1), lineThickness)
		seg.Position = UDim2.fromOffset(x1, y1)
		seg.Rotation = angle
	end

	-- Catmull-Rom spline interpolation
	local function catmullRom(p0, p1, p2, p3, t)
		local t2 = t * t
		local t3 = t2 * t
		return 0.5 * (
			(2 * p1) +
			(-p0 + p2) * t +
			(2 * p0 - 5 * p1 + 4 * p2 - p3) * t2 +
			(-p0 + 3 * p1 - 3 * p2 + p3) * t3
		)
	end

	-- Sort points by X and redraw curve
	local function redrawCurve()
		-- Sort control points by X
		table.sort(controlPoints, function(a, b) return a.x < b.x end)

		-- Build the list of pixel positions along the spline
		local n = #controlPoints
		local curvePixels = {}

		for i = 1, n - 1 do
			local p0 = controlPoints[math.max(i - 1, 1)]
			local p1 = controlPoints[i]
			local p2 = controlPoints[math.min(i + 1, n)]
			local p3 = controlPoints[math.min(i + 2, n)]

			local segsForSpan = math.ceil(curveSegments / (n - 1))

			for s = 0, segsForSpan - 1 do
				local t = s / segsForSpan
				local cx = catmullRom(p0.x, p1.x, p2.x, p3.x, t)
				local cy = catmullRom(p0.y, p1.y, p2.y, p3.y, t)

				-- Convert normalized to pixel (Y is flipped: 0 = bottom, 1 = top)
				local pixelX = cx * canvasWidth
				local pixelY = (1 - cy) * canvasHeight

				table.insert(curvePixels, { x = pixelX, y = pixelY })
			end
		end

		-- Add last point
		local lastPt = controlPoints[n]
		table.insert(curvePixels, { x = lastPt.x * canvasWidth, y = (1 - lastPt.y) * canvasHeight })

		-- Create/reuse line segments
		while #lineSegments < #curvePixels - 1 do
			table.insert(lineSegments, createLineSegment())
		end

		-- Hide excess segments
		for i = #curvePixels, #lineSegments do
			lineSegments[i].Visible = false
		end

		-- Update visible segments
		for i = 1, #curvePixels - 1 do
			local a = curvePixels[i]
			local b = curvePixels[i + 1]
			lineSegments[i].Visible = true
			updateLineSegment(lineSegments[i], a.x, a.y, b.x, b.y)
		end
	end

	-- Create draggable control point handles
	local dragState = {
		active = false,
		pointIndex = nil,
		startInputPosition = nil,
	}

	local function createPointHandle(index)
		local pt = controlPoints[index]
		local isEndpoint = (index == 1 or index == #controlPoints)

		local handle = Instance.new("TextButton")
		handle.Name = "Point" .. index
		handle.AutoButtonColor = false
		handle.Text = ""
		handle.BackgroundColor3 = isEndpoint and Theme.accentSoft or Theme.accent
		handle.BorderSizePixel = 0
		handle.AnchorPoint = Vector2.new(0.5, 0.5)
		handle.Size = UDim2.fromOffset(pointRadius * 2, pointRadius * 2)
		handle.Position = UDim2.fromOffset(
			pt.x * canvasWidth,
			(1 - pt.y) * canvasHeight
		)
		handle.ZIndex = 8
		handle.Parent = canvas

		local handleCorner = Instance.new("UICorner")
		handleCorner.CornerRadius = UDim.new(1, 0)
		handleCorner.Parent = handle

		local handleStroke = Instance.new("UIStroke")
		handleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		handleStroke.Color = Theme.textMain
		handleStroke.Thickness = px(1)
		handleStroke.Transparency = 0.5
		handleStroke.Parent = handle

		-- Hover effect
		handle.MouseEnter:Connect(function()
			TweenService:Create(handle, tweenInfo, {
				Size = UDim2.fromOffset(pointRadius * 2.5, pointRadius * 2.5),
			}):Play()
			handleStroke.Transparency = 0
		end)

		handle.MouseLeave:Connect(function()
			if not dragState.active or dragState.pointIndex ~= index then
				TweenService:Create(handle, tweenInfo, {
					Size = UDim2.fromOffset(pointRadius * 2, pointRadius * 2),
				}):Play()
				handleStroke.Transparency = 0.5
			end
		end)

		handle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragState.active = true
				dragState.pointIndex = index
				dragState.startInputPosition = input.Position
			end
		end)

		pointFrames[index] = handle
	end

	for i = 1, #controlPoints do
		createPointHandle(i)
	end

	-- Update point handle positions
	local function updatePointPositions()
		for i, pt in ipairs(controlPoints) do
			if pointFrames[i] then
				pointFrames[i].Position = UDim2.fromOffset(
					pt.x * canvasWidth,
					(1 - pt.y) * canvasHeight
				)
			end
		end
	end

	-- Handle dragging via UserInputService
	UserInputService.InputChanged:Connect(function(input)
		if not dragState.active then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end

		local idx = dragState.pointIndex
		if not idx then return end

		local canvasAbsPos = canvas.AbsolutePosition
		local guiInset = GuiService:GetGuiInset()
		local mousePos = input.Position

		-- Mouse position relative to canvas
		local relX = (mousePos.X - canvasAbsPos.X) / canvasWidth
		local relY = 1 - ((mousePos.Y - canvasAbsPos.Y) / canvasHeight)

		-- Clamp Y to 0-1
		relY = math.clamp(relY, 0, 1)

		-- Endpoints: lock X position
		local isEndpoint = (idx == 1 or idx == #controlPoints)
		if isEndpoint then
			controlPoints[idx].y = relY
		else
			-- Interior points: allow X movement but clamp to 0.01-0.99
			relX = math.clamp(relX, 0.01, 0.99)
			controlPoints[idx].x = relX
			controlPoints[idx].y = relY
		end

		updatePointPositions()
		redrawCurve()
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if dragState.active and dragState.pointIndex then
				local handle = pointFrames[dragState.pointIndex]
				if handle then
					TweenService:Create(handle, tweenInfo, {
						Size = UDim2.fromOffset(pointRadius * 2, pointRadius * 2),
					}):Play()
				end
			end

			dragState.active = false
			dragState.pointIndex = nil
			dragState.startInputPosition = nil
		end
	end)

	-- Initial draw
	redrawCurve()

	return {
		root = groupBox,
		titleBar = titleBar,
		titleLabel = titleLabel,
		body = body,
		canvas = canvas,
		getPoints = function()
			local sorted = {}
			for _, pt in ipairs(controlPoints) do
				table.insert(sorted, { x = pt.x, y = pt.y })
			end
			table.sort(sorted, function(a, b) return a.x < b.x end)
			return sorted
		end,
		evaluate = function(t)
			-- Evaluate the curve at normalized X position t (0-1)
			table.sort(controlPoints, function(a, b) return a.x < b.x end)
			local n = #controlPoints

			-- Find which span t falls in
			for i = 1, n - 1 do
				if t <= controlPoints[i + 1].x or i == n - 1 then
					local p0 = controlPoints[math.max(i - 1, 1)]
					local p1 = controlPoints[i]
					local p2 = controlPoints[math.min(i + 1, n)]
					local p3 = controlPoints[math.min(i + 2, n)]

					local spanT = 0
					local spanWidth = p2.x - p1.x
					if spanWidth > 0 then
						spanT = (t - p1.x) / spanWidth
					end

					return catmullRom(p0.y, p1.y, p2.y, p3.y, spanT)
				end
			end

			return controlPoints[n].y
		end,
	}
end

local function createWindow()
	local existingGui = playerGui:FindFirstChild("GlycerinUI")
	if existingGui then
		existingGui:Destroy()
	end

	local existingBlur = game:GetService("Lighting"):FindFirstChild("GlycerinBlur")
	if existingBlur then
		existingBlur:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GlycerinUI"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 100
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	local windowWidth = px(800)
	local windowHeight = px(450)
	local horizontalPadding = px(8)
	local verticalPadding = px(8)
	local columnGap = px(8)
	local sidebarWidth = px(60)
	local remainingWidth = windowWidth - (horizontalPadding * 2) - sidebarWidth - (columnGap * 3)
	local contentColumnWidth = remainingWidth / 3
	local containerHeight = windowHeight - (verticalPadding * 2)

	-- Background blur/dim overlay
	local blurEnabled = true
	local blurOverlay = Instance.new("Frame")
	blurOverlay.Name = "BackgroundBlur"
	blurOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	blurOverlay.BackgroundTransparency = 0.4
	blurOverlay.BorderSizePixel = 0
	blurOverlay.Size = UDim2.fromScale(1, 1)
	blurOverlay.ZIndex = -1
	blurOverlay.Parent = screenGui

	-- Also add a BlurEffect to Lighting for actual visual blur
	local blurEffect = Instance.new("BlurEffect")
	blurEffect.Name = "GlycerinBlur"
	blurEffect.Size = 10
	blurEffect.Parent = game:GetService("Lighting")

	local function updateBlur()
		blurOverlay.Visible = blurEnabled and screenGui.Enabled
		blurEffect.Enabled = blurEnabled and screenGui.Enabled
	end

	-- Show/Hide keybind
	local menuBind = Enum.KeyCode.RightShift
	local UserInputService = game:GetService("UserInputService")

	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then return end
		if input.KeyCode == menuBind then
			screenGui.Enabled = not screenGui.Enabled
			updateBlur()
		end
	end)

	updateBlur()

	local window = Instance.new("Frame")
	window.Name = "Window"
	window.AnchorPoint = Vector2.new(0.5, 0.5)
	window.Position = UDim2.fromScale(0.5, 0.5)
	window.Size = UDim2.fromOffset(windowWidth, windowHeight)
	window.BackgroundColor3 = Theme.surface
	window.BorderSizePixel = 0
	window.Parent = screenGui

	local windowCorner = Instance.new("UICorner")
	windowCorner.CornerRadius = UDim.new(0, px(18))
	windowCorner.Parent = window

	local windowStroke = Instance.new("UIStroke")
	windowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	windowStroke.Color = Theme.stroke
	windowStroke.Thickness = px(1)
	windowStroke.Parent = window

	local sidebarContainer = Instance.new("Frame")
	sidebarContainer.Name = "SidebarContainer"
	sidebarContainer.Position = UDim2.fromOffset(horizontalPadding, verticalPadding)
	sidebarContainer.Size = UDim2.fromOffset(sidebarWidth, containerHeight)
	sidebarContainer.BackgroundColor3 = Theme.surface2
	sidebarContainer.BorderSizePixel = 0
	sidebarContainer.Parent = window

	local sidebarCorner = Instance.new("UICorner")
	sidebarCorner.CornerRadius = UDim.new(0, px(14))
	sidebarCorner.Parent = sidebarContainer

	local sidebarPadding = Instance.new("UIPadding")
	sidebarPadding.PaddingTop = UDim.new(0, px(6))
	sidebarPadding.PaddingBottom = UDim.new(0, px(6))
	sidebarPadding.PaddingLeft = UDim.new(0, px(6))
	sidebarPadding.PaddingRight = UDim.new(0, px(6))
	sidebarPadding.Parent = sidebarContainer

	local sidebarLayout = Instance.new("UIListLayout")
	sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	sidebarLayout.Padding = UDim.new(0, px(4))
	sidebarLayout.Parent = sidebarContainer

	-- Sidebar tab button helper
	local activeTab = nil
	local tabButtons = {}

	local function createSidebarTab(iconName, tabName, isDefault)
		local iconAsset = Lucide.GetAsset(iconName)
		local btnSize = sidebarWidth - px(12)
		local iconSize = px(20)

		local tabBtn = Instance.new("TextButton")
		tabBtn.Name = tabName .. "Tab"
		tabBtn.AutoButtonColor = false
		tabBtn.Text = ""
		tabBtn.BackgroundColor3 = isDefault and Theme.accent or Theme.surface4
		tabBtn.BorderSizePixel = 0
		tabBtn.Size = UDim2.fromOffset(btnSize, btnSize)
		tabBtn.Parent = sidebarContainer

		local tabCorner = Instance.new("UICorner")
		tabCorner.CornerRadius = UDim.new(0, px(10))
		tabCorner.Parent = tabBtn

		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.BackgroundTransparency = 1
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Position = UDim2.fromScale(0.5, 0.5)
		icon.Size = UDim2.fromOffset(iconSize, iconSize)
		icon.ImageColor3 = isDefault and Theme.textMain or Theme.textTertiary
		icon.ZIndex = 2
		icon.Parent = tabBtn

		if iconAsset then
			icon.Image = iconAsset.Url
			icon.ImageRectSize = iconAsset.ImageRectSize
			icon.ImageRectOffset = iconAsset.ImageRectOffset
		end

		tabButtons[tabName] = {
			button = tabBtn,
			icon = icon,
		}

		if isDefault then
			activeTab = tabName
		end

		local function refreshTab()
			local isActive = (activeTab == tabName)
			TweenService:Create(tabBtn, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = isActive and Theme.accent or Theme.surface4,
			}):Play()
			TweenService:Create(icon, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				ImageColor3 = isActive and Theme.textMain or Theme.textTertiary,
			}):Play()
		end

		tabBtn.MouseButton1Click:Connect(function()
			activeTab = tabName
			for _, tb in pairs(tabButtons) do
				local isAct = (activeTab == tabName)
				-- refresh all
			end
			for name, tb in pairs(tabButtons) do
				local isAct = (name == activeTab)
				TweenService:Create(tb.button, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundColor3 = isAct and Theme.accent or Theme.surface4,
				}):Play()
				TweenService:Create(tb.icon, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					ImageColor3 = isAct and Theme.textMain or Theme.textTertiary,
				}):Play()
			end
		end)

		-- Hover effect (only when not active)
		local hoverStroke = Instance.new("UIStroke")
		hoverStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		hoverStroke.Color = Theme.accent
		hoverStroke.Thickness = px(2)
		hoverStroke.Transparency = 1
		hoverStroke.Parent = tabBtn

		tabBtn.MouseEnter:Connect(function()
			if activeTab ~= tabName then
				hoverStroke.Transparency = 0
			end
		end)

		tabBtn.MouseLeave:Connect(function()
			hoverStroke.Transparency = 1
		end)

		return tabBtn
	end

	-- Tab content containers
	local tabContents = {}

	-- Home tab content (the 3 columns)
	local homeContent = Instance.new("Frame")
	homeContent.Name = "HomeContent"
	homeContent.BackgroundTransparency = 1
	homeContent.Size = UDim2.fromScale(1, 1)
	homeContent.Visible = true
	homeContent.Parent = window

	-- Settings tab content (full width scrolling panel)
	local settingsContentWidth = windowWidth - (horizontalPadding * 2) - sidebarWidth - columnGap
	local settingsContent = Instance.new("ScrollingFrame")
	settingsContent.Name = "SettingsContent"
	settingsContent.Position = UDim2.fromOffset(horizontalPadding + sidebarWidth + columnGap, verticalPadding)
	settingsContent.Size = UDim2.fromOffset(settingsContentWidth, containerHeight)
	settingsContent.BackgroundTransparency = 1
	settingsContent.BorderSizePixel = 0
	settingsContent.CanvasSize = UDim2.fromOffset(0, 0)
	settingsContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
	settingsContent.ScrollingDirection = Enum.ScrollingDirection.Y
	settingsContent.ScrollBarThickness = 0
	settingsContent.ScrollingEnabled = true
	settingsContent.VerticalScrollBarInset = Enum.ScrollBarInset.None
	settingsContent.Visible = false
	settingsContent.Parent = window

	local settingsLayout = Instance.new("UIListLayout")
	settingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	settingsLayout.Padding = UDim.new(0, px(8))
	settingsLayout.Parent = settingsContent

	tabContents["Home"] = homeContent
	tabContents["Settings"] = settingsContent

	local function switchTab(tabName)
		for name, content in pairs(tabContents) do
			content.Visible = (name == tabName)
		end
	end

	-- Modify createSidebarTab to include switchTab callback
	local origCreateSidebarTab = createSidebarTab

	createSidebarTab = function(iconName, tabName, isDefault)
		local tabBtn = origCreateSidebarTab(iconName, tabName, isDefault)

		-- Add switchTab to the existing click handler
		tabBtn.MouseButton1Click:Connect(function()
			switchTab(tabName)
		end)

		return tabBtn
	end

	-- First tab: Home (active by default)
	createSidebarTab("house", "Home", true)
	-- Second tab: Settings
	createSidebarTab("settings", "Settings", false)

	local leftColumn = Instance.new("ScrollingFrame")
	leftColumn.Name = "leftColumn"
	leftColumn.Position = UDim2.fromOffset(horizontalPadding + sidebarWidth + columnGap, verticalPadding)
	leftColumn.Size = UDim2.fromOffset(contentColumnWidth, containerHeight)
	leftColumn.BackgroundTransparency = 1
	leftColumn.BorderSizePixel = 0
	leftColumn.CanvasSize = UDim2.fromOffset(0, 0)
	leftColumn.AutomaticCanvasSize = Enum.AutomaticSize.Y
	leftColumn.ScrollingDirection = Enum.ScrollingDirection.Y
	leftColumn.ScrollBarThickness = 0
	leftColumn.ScrollingEnabled = true
	leftColumn.VerticalScrollBarInset = Enum.ScrollBarInset.None
	leftColumn.Parent = homeContent

	local leftLayout = Instance.new("UIListLayout")
	leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
	leftLayout.Padding = UDim.new(0, px(8))
	leftLayout.Parent = leftColumn

	local middleColumn = Instance.new("ScrollingFrame")
	middleColumn.Name = "middleColumn"
	middleColumn.Position = UDim2.fromOffset(horizontalPadding + sidebarWidth + columnGap + contentColumnWidth + columnGap, verticalPadding)
	middleColumn.Size = UDim2.fromOffset(contentColumnWidth, containerHeight)
	middleColumn.BackgroundTransparency = 1
	middleColumn.BorderSizePixel = 0
	middleColumn.CanvasSize = UDim2.fromOffset(0, 0)
	middleColumn.AutomaticCanvasSize = Enum.AutomaticSize.Y
	middleColumn.ScrollingDirection = Enum.ScrollingDirection.Y
	middleColumn.ScrollBarThickness = 0
	middleColumn.ScrollingEnabled = true
	middleColumn.VerticalScrollBarInset = Enum.ScrollBarInset.None
	middleColumn.Parent = homeContent

	local middleLayout = Instance.new("UIListLayout")
	middleLayout.SortOrder = Enum.SortOrder.LayoutOrder
	middleLayout.Padding = UDim.new(0, px(8))
	middleLayout.Parent = middleColumn

	local rightColumn = Instance.new("ScrollingFrame")
	rightColumn.Name = "rightColumn"
	rightColumn.Position = UDim2.fromOffset(horizontalPadding + sidebarWidth + columnGap + contentColumnWidth + columnGap + contentColumnWidth + columnGap, verticalPadding)
	rightColumn.Size = UDim2.fromOffset(contentColumnWidth, containerHeight)
	rightColumn.BackgroundTransparency = 1
	rightColumn.BorderSizePixel = 0
	rightColumn.CanvasSize = UDim2.fromOffset(0, 0)
	rightColumn.AutomaticCanvasSize = Enum.AutomaticSize.Y
	rightColumn.ScrollingDirection = Enum.ScrollingDirection.Y
	rightColumn.ScrollBarThickness = 0
	rightColumn.ScrollingEnabled = true
	rightColumn.VerticalScrollBarInset = Enum.ScrollBarInset.None
	rightColumn.Parent = homeContent

	local rightLayout = Instance.new("UIListLayout")
	rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
	rightLayout.Padding = UDim.new(0, px(8))
	rightLayout.Parent = rightColumn

	local dragZones = {}

	local function createDragZone(name, position, size)
		local dragZone = Instance.new("TextButton")
		dragZone.Name = name
		dragZone.AutoButtonColor = false
		dragZone.Text = ""
		dragZone.BackgroundTransparency = 1
		dragZone.BorderSizePixel = 0
		dragZone.Position = position
		dragZone.Size = size
		dragZone.ZIndex = window.ZIndex + 1
		dragZone.Parent = window
		table.insert(dragZones, dragZone)

		return dragZone
	end

	createDragZone("TopDragZone", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, verticalPadding))
	createDragZone("BottomDragZone", UDim2.new(0, 0, 1, -verticalPadding), UDim2.new(1, 0, 0, verticalPadding))
	createDragZone("LeftDragZone", UDim2.fromOffset(0, verticalPadding), UDim2.fromOffset(horizontalPadding, containerHeight))
	createDragZone("RightDragZone", UDim2.new(1, -horizontalPadding, 0, verticalPadding), UDim2.fromOffset(horizontalPadding, containerHeight))
	createDragZone(
		"GapOneDragZone",
		UDim2.fromOffset(horizontalPadding + sidebarWidth, verticalPadding),
		UDim2.fromOffset(columnGap, containerHeight)
	)
	createDragZone(
		"GapTwoDragZone",
		UDim2.fromOffset(horizontalPadding + sidebarWidth + columnGap + contentColumnWidth, verticalPadding),
		UDim2.fromOffset(columnGap, containerHeight)
	)
	createDragZone(
		"GapThreeDragZone",
		UDim2.fromOffset(horizontalPadding + sidebarWidth + columnGap + contentColumnWidth + columnGap + contentColumnWidth, verticalPadding),
		UDim2.fromOffset(columnGap, containerHeight)
	)

	makeWindowDraggable(window, dragZones)

	local connectGroupBoxDrag = enableGroupBoxDragAndDrop(screenGui, {
		left = leftColumn,
		middle = middleColumn,
		right = rightColumn,
	})

	local columnsByName = {
		left = leftColumn,
		middle = middleColumn,
		right = rightColumn,
	}

	local homeGroupBoxes = {}
	local managedDestroyables = {}

	local function resolveColumn(column)
		if type(column) == "string" then
			return columnsByName[string.lower(column)]
		end

		return column
	end

	local function trackDestroyable(control)
		if control and control.destroy then
			table.insert(managedDestroyables, control)
		end

		return control
	end

	local function registerGroupBox(groupBox)
		if not groupBox or groupBox.__glycerinRegistered then
			return groupBox
		end

		groupBox.__glycerinRegistered = true

		local parent = groupBox.root and groupBox.root.Parent
		if parent == leftColumn or parent == middleColumn or parent == rightColumn then
			connectGroupBoxDrag(groupBox)
			table.insert(homeGroupBoxes, groupBox)
		end

		return trackDestroyable(groupBox)
	end

	local function createColumnGroupBox(factory, column, title)
		local parent = resolveColumn(column)
		assert(parent, "Expected column to be 'left', 'middle', 'right', or a matching ScrollingFrame")
		return registerGroupBox(factory(parent, title, contentColumnWidth))
	end

	-- Settings tab content
	local settingsGroupBox = createGroupBox(settingsContent, "Settings", settingsContentWidth)

	createLabel(settingsGroupBox.content, "Interface")
	createDivider(settingsGroupBox.content)

	-- Present in the UI, but theme swapping is still up to the integrator.
	local themeDropdown = createDropdown(settingsGroupBox.content, "Theme", {"Dark", "Light", "OLED"}, "Dark")

	-- Present in the UI, but scaling behavior is still up to the integrator.
	local uiScaleSlider = createSlider(settingsGroupBox.content, "UI Scale", 100, 50, 200, { stepped = 5 })

	local animationsToggle = createToggle(settingsGroupBox.content, "Animations", true)

	createDivider(settingsGroupBox.content)
	createLabel(settingsGroupBox.content, "Background")

	local blurToggle = createToggle(settingsGroupBox.content, "Background Blur", true)
	blurToggle.onChange(function(val)
		blurEnabled = val
		updateBlur()
	end)

	local blurStrength = createSlider(settingsGroupBox.content, "Blur Strength", 10, 0, 24, { stepped = 1 })
	blurStrength.onChange(function(val)
		blurEffect.Size = val
	end)

	createDivider(settingsGroupBox.content)
	createLabel(settingsGroupBox.content, "Keybinds")

	local menuKeyPicker = createKeyPicker(settingsGroupBox.content, "Menu Toggle", Enum.KeyCode.RightShift)
	menuKeyPicker.onChange(function(newKey)
		menuBind = newKey
	end)

	createDivider(settingsGroupBox.content)
	createLabel(settingsGroupBox.content, "Advanced")

	local webhookUrlInput = createTextInput(settingsGroupBox.content, "Webhook URL", "", { placeholder = "https://..." })

	local destroyed = false

	local function destroy()
		if destroyed then
			return
		end

		destroyed = true

		for _, control in ipairs(managedDestroyables) do
			if control and control.destroy then
				control.destroy()
			end
		end

		blurEffect:Destroy()
		screenGui:Destroy()
	end

	return {
		screenGui = screenGui,
		window = window,
		tabs = {
			home = homeContent,
			settings = settingsContent,
		},
		containers = {
			sidebar = sidebarContainer,
			left = leftColumn,
			middle = middleColumn,
			right = rightColumn,
			settings = settingsContent,
		},
		sizes = {
			column = contentColumnWidth,
			settings = settingsContentWidth,
		},
		groupBoxes = homeGroupBoxes,
		settings = {
			container = settingsContent,
			groupBox = settingsGroupBox,
			controls = {
				theme = themeDropdown,
				uiScale = uiScaleSlider,
				animations = animationsToggle,
				backgroundBlur = blurToggle,
				blurStrength = blurStrength,
				menuToggle = menuKeyPicker,
				webhookUrl = webhookUrlInput,
			},
		},
		Icons = Lucide,
		Theme = Theme,
		switchTab = switchTab,
		resolveColumn = resolveColumn,
		registerGroupBox = registerGroupBox,
		addGroupBox = function(column, title)
			return createColumnGroupBox(createGroupBox, column, title)
		end,
		addViewportGroupBox = function(column, title)
			return createColumnGroupBox(createViewportGroupBox, column, title)
		end,
		addBodyPartSelectorGroupBox = function(column, title)
			return createColumnGroupBox(createBodyPartSelectorGroupBox, column, title)
		end,
		addCurveEditorGroupBox = function(column, title)
			return createColumnGroupBox(createCurveEditorGroupBox, column, title)
		end,
		createToggle = createToggle,
		createCheckbox = createCheckbox,
		createLabel = createLabel,
		createWrappingLabel = createWrappingLabel,
		createDivider = createDivider,
		createTextInput = createTextInput,
		createNumberInput = createNumberInput,
		createPasswordInput = createPasswordInput,
		createKeyPicker = createKeyPicker,
		createDropdown = createDropdown,
		createMultiDropdown = createMultiDropdown,
		createFullWidthDropdown = createFullWidthDropdown,
		createFullWidthMultiDropdown = createFullWidthMultiDropdown,
		createColorPicker = createColorPicker,
		createSlider = createSlider,
		createRangeSlider = createRangeSlider,
		createGroupBox = function(parent, title, width)
			local groupBox = createGroupBox(parent, title, width)
			return registerGroupBox(groupBox)
		end,
		createViewportGroupBox = function(parent, title, width)
			local groupBox = createViewportGroupBox(parent, title, width)
			return registerGroupBox(groupBox)
		end,
		createBodyPartSelectorGroupBox = function(parent, title, width)
			local groupBox = createBodyPartSelectorGroupBox(parent, title, width)
			return registerGroupBox(groupBox)
		end,
		createCurveEditorGroupBox = function(parent, title, width)
			local groupBox = createCurveEditorGroupBox(parent, title, width)
			return registerGroupBox(groupBox)
		end,
		applyDependency = applyDependency,
		applyLocked = applyLocked,
		destroy = destroy,
	}
end

return {
	Theme = Theme,
	Icons = Lucide,
	createWindow = createWindow,
}
