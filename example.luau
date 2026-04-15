local SOURCE_URL = "https://raw.githubusercontent.com/j0z4fx/glycerin-ui/refs/heads/main/src.luau"
local Glycerin = assert(loadstring(game:HttpGet(SOURCE_URL), "@glycerin-src"))()

local ui = Glycerin.createWindow()
ui.switchTab("Home")

local function logValue(name, ...)
	print("[Glycerin Example]", name, ...)
end

local basics = ui.addGroupBox("left", "Basics")
local inputs = ui.addGroupBox("middle", "Inputs")
local advanced = ui.addGroupBox("right", "Advanced")

local viewport = ui.addViewportGroupBox("middle", "Viewport Preview")
local bodyParts = ui.addBodyPartSelectorGroupBox("right", "Body Parts")
local curveEditor = ui.addCurveEditorGroupBox("left", "Curve Editor")

ui.createLabel(basics.content, "Label Example")
ui.createDivider(basics.content)

ui.createWrappingLabel(
	basics.content,
	"This example loads src.luau from the GitHub raw URL through game:HttpGet(...) and creates one of every exposed control type."
)

local enabledToggle = ui.createToggle(basics.content, "Enabled", true)
enabledToggle.onChange(function(value)
	logValue("Toggle", value)
end)

local outlineCheckbox = ui.createCheckbox(basics.content, "Use Outlines", false)
outlineCheckbox.onChange(function(value)
	logValue("Checkbox", value)
end)

local usernameInput = ui.createTextInput(inputs.content, "Username", "", {
	placeholder = "Enter username",
})
usernameInput.onChange(function(value)
	logValue("TextInput", value)
end)

local speedInput = ui.createNumberInput(inputs.content, "WalkSpeed", 16, {
	min = 0,
	max = 100,
})
speedInput.onChange(function(value)
	logValue("NumberInput", value)
end)

local passwordInput = ui.createPasswordInput(inputs.content, "Password", "hunter2")
passwordInput.onChange(function(value)
	logValue("PasswordInput", value)
end)

local toggleKey = ui.createKeyPicker(inputs.content, "Toggle Key", Enum.KeyCode.RightShift)
toggleKey.onChange(function(value)
	logValue("KeyPicker", value and value.Name or "None")
end)

local opacitySlider = ui.createSlider(inputs.content, "Opacity", 75, 0, 100, {
	stepped = 1,
})
opacitySlider.onChange(function(value)
	logValue("Slider", value)
end)

local rangeSlider = ui.createRangeSlider(inputs.content, "Range", 20, 80, 0, 100, {
	stepped = 5,
})
rangeSlider.onChange(function(minValue, maxValue)
	logValue("RangeSlider", minValue, maxValue)
end)

local modeDropdown = ui.createDropdown(advanced.content, "Mode", {
	"Normal",
	"Fast",
	"Slow",
	"Custom",
}, "Normal")
modeDropdown.onChange(function(value)
	logValue("Dropdown", value)
end)

local targetDropdown = ui.createMultiDropdown(advanced.content, "Targets", {
	"Head",
	"Torso",
	"Arms",
	"Legs",
}, {"Head", "Torso"})
targetDropdown.onChange(function(values)
	logValue("MultiDropdown", table.concat(values, ", "))
end)

local boneDropdown = ui.createFullWidthDropdown(advanced.content, "Bone Type", {
	"Linear",
	"Bezier",
	"Catmull-Rom",
}, "Linear")
boneDropdown.onChange(function(value)
	logValue("FullWidthDropdown", value)
end)

local filterDropdown = ui.createFullWidthMultiDropdown(advanced.content, "Filter Parts", {
	"Head",
	"Torso",
	"Left Arm",
	"Right Arm",
}, {"Head"})
filterDropdown.onChange(function(values)
	logValue("FullWidthMultiDropdown", table.concat(values, ", "))
end)

local colorPicker = ui.createColorPicker(advanced.content, "Highlight", Color3.fromRGB(66, 120, 245))
colorPicker.onChange(function(value)
	logValue("ColorPicker", value)
end)

bodyParts.onChange(function(partName)
	logValue("BodyPartSelector", partName)
end)

logValue("CurveEditor initial sample", curveEditor.evaluate(0.5))
logValue("Example ready", "All controls have been created.")
