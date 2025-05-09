You're absolutely right. Let me redesign the UI library to match the image much more closely:


local ZyncUI = {}

-- Core Configuration
ZyncUI.Config = {
    Title = "Zync.pmo | Premium",
    Theme = {
        Background = Color3.fromRGB(25, 25, 25),
        MainBackground = Color3.fromRGB(15, 15, 15),
        SectionBackground = Color3.fromRGB(20, 20, 20),
        Text = Color3.fromRGB(255, 255, 255),
        SectionTitle = Color3.fromRGB(80, 80, 255),
        TabText = Color3.fromRGB(255, 255, 255),
        TabSelected = Color3.fromRGB(255, 255, 255),
        TabBackground = Color3.fromRGB(25, 25, 25),
        BorderColor = Color3.fromRGB(40, 40, 40),
    },
    ToggleKey = Enum.KeyCode.RightShift,
}

function ZyncUI:Create()
    local UI = {}
    
    -- Create base GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ZyncUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.BackgroundColor3 = self.Config.Theme.Background
    main.BorderColor3 = self.Config.Theme.BorderColor
    main.BorderSizePixel = 1
    main.Position = UDim2.new(0.5, -300, 0.5, -200)
    main.Size = UDim2.new(0, 600, 0, 400)
    main.Parent = screenGui
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.BackgroundColor3 = self.Config.Theme.Background
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
    
    -- Tab container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.BackgroundColor3 = self.Config.Theme.Background
    tabContainer.BorderSizePixel = 0
    tabContainer.Position = UDim2.new(0, 0, 0, 30)
    tabContainer.Size = UDim2.new(1, 0, 0, 30)
    tabContainer.Parent = main
    
    -- Tab Content Container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.BackgroundColor3 = self.Config.Theme.MainBackground
    contentContainer.BorderSizePixel = 0
    contentContainer.Position = UDim2.new(0, 0, 0, 60)
    contentContainer.Size = UDim2.new(1, 0, 1, -60)
    contentContainer.Parent = main
    
    -- Dragging functionality
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function updateDrag(input)
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
            updateDrag(input)
        end
    end)
    
    -- Toggle visibility with keybind
    game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == self.Config.ToggleKey then
            screenGui.Enabled = not screenGui.Enabled
        end
    end)
    
    -- Tab system
    local tabs = {}
    local tabButtons = {}
    local currentTab = nil
    
    function UI:AddTab(name)
        local tabButton = Instance.new("TextButton")
        tabButton.Name = name .. "Tab"
        tabButton.BackgroundColor3 = self.Config.Theme.TabBackground
        tabButton.BorderSizePixel = 0
        tabButton.Size = UDim2.new(0, 100, 1, 0)
        tabButton.Font = Enum.Font.Gotham
        tabButton.Text = name
        tabButton.TextColor3 = self.Config.Theme.TabText
        tabButton.TextSize = 14
        tabButton.Parent = tabContainer
        
        -- Position the tab based on existing tabs
        if #tabButtons > 0 then
            tabButton.Position = UDim2.new(0, #tabButtons * 100, 0, 0)
        end
        
        -- Create tab content
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = name .. "Content"
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.ScrollBarThickness = 2
        tabContent.ScrollingDirection = Enum.ScrollingDirection.Y
        tabContent.Visible = false
        tabContent.Parent = contentContainer
        
        -- Tab click handling
        tabButton.MouseButton1Click:Connect(function()
            if currentTab then
                currentTab.Visible = false
            end
            
            for _, btn in pairs(tabButtons) do
                btn.Font = Enum.Font.Gotham
                btn.TextColor3 = self.Config.Theme.TabText
            end
            
            tabButton.Font = Enum.Font.GothamBold
            tabButton.TextColor3 = self.Config.Theme.TabSelected
            
            tabContent.Visible = true
            currentTab = tabContent
        end)
        
        table.insert(tabButtons, tabButton)
        
        -- Select first tab by default
        if #tabButtons == 1 then
            tabButton.Font = Enum.Font.GothamBold
            tabButton.TextColor3 = self.Config.Theme.TabSelected
            tabContent.Visible = true
            currentTab = tabContent
        end
        
        -- Grid layout for sections 
        local gridLayout = Instance.new("UIGridLayout")
        gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
        gridLayout.CellSize = UDim2.new(0.5, -15, 0, 0) -- Sections take up half width
        gridLayout.Parent = tabContent
        
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim2.new(0, 10)
        padding.PaddingRight = UDim2.new(0, 10)
        padding.PaddingTop = UDim2.new(0, 10)
        padding.PaddingBottom = UDim2.new(0, 10)
        padding.Parent = tabContent
        
        -- Tab methods
        local TabMethods = {}
        
        function TabMethods:CreateSection(name)
            local section = Instance.new("Frame")
            section.Name = name .. "Section"
            section.BackgroundColor3 = self.Config.Theme.SectionBackground
            section.BorderColor3 = self.Config.Theme.BorderColor
            section.BorderSizePixel = 1
            section.AutomaticSize = Enum.AutomaticSize.Y
            section.Size = UDim2.new(1, 0, 0, 0)
            section.Parent = tabContent
            
            -- Section header
            local header = Instance.new("TextLabel")
            header.Name = "Header"
            header.BackgroundColor3 = self.Config.Theme.SectionTitle
            header.BorderSizePixel = 0
            header.Size = UDim2.new(1, 0, 0, 24)
            header.Font = Enum.Font.GothamBold
            header.Text = name
            header.TextColor3 = self.Config.Theme.Text
            header.TextSize = 14
            header.Parent = section
            
            -- Section content frame
            local content = Instance.new("Frame")
            content.Name = "Content"
            content.BackgroundTransparency = 1
            content.Position = UDim2.new(0, 0, 0, 24)
            content.Size = UDim2.new(1, 0, 0, 0)
            content.AutomaticSize = Enum.AutomaticSize.Y
            content.Parent = section
            
            -- Content layout
            local listLayout = Instance.new("UIListLayout")
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Padding = UDim.new(0, 5)
            listLayout.Parent = content
            
            -- Content padding
            local padding = Instance.new("UIPadding")
            padding.PaddingLeft = UDim.new(0, 8)
            padding.PaddingRight = UDim.new(0, 8)
            padding.PaddingTop = UDim.new(0, 8)
            padding.PaddingBottom = UDim.new(0, 8)
            padding.Parent = content
            
            -- Update section size when content changes
            listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                content.Size = UDim2.new(1, 0, 0, listLayout.AbsoluteContentSize.Y + 16)
                section.Size = UDim2.new(1, 0, 0, content.Size.Y.Offset + 24)
                
                -- Update canvas size
                local totalHeight = 0
                for _, child in pairs(tabContent:GetChildren()) do
                    if child:IsA("Frame") and child.Name:find("Section$") then
                        totalHeight = totalHeight + child.AbsoluteSize.Y + gridLayout.CellPadding.Y.Offset
                    end
                end
                tabContent.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
            end)
            
            -- Section methods
            local SectionMethods = {}
            
            function SectionMethods:AddToggle(name, default, callback)
                local toggle = Instance.new("Frame")
                toggle.Name = name .. "Toggle"
                toggle.BackgroundTransparency = 1
                toggle.Size = UDim2.new(1, 0, 0, 20)
                toggle.Parent = content
                
                local checkbox = Instance.new("Frame")
                checkbox.Name = "Checkbox"
                checkbox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                checkbox.BorderColor3 = Color3.fromRGB(60, 60, 60)
                checkbox.BorderSizePixel = 1
                checkbox.Position = UDim2.new(0, 0, 0, 0)
                checkbox.Size = UDim2.new(0, 16, 0, 16)
                checkbox.Parent = toggle
                
                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.BackgroundTransparency = 1
                label.Position = UDim2.new(0, 24, 0, 0)
                label.Size = UDim2.new(1, -24, 1, 0)
                label.Font = Enum.Font.Gotham
                label.Text = name
                label.TextColor3 = self.Config.Theme.Text
                label.TextSize = 14
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = toggle
                
                local value = default or false
                
                local function updateToggle()
                    if value then
                        checkbox.BackgroundColor3 = self.Config.Theme.SectionTitle
                    else
                        checkbox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    end
                end
                
                updateToggle()
                
                local button = Instance.new("TextButton")
                button.Name = "Button"
                button.BackgroundTransparency = 1
                button.Size = UDim2.new(1, 0, 1, 0)
                button.Text = ""
                button.Parent = toggle
                
                button.MouseButton1Click:Connect(function()
                    value = not value
                    updateToggle()
                    if callback then callback(value) end
                end)
                
                return {
                    SetValue = function(newValue)
                        value = newValue
                        updateToggle()
                        if callback then callback(value) end
                    end,
                    GetValue = function()
                        return value
                    end
                }
            end
            
            function SectionMethods:AddSlider(name, min, max, default, callback)
                local slider = Instance.new("Frame")
                slider.Name = name .. "Slider"
                slider.BackgroundTransparency = 1
                slider.Size = UDim2.new(1, 0, 0, 35)
                slider.Parent = content
                
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
                
                local valueDisplay = Instance.new("TextLabel")
                valueDisplay.Name = "Value"
                valueDisplay.BackgroundTransparency = 1
                valueDisplay.Position = UDim2.new(1, -40, 0, 0)
                valueDisplay.Size = UDim2.new(0, 40, 0, 20)
                valueDisplay.Font = Enum.Font.Gotham
                valueDisplay.Text = tostring(default or min) .. "/" .. tostring(max)
                valueDisplay.TextColor3 = self.Config.Theme.Text
                valueDisplay.TextSize = 14
                valueDisplay.TextXAlignment = Enum.TextXAlignment.Right
                valueDisplay.Parent = slider
                
                local sliderFrame = Instance.new("Frame")
                sliderFrame.Name = "SliderFrame"
                sliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                sliderFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
                sliderFrame.BorderSizePixel = 1
                sliderFrame.Position = UDim2.new(0, 0, 0, 25)
                sliderFrame.Size = UDim2.new(1, 0, 0, 8)
                sliderFrame.Parent = slider
                
                local fill = Instance.new("Frame")
                fill.Name = "Fill"
                fill.BackgroundColor3 = self.Config.Theme.SectionTitle
                fill.BorderSizePixel = 0
                fill.Size = UDim2.new(0, 0, 1, 0)
                fill.Parent = sliderFrame
                
                local value = default or min
                
                local function updateSlider(newValue)
                    value = math.clamp(newValue, min, max)
                    local percentage = (value - min) / (max - min)
                    fill.Size = UDim2.new(percentage, 0, 1, 0)
                    valueDisplay.Text = tostring(value) .. "/" .. tostring(max)
                    if callback then callback(value) end
                end
                
                updateSlider(value)
                
                local button = Instance.new("TextButton")
                button.Name = "Button"
                button.BackgroundTransparency = 1
                button.Size = UDim2.new(1, 0, 1, 0)
                button.Text = ""
                button.Parent = sliderFrame
                
                local dragging = false
                
                button.MouseButton1Down:Connect(function()
                    dragging = true
                end)
                
                game:GetService("UserInputService").InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                game:GetService("UserInputService").InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                        local framePos = sliderFrame.AbsolutePosition
                        local frameSize = sliderFrame.AbsoluteSize
                        
                        local relativeX = math.clamp((mousePos.X - framePos.X) / frameSize.X, 0, 1)
                        local newValue = min + (max - min) * relativeX
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
            
            function SectionMethods:AddDropdown(name, options, default, callback)
                local dropdown = Instance.new("Frame")
                dropdown.Name = name .. "Dropdown"
                dropdown.BackgroundTransparency = 1
                dropdown.Size = UDim2.new(1, 0, 0, 20)
                dropdown.Parent = content
                
                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.BackgroundTransparency = 1
                label.Size = UDim2.new(1, 0, 1, 0)
                label.Font = Enum.Font.Gotham
                label.Text = name
                label.TextColor3 = self.Config.Theme.Text
                label.TextSize = 14
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = dropdown
                
                local selected = Instance.new("TextLabel")
                selected.Name = "Selected"
                selected.BackgroundTransparency = 1
                selected.Position = UDim2.new(1, -100, 0, 0)
                selected.Size = UDim2.new(0, 80, 1, 0)
                selected.Font = Enum.Font.Gotham
                selected.Text = default or options[1]
                selected.TextColor3 = self.Config.Theme.Text
                selected.TextSize = 14
                selected.TextXAlignment = Enum.TextXAlignment.Right
                selected.Parent = dropdown
                
                local arrow = Instance.new("TextLabel")
                arrow.Name = "Arrow"
                arrow.BackgroundTransparency = 1
                arrow.Position = UDim2.new(1, -15, 0, 0)
                arrow.Size = UDim2.new(0, 15, 1, 0)
                arrow.Font = Enum.Font.Gotham
                arrow.Text = "▼"
                arrow.TextColor3 = self.Config.Theme.Text
                arrow.TextSize = 12
                arrow.Parent = dropdown
                
                local button = Instance.new("TextButton")
                button.Name = "Button"
                button.BackgroundTransparency = 1
                button.Size = UDim2.new(1, 0, 1, 0)
                button.Text = ""
                button.Parent = dropdown
                
                local selectedValue = default or options[1]
                
                button.MouseButton1Click:Connect(function()
                    local menu = Instance.new("Frame")
                    menu.Name = "DropdownMenu"
                    menu.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    menu.BorderColor3 = Color3.fromRGB(60, 60, 60)
                    menu.BorderSizePixel = 1
                    menu.Position = UDim2.new(0, 0, 1, 5)
                    menu.Size = UDim2.new(1, 0, 0, #options * 25)
                    menu.ZIndex = 10
                    menu.Parent = dropdown
                    
                    local listLayout = Instance.new("UIListLayout")
                    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    listLayout.Parent = menu
                    
                    for i, option in ipairs(options) do
                        local optionButton = Instance.new("TextButton")
                        optionButton.Name = option
                        optionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                        optionButton.BackgroundTransparency = 0
                        optionButton.BorderSizePixel = 0
                        optionButton.Size = UDim2.new(1, 0, 0, 25)
                        optionButton.Font = Enum.Font.Gotham
                        optionButton.Text = option
                        optionButton.TextColor3 = self.Config.Theme.Text
                        optionButton.TextSize = 14
                        optionButton.ZIndex = 10
                        optionButton.Parent = menu
                        
                        optionButton.MouseEnter:Connect(function()
                            optionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                        end)
                        
                        optionButton.MouseLeave:Connect(function()
                            optionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                        end)
                        
                        optionButton.MouseButton1Click:Connect(function()
                            selectedValue = option
                            selected.Text = option
                            menu:Destroy()
                            if callback then callback(option) end
                        end)
                    end
                    
                    -- Close dropdown when clicking elsewhere
                    local function closeMenu()
                        if menu and menu.Parent then
                            menu:Destroy()
                        end
                    end
                    
                    local closeConnection
                    closeConnection = game:GetService("UserInputService").InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            closeMenu()
                            closeConnection:Disconnect()
                        end
                    end)
                end)
                
                return {
                    SetValue = function(newValue)
                        if table.find(options, newValue) then
                            selectedValue = newValue
                            selected.Text = newValue
                            if callback then callback(newValue) end
                        end
                    end,
                    GetValue = function()
                        return selectedValue
                    end
                }
            end
            
            function SectionMethods:AddButton(name, callback)
                local button = Instance.new("Frame")
                button.Name = name .. "Button"
                button.BackgroundTransparency = 1
                button.Size = UDim2.new(1, 0, 0, 25)
                button.Parent = content
                
                local buttonElement = Instance.new("TextButton")
                buttonElement.Name = "ButtonElement"
                buttonElement.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                buttonElement.BorderColor3 = Color3.fromRGB(60, 60, 60)
                buttonElement.BorderSizePixel = 1
                buttonElement.Size = UDim2.new(1, 0, 1, 0)
                buttonElement.Font = Enum.Font.Gotham
                buttonElement.Text = name
                buttonElement.TextColor3 = self.Config.Theme.Text
                buttonElement.TextSize = 14
                buttonElement.Parent = button
                
                buttonElement.MouseEnter:Connect(function()
                    buttonElement.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                end)
                
                buttonElement.MouseLeave:Connect(function()
                    buttonElement.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                end)
                
                buttonElement.MouseButton1Click:Connect(function()
                    if callback then callback() end
                end)
            end
            
            function SectionMethods:AddTextbox(name, placeholder, callback)
                local textbox = Instance.new("Frame")
                textbox.Name = name .. "Textbox"
                textbox.BackgroundTransparency = 1
                textbox.Size = UDim2.new(1, 0, 0, 20)
                textbox.Parent = content
                
                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.BackgroundTransparency = 1
                label.Size = UDim2.new(0.5, -5, 1, 0)
                label.Font = Enum.Font.Gotham
                label.Text = name
                label.TextColor3 = self.Config.Theme.Text
                label.TextSize = 14
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = textbox
                
                local inputBox = Instance.new("TextBox")
                inputBox.Name = "Input"
                inputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                inputBox.BorderColor3 = Color3.fromRGB(60, 60, 60)
                inputBox.BorderSizePixel = 1
                inputBox.Position = UDim2.new(0.5, 0, 0, 0)
                inputBox.Size = UDim2.new(0.5, 0, 1, 0)
                inputBox.Font = Enum.Font.Gotham
                inputBox.PlaceholderText = placeholder or ""
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
            
            return SectionMethods
        end
        
        return TabMethods
    end
    
    -- Parent the ScreenGui
    if game:GetService("RunService"):IsStudio() then
        screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    else
        screenGui.Parent = game:GetService("CoreGui")
    end
    
    return UI
end

return ZyncUI
