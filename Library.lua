local PlexUI = {}

-- Configuration
PlexUI.Config = {
    Title = "PlexUI",
    Theme = {
        Background = Color3.fromRGB(20, 20, 20),
        Header = Color3.fromRGB(30, 30, 30),
        Text = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(80, 80, 255),
        Secondary = Color3.fromRGB(40, 40, 40),
        Hover = Color3.fromRGB(50, 50, 50),
    },
    ToggleKey = Enum.KeyCode.RightShift,
    Draggable = true,
}

-- Core UI Components
function PlexUI:CreateWindow(config)
    config = config or {}
    for k, v in pairs(config) do
        self.Config[k] = v
    end
    
    -- Create main UI
    local PlexLibrary = {}
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PlexUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.BackgroundColor3 = self.Config.Theme.Background
    main.BorderSizePixel = 0
    main.Position = UDim2.new(0.5, -300, 0.5, -200)
    main.Size = UDim2.new(0, 600, 0, 400)
    main.Parent = screenGui
    
    -- Drop shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.ZIndex = -1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.Parent = main
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.BackgroundColor3 = self.Config.Theme.Header
    header.BorderSizePixel = 0
    header.Size = UDim2.new(1, 0, 0, 30)
    header.Parent = main
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 10, 0, 0)
    title.Size = UDim2.new(0, 200, 1, 0)
    title.Font = Enum.Font.GothamBold
    title.Text = self.Config.Title
    title.TextColor3 = self.Config.Theme.Text
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local close = Instance.new("TextButton")
    close.Name = "Close"
    close.BackgroundTransparency = 1
    close.Position = UDim2.new(1, -30, 0, 0)
    close.Size = UDim2.new(0, 30, 1, 0)
    close.Font = Enum.Font.GothamBold
    close.Text = "×"
    close.TextColor3 = self.Config.Theme.Text
    close.TextSize = 20
    close.Parent = header
    
    -- Tab System
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.BackgroundColor3 = self.Config.Theme.Header
    tabContainer.BorderSizePixel = 0
    tabContainer.Position = UDim2.new(0, 0, 0, 30)
    tabContainer.Size = UDim2.new(1, 0, 0, 30)
    tabContainer.Parent = main
    
    local tabContent = Instance.new("Frame")
    tabContent.Name = "TabContent"
    tabContent.BackgroundColor3 = self.Config.Theme.Background
    tabContent.BorderSizePixel = 0
    tabContent.Position = UDim2.new(0, 0, 0, 60)
    tabContent.Size = UDim2.new(1, 0, 1, -60)
    tabContent.Parent = main
    
    -- Dragging functionality
    if self.Config.Draggable then
        local dragging, dragInput, dragStart, startPos
        
        local function update(input)
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
        
        header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = main.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        header.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)
        
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                update(input)
            end
        end)
    end
    
    -- Toggle UI visibility with keybind
    game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == self.Config.ToggleKey then
            screenGui.Enabled = not screenGui.Enabled
        end
    end)
    
    -- Close button functionality
    close.MouseButton1Click:Connect(function()
        screenGui.Enabled = false
    end)
    
    -- Tab functionality
    local tabs = {}
    local tabButtons = {}
    local currentTab = nil
    
    function PlexLibrary:AddTab(name)
        local tabButton = Instance.new("TextButton")
        tabButton.Name = name.."Tab"
        tabButton.BackgroundTransparency = 1
        tabButton.Size = UDim2.new(0, 100, 1, 0)
        tabButton.Font = Enum.Font.Gotham
        tabButton.Text = name
        tabButton.TextColor3 = self.Config.Theme.Text
        tabButton.TextSize = 14
        tabButton.Parent = tabContainer
        
        -- Position the tab button
        if #tabButtons > 0 then
            tabButton.Position = UDim2.new(0, 100 * #tabButtons, 0, 0)
        else
            tabButton.Position = UDim2.new(0, 0, 0, 0)
        end
        
        local tabFrame = Instance.new("ScrollingFrame")
        tabFrame.Name = name.."Content"
        tabFrame.BackgroundTransparency = 1
        tabFrame.BorderSizePixel = 0
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.ScrollBarThickness = 4
        tabFrame.ScrollBarImageColor3 = self.Config.Theme.Accent
        tabFrame.Visible = false
        tabFrame.Parent = tabContent
        
        -- Add padding and layout
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 10)
        padding.PaddingRight = UDim.new(0, 10)
        padding.PaddingTop = UDim.new(0, 10)
        padding.PaddingBottom = UDim.new(0, 10)
        padding.Parent = tabFrame
        
        local list = Instance.new("UIListLayout")
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Padding = UDim.new(0, 10)
        list.Parent = tabFrame
        
        -- Auto-size the content
        list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabFrame.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 20)
        end)
        
        table.insert(tabButtons, tabButton)
        
        -- Tab button click handler
        tabButton.MouseButton1Click:Connect(function()
            if currentTab then
                currentTab.Visible = false
            end
            tabFrame.Visible = true
            currentTab = tabFrame
            
            -- Update tab button styling
            for _, btn in ipairs(tabButtons) do
                if btn == tabButton then
                    btn.Font = Enum.Font.GothamBold
                    btn.TextColor3 = self.Config.Theme.Accent
                else
                    btn.Font = Enum.Font.Gotham
                    btn.TextColor3 = self.Config.Theme.Text
                end
            end
        end)
        
        -- Default to the first tab
        if #tabButtons == 1 then
            tabButton.Font = Enum.Font.GothamBold
            tabButton.TextColor3 = self.Config.Theme.Accent
            tabFrame.Visible = true
            currentTab = tabFrame
        end
        
        -- Element creation functions
        local tabElements = {}
        
        function tabElements:CreateSection(sectionName)
            local section = Instance.new("Frame")
            section.Name = sectionName.."Section"
            section.BackgroundColor3 = self.Config.Theme.Secondary
            section.BorderSizePixel = 0
            section.Size = UDim2.new(0.48, 0, 0, 120)
            section.Parent = tabFrame
            
            local sectionHeader = Instance.new("TextLabel")
            sectionHeader.Name = "Header"
            sectionHeader.BackgroundColor3 = self.Config.Theme.Accent
            sectionHeader.BorderSizePixel = 0
            sectionHeader.Size = UDim2.new(1, 0, 0, 25)
            sectionHeader.Font = Enum.Font.GothamBold
            sectionHeader.Text = sectionName
            sectionHeader.TextColor3 = self.Config.Theme.Text
            sectionHeader.TextSize = 14
            sectionHeader.Parent = section
            
            local sectionContent = Instance.new("Frame")
            sectionContent.Name = "Content"
            sectionContent.BackgroundTransparency = 1
            sectionContent.Position = UDim2.new(0, 0, 0, 25)
            sectionContent.Size = UDim2.new(1, 0, 1, -25)
            sectionContent.Parent = section
            
            local padding = Instance.new("UIPadding")
            padding.PaddingLeft = UDim.new(0, 8)
            padding.PaddingRight = UDim.new(0, 8)
            padding.PaddingTop = UDim.new(0, 8)
            padding.PaddingBottom = UDim.new(0, 8)
            padding.Parent = sectionContent
            
            local list = Instance.new("UIListLayout")
            list.SortOrder = Enum.SortOrder.LayoutOrder
            list.Padding = UDim.new(0, 6)
            list.Parent = sectionContent
            
            -- Auto-size the section based on content
            list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                section.Size = UDim2.new(0.48, 0, 0, list.AbsoluteContentSize.Y + 41)
            end)
            
            local sectionElements = {}
            
            function sectionElements:AddToggle(name, default, callback)
                local toggle = Instance.new("Frame")
                toggle.Name = name.."Toggle"
                toggle.BackgroundTransparency = 1
                toggle.Size = UDim2.new(1, 0, 0, 25)
                toggle.Parent = sectionContent
                
                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.BackgroundTransparency = 1
                label.Size = UDim2.new(1, -30, 1, 0)
                label.Font = Enum.Font.Gotham
                label.Text = name
                label.TextColor3 = self.Config.Theme.Text
                label.TextSize = 14
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = toggle
                
                local box = Instance.new("Frame")
                box.Name = "Box"
                box.BackgroundColor3 = self.Config.Theme.Background
                box.BorderSizePixel = 0
                box.Position = UDim2.new(1, -25, 0.5, -10)
                box.Size = UDim2.new(0, 20, 0, 20)
                box.Parent = toggle
                
                local value = default or false
                
                local function updateVisual()
                    if value then
                        box.BackgroundColor3 = self.Config.Theme.Accent
                    else
                        box.BackgroundColor3 = self.Config.Theme.Background
                    end
                end
                
                updateVisual()
                
                -- Clickable area
                local button = Instance.new("TextButton")
                button.Name = "Button"
                button.BackgroundTransparency = 1
                button.Size = UDim2.new(1, 0, 1, 0)
                button.Text = ""
                button.Parent = toggle
                
                button.MouseButton1Click:Connect(function()
                    value = not value
                    updateVisual()
                    if callback then callback(value) end
                end)
                
                return {
                    SetValue = function(newValue)
                        value = newValue
                        updateVisual()
                        if callback then callback(value) end
                    end,
                    GetValue = function()
                        return value
                    end
                }
            end
            
            function sectionElements:AddSlider(name, min, max, default, callback)
                local slider = Instance.new("Frame")
                slider.Name = name.."Slider"
                slider.BackgroundTransparency = 1
                slider.Size = UDim2.new(1, 0, 0, 45)
                slider.Parent = sectionContent
                
                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.BackgroundTransparency = 1
                label.Size = UDim2.new(1, 0, 0, 20)
                label.Font = Enum.Font.Gotham
                label.Text = name
                label.TextColor3 = self.Config.Theme.Text
                label.TextSize = 14
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = slider
                
                local value = default or min
                local valueDisplay = Instance.new("TextLabel")
                valueDisplay.Name = "Value"
                valueDisplay.BackgroundTransparency = 1
                valueDisplay.Position = UDim2.new(1, -40, 0, 0)
                valueDisplay.Size = UDim2.new(0, 40, 0, 20)
                valueDisplay.Font = Enum.Font.Gotham
                valueDisplay.Text = tostring(value)
                valueDisplay.TextColor3 = self.Config.Theme.Text
                valueDisplay.TextSize = 14
                valueDisplay.Parent = slider
                
                local sliderBG = Instance.new("Frame")
                sliderBG.Name = "Background"
                sliderBG.BackgroundColor3 = self.Config.Theme.Background
                sliderBG.BorderSizePixel = 0
                sliderBG.Position = UDim2.new(0, 0, 0, 25)
                sliderBG.Size = UDim2.new(1, 0, 0, 10)
                sliderBG.Parent = slider
                
                local fill = Instance.new("Frame")
                fill.Name = "Fill"
                fill.BackgroundColor3 = self.Config.Theme.Accent
                fill.BorderSizePixel = 0
                fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                fill.Parent = sliderBG
                
                local function updateSlider(newValue)
                    value = math.clamp(newValue, min, max)
                    valueDisplay.Text = tostring(value)
                    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                    if callback then callback(value) end
                end
                
                -- Slider interaction
                local button = Instance.new("TextButton")
                button.Name = "Button"
                button.BackgroundTransparency = 1
                button.Size = UDim2.new(1, 0, 1, 0)
                button.Text = ""
                button.Parent = sliderBG
                
                local dragging = false
                
                button.MouseButton1Down:Connect(function()
                    dragging = true
                end)
                
                game:GetService("UserInputService").InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                button.MouseMoved:Connect(function(x)
                    if dragging then
                        local relPos = math.clamp((x - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
                        local newValue = min + (max - min) * relPos
                        updateSlider(newValue)
                    end
                end)
                
                return {
                    SetValue = function(newValue)
                        updateSlider(newValue)
                    end,
                    GetValue = function()
                        return value
                    end
                }
            end
            
            function sectionElements:AddDropdown(name, options, default, callback)
                local dropdown = Instance.new("Frame")
                dropdown.Name = name.."Dropdown"
                dropdown.BackgroundTransparency = 1
                dropdown.Size = UDim2.new(1, 0, 0, 45)
                dropdown.ClipsDescendants = true
                dropdown.Parent = sectionContent
                
                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.BackgroundTransparency = 1
                label.Size = UDim2.new(1, 0, 0, 20)
                label.Font = Enum.Font.Gotham
                label.Text = name
                label.TextColor3 = self.Config.Theme.Text
                label.TextSize = 14
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = dropdown
                
                local selected = default or options[1] or "Select"
                
                local dropButton = Instance.new("TextButton")
                dropButton.Name = "Button"
                dropButton.BackgroundColor3 = self.Config.Theme.Background
                dropButton.BorderSizePixel = 0
                dropButton.Position = UDim2.new(0, 0, 0, 25)
                dropButton.Size = UDim2.new(1, 0, 0, 25)
                dropButton.Font = Enum.Font.Gotham
                dropButton.Text = "  " .. selected
                dropButton.TextColor3 = self.Config.Theme.Text
                dropButton.TextSize = 14
                dropButton.TextXAlignment = Enum.TextXAlignment.Left
                dropButton.Parent = dropdown
                
                local arrow = Instance.new("TextLabel")
                arrow.Name = "Arrow"
                arrow.BackgroundTransparency = 1
                arrow.Position = UDim2.new(1, -20, 0, 0)
                arrow.Size = UDim2.new(0, 20, 1, 0)
                arrow.Font = Enum.Font.Gotham
                arrow.Text = "▼"
                arrow.TextColor3 = self.Config.Theme.Text
                arrow.TextSize = 14
                arrow.Parent = dropButton
                
                local optionContainer = Instance.new("Frame")
                optionContainer.Name = "Options"
                optionContainer.BackgroundColor3 = self.Config.Theme.Background
                optionContainer.BorderSizePixel = 0
                optionContainer.Position = UDim2.new(0, 0, 0, 50)
                optionContainer.Size = UDim2.new(1, 0, 0, 0)
                optionContainer.Visible = false
                optionContainer.Parent = dropdown
                
                local list = Instance.new("UIListLayout")
                list.SortOrder = Enum.SortOrder.LayoutOrder
                list.Parent = optionContainer
                
                local opened = false
                
                local function toggleDropdown()
                    opened = not opened
                    if opened then
                        dropdown.Size = UDim2.new(1, 0, 0, 50 + (#options * 25))
                        optionContainer.Size = UDim2.new(1, 0, 0, #options * 25)
                        optionContainer.Visible = true
                        arrow.Text = "▲"
                    else
                        dropdown.Size = UDim2.new(1, 0, 0, 50)
                        optionContainer.Size = UDim2.new(1, 0, 0, 0)
                        optionContainer.Visible = false
                        arrow.Text = "▼"
                    end
                end
                
                dropButton.MouseButton1Click:Connect(toggleDropdown)
                
                for i, option in ipairs(options) do
                    local optionButton = Instance.new("TextButton")
                    optionButton.Name = option
                    optionButton.BackgroundColor3 = self.Config.Theme.Background
                    optionButton.BackgroundTransparency = 0
                    optionButton.BorderSizePixel = 0
                    optionButton.Size = UDim2.new(1, 0, 0, 25)
                    optionButton.Font = Enum.Font.Gotham
                    optionButton.Text = "  " .. option
                    optionButton.TextColor3 = self.Config.Theme.Text
                    optionButton.TextSize = 14
                    optionButton.TextXAlignment = Enum.TextXAlignment.Left
                    optionButton.Parent = optionContainer
                    
                    optionButton.MouseEnter:Connect(function()
                        optionButton.BackgroundColor3 = self.Config.Theme.Hover
                    end)
                    
                    optionButton.MouseLeave:Connect(function()
                        optionButton.BackgroundColor3 = self.Config.Theme.Background
                    end)
                    
                    optionButton.MouseButton1Click:Connect(function()
                        selected = option
                        dropButton.Text = "  " .. selected
                        toggleDropdown()
                        if callback then callback(selected) end
                    end)
                end
                
                return {
                    SetValue = function(newValue)
                        if table.find(options, newValue) then
                            selected = newValue
                            dropButton.Text = "  " .. selected
                            if callback then callback(selected) end
                        end
                    end,
                    GetValue = function()
                        return selected
                    end
                }
            end
            
            function sectionElements:AddButton(name, callback)
                local button = Instance.new("TextButton")
                button.Name = name.."Button"
                button.BackgroundColor3 = self.Config.Theme.Secondary
                button.BorderSizePixel = 0
                button.Size = UDim2.new(1, 0, 0, 30)
                button.Font = Enum.Font.GothamBold
                button.Text = name
                button.TextColor3 = self.Config.Theme.Text
                button.TextSize = 14
                button.Parent = sectionContent
                
                button.MouseEnter:Connect(function()
                    button.BackgroundColor3 = self.Config.Theme.Hover
                end)
                
                button.MouseLeave:Connect(function()
                    button.BackgroundColor3 = self.Config.Theme.Secondary
                end)
                
                button.MouseButton1Click:Connect(function()
                    if callback then callback() end
                end)
            end
            
            function sectionElements:AddTextbox(name, placeholder, callback)
                local textbox = Instance.new("Frame")
                textbox.Name = name.."Textbox"
                textbox.BackgroundTransparency = 1
                textbox.Size = UDim2.new(1, 0, 0, 45)
                textbox.Parent = sectionContent
                
                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.BackgroundTransparency = 1
                label.Size = UDim2.new(1, 0, 0, 20)
                label.Font = Enum.Font.Gotham
                label.Text = name
                label.TextColor3 = self.Config.Theme.Text
                label.TextSize = 14
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = textbox
                
                local inputBox = Instance.new("TextBox")
                inputBox.Name = "Input"
                inputBox.BackgroundColor3 = self.Config.Theme.Background
                inputBox.BorderSizePixel = 0
                inputBox.Position = UDim2.new(0, 0, 0, 25)
                inputBox.Size = UDim2.new(1, 0, 0, 25)
                inputBox.Font = Enum.Font.Gotham
                inputBox.PlaceholderText = placeholder or "Enter text..."
                inputBox.Text = ""
                inputBox.TextColor3 = self.Config.Theme.Text
                inputBox.TextSize = 14
                inputBox.Parent = textbox
                
                inputBox.FocusLost:Connect(function(enterPressed)
                    if enterPressed and callback then
                        callback(inputBox.Text)
                    end
                end)
                
                return {
                    GetText = function()
                        return inputBox.Text
                    end,
                    SetText = function(text)
                        inputBox.Text = text
                    end
                }
            end
            
            return sectionElements
        end
        
        return tabElements
    end
    
    -- Initialize the UI
    if game:GetService("RunService"):IsStudio() then
        screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    else
        screenGui.Parent = game:GetService("CoreGui")
    end
    
    return PlexLibrary
end

return PlexUI
