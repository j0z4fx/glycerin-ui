# Glycerin API

`src.luau` is the stripped API build.

`window.client.luau` is still the showcase/demo script with sample controls pre-filled.

## Quick Start

As a ModuleScript:

```lua
local Glycerin = require(path.to.src)
local ui = Glycerin.createWindow()
```

Adding your own content:

```lua
local Glycerin = require(path.to.src)
local ui = Glycerin.createWindow()

local main = ui.addGroupBox("left", "Main")
local enabled = ui.createToggle(main.content, "Enabled", false)
local speed = ui.createSlider(main.content, "Speed", 16, 0, 100, { stepped = 1 })
local mode = ui.createDropdown(main.content, "Mode", {"Walk", "Run", "Fly"}, "Walk")

enabled.onChange(function(value)
	print("Enabled:", value)
end)

speed.onChange(function(value)
	print("Speed:", value)
end)

mode.onChange(function(value)
	print("Mode:", value)
end)
```

## Module Surface

`require(src)` returns:

```lua
{
	Theme = ThemeTable,
	Icons = LucideLibrary,
	createWindow = function() -> WindowApi
}
```

`Glycerin.Theme` exposes the color tokens used internally.

`Glycerin.Icons` is the Lucide loader object returned by the bundled HTTP-loaded icon library.

## createWindow

`Glycerin.createWindow()` creates the main GUI and returns a `WindowApi`.

Important fields:

- `screenGui`: the root `ScreenGui`
- `window`: the main window frame
- `tabs.home`: the 3-column home area
- `tabs.settings`: the settings scrolling panel
- `containers.left`, `containers.middle`, `containers.right`: scrollable home columns
- `containers.settings`: settings scrolling frame
- `sizes.column`: default width for home group boxes
- `sizes.settings`: width of the settings panel
- `groupBoxes`: array of draggable home-tab group boxes you create
- `settings.groupBox`: the built-in settings group box
- `settings.controls`: references to the built-in settings controls
- `Theme`: same theme table as `Glycerin.Theme`
- `Icons`: same icon table as `Glycerin.Icons`
- `switchTab(tabName)`: switch between `"Home"` and `"Settings"`
- `resolveColumn(column)`: accepts `"left"`, `"middle"`, `"right"`, or a column instance
- `registerGroupBox(groupBox)`: registers a manually-created group box for home-tab drag/drop
- `destroy()`: removes the UI and blur effect

## Recommended Group Box Helpers

Use these when adding content to the home tab:

- `ui.addGroupBox(column, title)`
- `ui.addViewportGroupBox(column, title)`
- `ui.addBodyPartSelectorGroupBox(column, title)`
- `ui.addCurveEditorGroupBox(column, title)`

`column` can be `"left"`, `"middle"`, or `"right"`.

These helpers size the group box for the home columns and register drag/drop automatically.

Example:

```lua
local preview = ui.addViewportGroupBox("middle", "Preview")
local selector = ui.addBodyPartSelectorGroupBox("right", "Body Part")
local curve = ui.addCurveEditorGroupBox("left", "Curve")
```

## Low-Level Factories

These are exposed on the `WindowApi`:

- `createToggle(parent, text, defaultValue, options)`
- `createCheckbox(parent, text, defaultValue, options)`
- `createLabel(parent, text, options)`
- `createWrappingLabel(parent, text, options)`
- `createDivider(parent, options)`
- `createTextInput(parent, text, defaultValue, options)`
- `createNumberInput(parent, text, defaultValue, options)`
- `createPasswordInput(parent, text, defaultValue, options)`
- `createKeyPicker(parent, text, defaultKey, options)`
- `createDropdown(parent, text, items, defaultItem, options)`
- `createMultiDropdown(parent, text, items, defaultItems, options)`
- `createFullWidthDropdown(parent, text, items, defaultItem, options)`
- `createFullWidthMultiDropdown(parent, text, items, defaultItems, options)`
- `createColorPicker(parent, text, defaultColor, options)`
- `createSlider(parent, text, defaultValue, min, max, options)`
- `createRangeSlider(parent, text, defaultMin, defaultMax, min, max, options)`
- `createGroupBox(parent, title, width)`
- `createViewportGroupBox(parent, title, width)`
- `createBodyPartSelectorGroupBox(parent, title, width)`
- `createCurveEditorGroupBox(parent, title, width)`
- `applyDependency(control, depConfig)`
- `applyLocked(control, lockConfig)`

