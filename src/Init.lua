local WindUI = {
	Window = nil,
	Theme = nil,
	Creator = require("./modules/Creator"),
	LocalizationModule = require("./modules/Localization"),
	NotificationModule = require("./components/Notification"),
	Themes = nil,
	Transparent = false,

	TransparencyValue = 0.15,

	UIScale = 1,

	ConfigManager = nil,
	Version = "0.0.0",

	Services = require("./utils/services/Init"),

	OnThemeChangeFunction = nil,

	cloneref = nil,
	UIScaleObj = nil,
}

local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)

WindUI.cloneref = cloneref

local HttpService = cloneref(game:GetService("HttpService"))
local Players = cloneref(game:GetService("Players"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local RunService = cloneref(game:GetService("RunService"))

local LocalPlayer = Players.LocalPlayer or nil

local Package = HttpService:JSONDecode(require("../build/package"))
if Package then
	WindUI.Version = Package.version
end

local KeySystem = require("./components/KeySystem")

local Creator = WindUI.Creator

local New = Creator.New

--local Tween = Creator.Tween
--local ServicesModule = WindUI.Services

local Acrylic = require("./utils/Acrylic/Init")

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end

local GUIParent = gethui and gethui() or (CoreGui or LocalPlayer:WaitForChild("PlayerGui"))

local UIScaleObj = New("UIScale", {
	Scale = WindUI.UIScale,
})

WindUI.UIScaleObj = UIScaleObj

WindUI.ScreenGui = New("ScreenGui", {
	Name = "WindUI",
	Parent = GUIParent,
	IgnoreGuiInset = true,
	ScreenInsets = "None",
	DisplayOrder = -99999,
}, {

	New("Folder", {
		Name = "Window",
	}),
	-- New("Folder", {
	--     Name = "Notifications"
	-- }),
	-- New("Folder", {
	--     Name = "Dropdowns"
	-- }),
	New("Folder", {
		Name = "KeySystem",
	}),
	New("Folder", {
		Name = "Popups",
	}),
	New("Folder", {
		Name = "ToolTips",
	}),
})

WindUI.NotificationGui = New("ScreenGui", {
	Name = "WindUI/Notifications",
	Parent = GUIParent,
	IgnoreGuiInset = true,
})
WindUI.DropdownGui = New("ScreenGui", {
	Name = "WindUI/Dropdowns",
	Parent = GUIParent,
	IgnoreGuiInset = true,
})
WindUI.TooltipGui = New("ScreenGui", {
	Name = "WindUI/Tooltips",
	Parent = GUIParent,
	IgnoreGuiInset = true,
})
ProtectGui(WindUI.ScreenGui)
ProtectGui(WindUI.NotificationGui)
ProtectGui(WindUI.DropdownGui)
ProtectGui(WindUI.TooltipGui)

Creator.Init(WindUI)

function WindUI:SetParent(parent)
	if WindUI.ScreenGui then
		WindUI.ScreenGui.Parent = parent
	end
	if WindUI.NotificationGui then
		WindUI.NotificationGui.Parent = parent
	end
	if WindUI.DropdownGui then
		WindUI.DropdownGui.Parent = parent
	end
	if WindUI.TooltipGui then
		WindUI.TooltipGui.Parent = parent
	end
end
math.clamp(WindUI.TransparencyValue, 0, 1)

-- local Holder = WindUI.NotificationModule.Init(WindUI.NotificationGui)

local IslandSize = 44
local IslandExpandedWidth = 250
local IslandExpandedHeight = 44

WindUI.DynamicIsland = New("TextButton", {
	Name = "DynamicIsland",
	Parent = WindUI.ScreenGui,
	Size = UDim2.new(0, IslandSize, 0, IslandSize),
	Position = UDim2.new(0, 273, 0, 6),
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 0.3,
	Text = "",
	ZIndex = 9999999,
	AutoButtonColor = false,
}, {
	New("UICorner", { CornerRadius = UDim.new(1, 0) }),
	New("ImageLabel", {
		Name = "Icon",
		Size = UDim2.new(0, 28, 0, 28),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://139056174427730",
	}),
	New("Frame", {
		Name = "Content",
		Size = UDim2.new(1, -20, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Visible = false,
	}, {
		New("UIListLayout", {
			FillDirection = "Vertical",
			VerticalAlignment = "Center",
			Padding = UDim.new(0, 2),
		}),
		New("TextLabel", {
			Name = "Title",
			Size = UDim2.new(1, 0, 0, 14),
			BackgroundTransparency = 1,
			Text = "Notification",
			TextColor3 = Color3.new(1, 1, 1),
			TextXAlignment = "Left",
			FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
			TextSize = 14,
			TextTransparency = 1,
		}),
		New("TextLabel", {
			Name = "Desc",
			Size = UDim2.new(1, 0, 0, 12),
			BackgroundTransparency = 1,
			Text = "Message content",
			TextColor3 = Color3.new(0.8, 0.8, 0.8),
			TextXAlignment = "Left",
			FontFace = Font.new(Creator.Font, Enum.FontWeight.Regular),
			TextSize = 12,
			TextTransparency = 1,
		})
	})
})

Creator.AddSignal(WindUI.DynamicIsland.MouseButton1Click, function()
	if WindUI.Window and WindUI.Window.UIElements and WindUI.Window.UIElements.Main then
		local Main = WindUI.Window.UIElements.Main
		if Main.Visible then
			-- Toggle Off (ẩn UI)
			Main.Visible = false
		else
			-- Toggle On (hiện UI)
			Main.Visible = true
		end
	end
end)

local isNotifying = false
local NotificationQueue = {}

local function ProcessNotification()
	if isNotifying or #NotificationQueue == 0 then return end
	isNotifying = true

	local Config = table.remove(NotificationQueue, 1)
	local Island = WindUI.DynamicIsland
	local Icon = Island.Icon
	local Content = Island.Content

	Content.Title.Text = Config.Title or "Notification"
	Content.Desc.Text = Config.Content or ""

	-- Tính toán kích thước tối thiểu cần thiết
	local textWidth = math.max(Content.Title.TextBounds.X, Content.Desc.TextBounds.X) + 30
	local targetWidth = math.max(IslandExpandedWidth, textWidth)

	-- Bước 1: Mờ icon, phình to
	Creator.Tween(Icon, 0.2, { ImageTransparency = 1 }):Play()
	Creator.Tween(Island, 0.4, { Size = UDim2.new(0, targetWidth, 0, IslandExpandedHeight) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
	
	task.wait(0.2)
	Content.Visible = true
	Creator.Tween(Content.Title, 0.2, { TextTransparency = 0 }):Play()
	Creator.Tween(Content.Desc, 0.2, { TextTransparency = 0 }):Play()

	-- Bước 2: Chờ thời gian
	task.wait(Config.Duration or 3)

	-- Bước 3: Thu nhỏ, hiện lại icon
	Creator.Tween(Content.Title, 0.2, { TextTransparency = 1 }):Play()
	Creator.Tween(Content.Desc, 0.2, { TextTransparency = 1 }):Play()
	
	task.wait(0.2)
	Content.Visible = false
	Creator.Tween(Island, 0.4, { Size = UDim2.new(0, IslandSize, 0, IslandSize) }, Enum.EasingStyle.Back, Enum.EasingDirection.InOut):Play()
	task.wait(0.2)
	Creator.Tween(Icon, 0.2, { ImageTransparency = 0 }):Play()
	
	task.wait(0.3)
	isNotifying = false
	ProcessNotification()
end

function WindUI:Notify(Config)
	table.insert(NotificationQueue, Config)
	ProcessNotification()
end

function WindUI:SetNotificationLower(Val)
	-- Holder.SetLower(Val) -- Bỏ qua vì đã dùng Dynamic Island
end

function WindUI:SetFont(FontId)
	Creator.UpdateFont(FontId)
end

function WindUI:OnThemeChange(func)
	WindUI.OnThemeChangeFunction = func
end

function WindUI:AddTheme(LTheme)
	WindUI.Themes[LTheme.Name] = LTheme
	return LTheme
end

function WindUI:SetTheme(Value)
	if WindUI.Themes[Value] then
		WindUI.Theme = WindUI.Themes[Value]
		Creator.SetTheme(WindUI.Themes[Value])

		if WindUI.OnThemeChangeFunction then
			WindUI.OnThemeChangeFunction(Value)
		end

		return WindUI.Themes[Value]
	end
	return nil
end

function WindUI:GetThemes()
	return WindUI.Themes
end
function WindUI:GetCurrentTheme()
	return WindUI.Theme.Name
end
function WindUI:GetTransparency()
	return WindUI.Transparent or false
end
function WindUI:GetWindowSize()
	return WindUI.Window.UIElements.Main.Size
end
function WindUI:Localization(LocalizationConfig)
	return WindUI.LocalizationModule:New(LocalizationConfig, Creator)
end

function WindUI:SetLanguage(Value)
	if Creator.Localization then
		return Creator.SetLanguage(Value)
	end
	return false
end

function WindUI:ToggleAcrylic(Value)
	if WindUI.Window and WindUI.Window.AcrylicPaint and WindUI.Window.AcrylicPaint.Model then
		WindUI.Window.Acrylic = Value
		WindUI.Window.AcrylicPaint.Model.Transparency = Value and 0.98 or 1
		if Value then
			Acrylic.Enable()
		else
			Acrylic.Disable()
		end
	end
end

function WindUI:Gradient(stops, props)
	local colorSequence = {}
	local transparencySequence = {}

	for posStr, stop in next, stops do
		local position = tonumber(posStr)
		if position then
			position = math.clamp(position / 100, 0, 1)

			local color = stop.Color
			if typeof(color) == "string" and string.sub(color, 1, 1) == "#" then
				color = Color3.fromHex(color)
			end

			local transparency = stop.Transparency or 0

			table.insert(colorSequence, ColorSequenceKeypoint.new(position, color))
			table.insert(transparencySequence, NumberSequenceKeypoint.new(position, transparency))
		end
	end

	table.sort(colorSequence, function(a, b)
		return a.Time < b.Time
	end)
	table.sort(transparencySequence, function(a, b)
		return a.Time < b.Time
	end)

	if #colorSequence < 2 then
		table.insert(colorSequence, ColorSequenceKeypoint.new(1, colorSequence[1].Value))
		table.insert(transparencySequence, NumberSequenceKeypoint.new(1, transparencySequence[1].Value))
	end

	local gradientData = {
		Color = ColorSequence.new(colorSequence),
		Transparency = NumberSequence.new(transparencySequence),
	}

	if props then
		for k, v in pairs(props) do
			gradientData[k] = v
		end
	end

	return gradientData
end

function WindUI:Popup(PopupConfig)
	PopupConfig.WindUI = WindUI
	return require("./components/popup/Init").new(PopupConfig, WindUI.ScreenGui.Popups)
end

WindUI.Themes = require("./themes/Init")(WindUI, Creator)

Creator.Themes = WindUI.Themes

WindUI:SetTheme("Dark")
WindUI:SetLanguage(Creator.Language)

function WindUI:CreateWindow(Config)
	local CreateWindow = require("./components/window/Init")

	if not RunService:IsStudio() and writefile then
		if not isfolder("WindUI") then
			makefolder("WindUI")
		end
		if Config.Folder then
			makefolder(Config.Folder)
		else
			makefolder(Config.Title)
		end
	end

	Config.WindUI = WindUI
	Config.Window = WindUI.Window
	Config.Parent = WindUI.ScreenGui.Window

	if WindUI.Window then
		warn("You cannot create more than one window")
		return
	end

	local CanLoadWindow = true

	local Theme = WindUI.Themes[Config.Theme or "Dark"]

	--WindUI.Theme = Theme
	Creator.SetTheme(Theme)

	local hwid = gethwid or function()
		return Players.LocalPlayer.UserId
	end

	local Filename = hwid()

	if Config.KeySystem then
		CanLoadWindow = false

		local function loadKeysystem()
			KeySystem.new(Config, Filename, function(c)
				CanLoadWindow = c
			end)
		end

		local keyPath = (Config.Folder or "Temp") .. "/" .. Filename .. ".key"

		if Config.KeySystem.KeyValidator then
			if Config.KeySystem.SaveKey and isfile(keyPath) then
				local savedKey = readfile(keyPath)
				local isValid = Config.KeySystem.KeyValidator(savedKey)

				if isValid then
					CanLoadWindow = true
				else
					loadKeysystem()
				end
			else
				loadKeysystem()
			end
		elseif not Config.KeySystem.API then
			if Config.KeySystem.SaveKey and isfile(keyPath) then
				local savedKey = readfile(keyPath)
				local isKey = (type(Config.KeySystem.Key) == "table") and table.find(Config.KeySystem.Key, savedKey)
					or tostring(Config.KeySystem.Key) == tostring(savedKey)

				if isKey then
					CanLoadWindow = true
				else
					loadKeysystem()
				end
			else
				loadKeysystem()
			end
		else
			if isfile(keyPath) then
				local fileKey = readfile(keyPath)
				local isSuccess = false

				for _, i in next, Config.KeySystem.API do
					local serviceData = WindUI.Services[i.Type]
					if serviceData then
						local args = {}
						for _, argName in next, serviceData.Args do
							table.insert(args, i[argName])
						end

						local service = serviceData.New(table.unpack(args))
						local success = service.Verify(fileKey)
						if success then
							isSuccess = true
							break
						end
					end
				end

				CanLoadWindow = isSuccess
				if not isSuccess then
					loadKeysystem()
				end
			else
				loadKeysystem()
			end
		end

		repeat
			task.wait()
		until CanLoadWindow
	end

	local Window = CreateWindow(Config)

	WindUI.Transparent = Config.Transparent
	WindUI.Window = Window

	if Config.Acrylic then
		Acrylic.init()
	end

	-- function Window:ToggleTransparency(Value)
	--     WindUI.Transparent = Value
	--     WindUI.Window.Transparent = Value

	--     Window.UIElements.Main.Background.BackgroundTransparency = Value and WindUI.TransparencyValue or 0
	--     Window.UIElements.Main.Background.ImageLabel.ImageTransparency = Value and WindUI.TransparencyValue or 0
	--     Window.UIElements.Main.Gradient.UIGradient.Transparency = NumberSequence.new{
	--         NumberSequenceKeypoint.new(0, 1),
	--         NumberSequenceKeypoint.new(1, Value and 0.85 or 0.7),
	--     }
	-- end

	return Window
end

return WindUI
