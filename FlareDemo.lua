--[[
    FlareUI (Customized WindUI) - Comprehensive Demo Loader
    This script demonstrates all available UI components with the new customized layout.
]]

local cloneref = (cloneref or clonereference or function(instance) return instance end)
local RunService = cloneref(game:GetService("RunService"))

local WindUI
do
    local ok, result = pcall(function()
        return require(script.Parent.src.Init)
    end)

    if ok then
        WindUI = result
    else
        -- Fallback for direct execution if script is not parented correctly
        -- In your environment, you can use the local path
        WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Therealtobu/FlareUI/main/dist/main.lua"))()
    end
end

-- Create Window with the new customized layout
local Window = WindUI:CreateWindow({
    Title = "FlareUI Demo",
    Author = "by AI Assistant",
    Icon = "lucide:sparkles",
    Theme = "Dark",
    NewElements = true, -- Modern look
    Transparent = true,
    ToggleKey = Enum.KeyCode.RightControl,
    Acrylic = true,
    User = {
        Enabled = true, -- Shows the profile in the sidebar top
        Anonymous = false,
        Callback = function()
            WindUI:Notify({
                Title = "Profile",
                Content = "You clicked on your profile!",
                Icon = "lucide:user"
            })
        end
    }
})

-- Add a Tag to the Topbar
Window:Tag({
    Title = "STABLE",
    Color = Color3.fromRGB(0, 255, 150),
})

-- Add a Custom Topbar Button
Window.Topbar:Button({
    Name = "Info",
    Icon = "lucide:info",
    Callback = function()
        Window:Dialog({
            Title = "About FlareUI",
            Content = "This is a customized version of WindUI with a slim topbar, floating controls, and sidebar profile.",
            Buttons = {
                { Title = "Close", Variant = "Primary" }
            }
        })
    end
})

-- --- TAB 1: DASHBOARD ---
local Tab1 = Window:Tab({
    Title = "Dashboard",
    Icon = "lucide:layout-dashboard",
})
Tab1:Select()

Tab1:Section({
    Title = "Welcome to FlareUI",
    Desc = "Check out the new slim topbar and sidebar profile!"
})

local StatsGroup = Tab1:Group()
StatsGroup:Paragraph({
    Title = "System Status",
    Content = "All systems operational. Custom UI layout loaded successfully."
})

Tab1:Section({ Title = "Quick Actions" })
local ActionGroup = Tab1:Group()

ActionGroup:Button({
    Title = "Show Notification",
    Icon = "lucide:bell",
    Callback = function()
        WindUI:Notify({
            Title = "FlareUI Notification",
            Content = "This is a sample notification with modern styling.",
            Icon = "lucide:check-circle"
        })
    end
})

ActionGroup:Toggle({
    Title = "Automatic Updates",
    Value = true,
    Callback = function(v) print("Updates:", v) end
})

-- --- TAB 2: INTERACTIVE ELEMENTS ---
local Tab2 = Window:Tab({
    Title = "Elements",
    Icon = "lucide:component",
})

Tab2:Section({ Title = "Input Elements" })

Tab2:Input({
    Title = "Search Query",
    Placeholder = "Type something...",
    Callback = function(v) print("Input:", v) end
})

Tab2:Slider({
    Title = "Walk Speed",
    Value = { Min = 16, Max = 100, Default = 16 },
    Callback = function(v) print("Speed:", v) end
})

Tab2:Dropdown({
    Title = "Select Region",
    Values = {"North America", "Europe", "Asia", "South America"},
    Value = "Asia",
    Callback = function(v) print("Selected:", v) end
})

Tab2:Colorpicker({
    Title = "Theme Color",
    Default = Color3.fromRGB(0, 120, 255),
    Callback = function(color) print("Color:", color) end
})

Tab2:Keybind({
    Title = "Fast Fly Bind",
    Default = Enum.KeyCode.E,
    Callback = function() print("Keybind pressed!") end
})

-- --- TAB 3: SETTINGS ---
local Tab3 = Window:Tab({
    Title = "Settings",
    Icon = "lucide:settings",
})

Tab3:Section({ Title = "UI Customization" })

local ThemeList = {}
for name, _ in pairs(WindUI.Themes) do table.insert(ThemeList, name) end

Tab3:Dropdown({
    Title = "UI Theme",
    Values = ThemeList,
    Value = "Dark",
    Callback = function(v) WindUI:SetTheme(v) end
})

Tab3:Toggle({
    Title = "Acrylic Blur",
    Value = true,
    Callback = function(v) Window:ToggleTransparency(v) end
})

Tab3:Button({
    Title = "Destroy UI",
    Variant = "Danger",
    Callback = function() Window:Destroy() end
})

return Window