## Common Control API

Most controls return:

- `root`: the root GUI object for that control
- `getValue()`
- `setValue(...)`
- `onChange(callback)`

Notes:

- `createRangeSlider().getValue()` returns `minValue, maxValue`
- `createRangeSlider().onChange(callback)` calls back with `minValue, maxValue`
- `createPasswordInput()` also exposes `toggleVisibility()`
- `createBodyPartSelectorGroupBox()` exposes `getActivePart()`, `setActivePart(name)`, and `onChange(callback)`
- `createCurveEditorGroupBox()` exposes `getPoints()` and `evaluate(t)`
- `createViewportGroupBox()` exposes `viewport`, `model`, `camera`, and `destroy()`
- plain labels and dividers expose placeholder `getValue/setValue/onChange` methods for consistency

## Shared Options

Most interactive controls support:

```lua
{
	dependency = {
		control = someOtherControl,
		condition = function(value)
			return value == true
		end,
	},
	locked = true
}
```

Dependency behavior:

- if `condition` is omitted, the control is visible when the dependency value is `true`
- you can also use `getValue` and `signal` in `depConfig` for custom dependency sources

Locked behavior:

- adds a visual lock overlay
- if `locked` was supplied, the returned control also gains `setLocked(bool)` and `isLocked()`

## Per-Control Options

- `createLabel` and `createWrappingLabel`: `options.color`
- `createTextInput`, `createPasswordInput`: `options.placeholder`, `options.inputWidth`
- `createNumberInput`: `options.min`, `options.max`, `options.inputWidth`
- `createDropdown`, `createMultiDropdown`: `options.dropdownWidth`
- `createSlider`, `createRangeSlider`: `options.stepped`

## Group Box Return Shapes

`createGroupBox()` returns:

```lua
{
	root = Frame,
	titleBar = Frame,
	titleLabel = TextLabel,
	body = Frame,
	content = Frame
}
```

That `content` frame is where you place controls.

Example:

```lua
local box = ui.addGroupBox("left", "Combat")
ui.createToggle(box.content, "Silent Aim", false)
ui.createCheckbox(box.content, "Wall Check", true)
ui.createDivider(box.content)
ui.createTextInput(box.content, "Target", "", { placeholder = "Username" })
```

## Built-In Settings Menu

The stripped build keeps the settings tab intact.

Available built-in control references:

- `ui.settings.controls.theme`
- `ui.settings.controls.uiScale`
- `ui.settings.controls.animations`
- `ui.settings.controls.backgroundBlur`
- `ui.settings.controls.blurStrength`
- `ui.settings.controls.menuToggle`
- `ui.settings.controls.webhookUrl`

Current built-in behavior:

- `backgroundBlur` toggles the blur overlay/effect
- `blurStrength` updates the `BlurEffect.Size`
- `menuToggle` changes the show/hide keybind
- `theme` and `uiScale` are present in the UI, but do not apply visual changes by themselves yet

## Notes

- Creating a second window destroys the previous `GlycerinUI` and existing `GlycerinBlur`
- Home-tab group boxes are draggable between columns
- Settings content is not draggable
- If you create a custom group box with a low-level factory for a home column, call `ui.registerGroupBox(groupBox)` unless you used `ui.addGroupBox(...)` or one of the other `add...GroupBox(...)` helpers
