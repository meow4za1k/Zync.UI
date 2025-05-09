local ZyncUI = {}
ZyncUI.__index = ZyncUI

-- Utility functions
local function Tween(object, properties, duration)
    local tweenInfo = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local tween = game:GetService("TweenService"):Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

function ZyncUI.new(title)
    local self = setmetatable({}, ZyncUI)
    
    -- Main GUI Components
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "ZyncUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = game:GetService("CoreGui")
    
    -- Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, 600, 0, 450)
    self.MainFrame.Position = UDim2.new(0.5, -300, 0.5, -225)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    self.MainFrame.BorderSizePixel = 1
    self.MainFrame.BorderColor3 = Color3.fromRGB(40, 40, 40)
    self.MainFrame.Parent = self.ScreenGui
    
    -- Title Bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 30)
    self.TitleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.MainFrame
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -10, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Zync.pmo | Premium"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamSemibold
    titleLabel.TextSize = 14
    titleLabel.Parent = self.TitleBar
    
    -- Tab Container
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(1, 0, 0, 30)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 30)
    self.TabContainer.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.Parent = self.MainFrame
    
    -- Tabs
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 0)
    tabLayout.Parent = self.TabContainer
    
    -- Content Frame
    self.ContentFrame = Instance.new("Frame")
    self.ContentFrame.Name = "ContentFrame"
    self.ContentFrame.Size = UDim2.new(1, 0, 1, -60)
    self.ContentFrame.Position = UDim2.new(0, 0, 0, 60)
    self.ContentFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    self.ContentFrame.BorderSizePixel = 0
    self.ContentFrame.Parent = self.MainFrame
    
    -- Initialize tabs
    self.Tabs = {}
    self.ActiveTab = nil
    
    -- Make UI draggable
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
        end
    end)
    
    self.TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    game:GetService("RunService").RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            self.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    return self
end

function ZyncUI:AddTab(name)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "Tab"
    tabButton.Size = UDim2.new(0, 90, 1, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    tabButton.BorderSizePixel = 0
    tabButton.Text = name
    tabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
    tabButton.Font = Enum.Font.Gotham
    tabButton.TextSize = 13
    tabButton.Parent = self.TabContainer
    
    local tabContent = Instance.new("Frame")
    tabContent.Name = name .. "Content"
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false
    tabContent.Parent = self.ContentFrame
    
    -- Create a grid layout for the sections
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0, 270, 0, 0) -- Width fixed, height dynamic
    gridLayout.CellPadding = UDim2.new(0, 15, 0, 15)
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.Parent = tabContent
    
    -- Add padding
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.PaddingTop = UDim.new(0, 15)
    padding.PaddingBottom = UDim.new(0, 15)
    padding.Parent = tabContent
    
    local tab = {
        Button = tabButton,
        Content = tabContent,
        Name = name,
        Sections = {}
    }
    
    table.insert(self.Tabs, tab)
    
    tabButton.MouseButton1Click:Connect(function()
        self:SelectTab(name)
    end)
    
    if #self.Tabs == 1 then
        self:SelectTab(name)
    end
    
    local tabMethods = {}
    
    function tabMethods:AddSection(sectionName)
        local sectionFrame = Instance.new("Frame")
        sectionFrame.Name = sectionName .. "Section"
        sectionFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        sectionFrame.BorderSizePixel = 0
        sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
        sectionFrame.Parent = tabContent
        
        -- Section header
        local headerFrame = Instance.new("Frame")
        headerFrame.Name = "Header"
        headerFrame.Size = UDim2.new(1, 0, 0, 30)
        headerFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        headerFrame.BorderSizePixel = 0
        headerFrame.Parent = sectionFrame
        
        local headerLabel = Instance.new("TextLabel")
        headerLabel.Name = "HeaderLabel"
        headerLabel.Size = UDim2.new(1, -10, 1, 0)
        headerLabel.Position = UDim2.new(0, 10, 0, 0)
        headerLabel.BackgroundTransparency = 1
        headerLabel.Text = sectionName
        headerLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
        headerLabel.TextXAlignment = Enum.TextXAlignment.Left
        headerLabel.Font = Enum.Font.GothamSemibold
        headerLabel.TextSize = 14
        headerLabel.Parent = headerFrame
        
        -- Section content
        local contentFrame = Instance.new("Frame")
        contentFrame.Name = "Content"
        contentFrame.Size = UDim2.new(1, 0, 0, 0)
        contentFrame.Position = UDim2.new(0, 0, 0, 30)
        contentFrame.BackgroundTransparency = 1
        contentFrame.AutomaticSize = Enum.AutomaticSize.Y
        contentFrame.Parent = sectionFrame
        
        -- Layout for content
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 5)
        contentLayout.Parent = contentFrame
        
        -- Padding for content
        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingLeft = UDim.new(0, 10)
        contentPadding.PaddingRight = UDim.new(0, 10)
        contentPadding.PaddingTop = UDim.new(0, 10)
        contentPadding.PaddingBottom = UDim.new(0, 10)
        contentPadding.Parent = contentFrame
        
        local section = {
            Frame = sectionFrame,
            Content = contentFrame
        }
        
        local sectionMethods = {}
        
        function sectionMethods:AddToggle(name, default, callback)
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Name = name .. "Toggle"
            toggleFrame.Size = UDim2.new(1, 0, 0, 25)
            toggleFrame.BackgroundTransparency = 1
            toggleFrame.Parent = contentFrame
            
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1, -25, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = name
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.Gotham
            label.TextSize = 13
            label.Parent = toggleFrame
            
            local checkbox = Instance.new("Frame")
            checkbox.Name = "Checkbox"
            checkbox.Size = UDim2.new(0, 16, 0, 16)
            checkbox.Position = UDim2.new(1, -16, 0.5, -8)
            checkbox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            checkbox.BorderSizePixel = 0
            checkbox.Parent = toggleFrame
            
            local enabled = default or false
            
            local function updateToggle()
                checkbox.BackgroundColor3 = enabled and Color3.fromRGB(60, 60, 180) or Color3.fromRGB(40, 40, 45)
                if callback then callback(enabled) end
            end
            
            toggleFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    enabled = not enabled
                    updateToggle()
                end
            end)
            
            updateToggle() -- Initialize state
            
            return {
                Frame = toggleFrame,
                SetValue = function(self, value)
                    enabled = value
                    updateToggle()
                end,
                GetValue = function(self)
                    return enabled
                end
            }
        end
        
        function sectionMethods:AddSlider(name, min, max, default, callback)
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Name = name .. "Slider"
            sliderFrame.Size = UDim2.new(1, 0, 0, 40)
            sliderFrame.BackgroundTransparency = 1
            sliderFrame.Parent = contentFrame
            
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(0.7, 0, 0, 20)
            label.BackgroundTransparency = 1
            label.Text = name
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.Gotham
            label.TextSize = 13
            label.Parent = sliderFrame
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Name = "Value"
            valueLabel.Size = UDim2.new(0.3, 0, 0, 20)
            valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = default .. "/" .. max
            valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Font = Enum.Font.Gotham
            valueLabel.TextSize = 13
            valueLabel.Parent = sliderFrame
            
            local sliderBack = Instance.new("Frame")
            sliderBack.Name = "Back"
            sliderBack.Size = UDim2.new(1, 0, 0, 5)
            sliderBack.Position = UDim2.new(0, 0, 0, 25)
            sliderBack.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            sliderBack.BorderSizePixel = 0
            sliderBack.Parent = sliderFrame
            
            local sliderFill = Instance.new("Frame")
            sliderFill.Name = "Fill"
            sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            sliderFill.BackgroundColor3 = Color3.fromRGB(60, 60, 180)
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderBack
            
            local value = default
            local dragging = false
            
            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)
                value = math.floor(min + (max - min) * pos)
                sliderFill.Size = UDim2.new(pos, 0, 1, 0)
                valueLabel.Text = value .. "/" .. max
                if callback then callback(value) end
            end
            
            sliderBack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateSlider(input)
                end
            end)
            
            sliderBack.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            game:GetService("UserInputService").InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input)
                end
            end)
            
            return {
                Frame = sliderFrame,
                SetValue = function(self, newValue)
                    value = math.clamp(newValue, min, max)
                    local pos = (value - min) / (max - min)
                    sliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    valueLabel.Text = value .. "/" .. max
                    if callback then callback(value) end
                end,
                GetValue = function(self)
                    return value
                end
            }
        end
        
        function sectionMethods:AddDropdown(name, options, default, callback)
            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Name = name .. "Dropdown"
            dropdownFrame.Size = UDim2.new(1, 0, 0, 45)
            dropdownFrame.BackgroundTransparency = 1
            dropdownFrame.Parent = contentFrame
            
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1, 0, 0, 20)
            label.BackgroundTransparency = 1
            label.Text = name
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.Gotham
            label.TextSize = 13
            label.Parent = dropdownFrame
            
            local selectedOption = default or options[1] or "Select..."
            
            local dropButton = Instance.new("TextButton")
            dropButton.Name = "DropButton"
            dropButton.Size = UDim2.new(1, 0, 0, 20)
            dropButton.Position = UDim2.new(0, 0, 0, 25)
            dropButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            dropButton.BorderSizePixel = 0
            dropButton.Text = "  " .. selectedOption
            dropButton.TextColor3 = Color3.fromRGB(200, 200, 200)
            dropButton.TextXAlignment = Enum.TextXAlignment.Left
            dropButton.Font = Enum.Font.Gotham
            dropButton.TextSize = 13
            dropButton.Parent = dropdownFrame
            
            local arrowLabel = Instance.new("TextLabel")
            arrowLabel.Name = "Arrow"
            arrowLabel.Size = UDim2.new(0, 20, 0, 20)
            arrowLabel.Position = UDim2.new(1, -20, 0, 0)
            arrowLabel.BackgroundTransparency = 1
            arrowLabel.Text = "▼"
            arrowLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            arrowLabel.Font = Enum.Font.Gotham
            arrowLabel.TextSize = 11
            arrowLabel.Parent = dropButton
            
            local dropMenu = Instance.new("Frame")
            dropMenu.Name = "DropMenu"
            dropMenu.Size = UDim2.new(1, 0, 0, 0) -- Will expand when opened
            dropMenu.Position = UDim2.new(0, 0, 1, 0)
            dropMenu.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            dropMenu.BorderSizePixel = 0
            dropMenu.ClipsDescendants = true
            dropMenu.Visible = false
            dropMenu.ZIndex = 5
            dropMenu.Parent = dropButton
            
            local menuLayout = Instance.new("UIListLayout")
            menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
            menuLayout.Parent = dropMenu
            
            local open = false
            
            local function createOption(optionName)
                local optionButton = Instance.new("TextButton")
                optionButton.Name = optionName
                optionButton.Size = UDim2.new(1, 0, 0, 20)
                optionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
                optionButton.BorderSizePixel = 0
                optionButton.Text = "  " .. optionName
                optionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                optionButton.TextXAlignment = Enum.TextXAlignment.Left
                optionButton.Font = Enum.Font.Gotham
                optionButton.TextSize = 13
                optionButton.ZIndex = 6
                optionButton.Parent = dropMenu
                
                optionButton.MouseButton1Click:Connect(function()
                    selectedOption = optionName
                    dropButton.Text = "  " .. selectedOption
                    if callback then callback(selectedOption) end
                    
                    -- Close the dropdown
                    open = false
                    Tween(dropMenu, {Size = UDim2.new(1, 0, 0, 0)}, 0.2).Completed:Connect(function()
                        if not open then dropMenu.Visible = false end
                    end)
                    arrowLabel.Text = "▼"
                end)
                
                return optionButton
            end
            
            -- Create option buttons
            for _, option in ipairs(options) do
                createOption(option)
            end
            
            -- Toggle dropdown visibility
            dropButton.MouseButton1Click:Connect(function()
                open = not open
                
                if open then
                    dropMenu.Visible = true
                    Tween(dropMenu, {Size = UDim2.new(1, 0, 0, math.min(#options * 20, 100))}, 0.2)
                    arrowLabel.Text = "▲"
                else
                    Tween(dropMenu, {Size = UDim2.new(1, 0, 0, 0)}, 0.2).Completed:Connect(function()
                        if not open then dropMenu.Visible = false end
                    end)
                    arrowLabel.Text = "▼"
                end
            end)
            
            return {
                Frame = dropdownFrame,
                SetValue = function(self, value)
                    if table.find(options, value) then
                        selectedOption = value
                        dropButton.Text = "  " .. selectedOption
                        if callback then callback(selectedOption) end
                    end
                end,
                GetValue = function(self)
                    return selectedOption
                end,
                SetOptions = function(self, newOptions)
                    -- Clear current options
                    for _, child in pairs(dropMenu:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    -- Add new options
                    for _, option in ipairs(newOptions) do
                        createOption(option)
                    end
                    
                    options = newOptions
                    
                    -- Reset selection if current value is not in the new options
                    if not table.find(newOptions, selectedOption) then
                        selectedOption = newOptions[1] or "Select..."
                        dropButton.Text = "  " .. selectedOption
                        if callback then callback(selectedOption) end
                    end
                end
            }
        end
        
        function sectionMethods:AddTextBox(name, default, callback)
            local textboxFrame = Instance.new("Frame")
            textboxFrame.Name = name .. "TextBox"
            textboxFrame.Size = UDim2.new(1, 0, 0, 45)
            textboxFrame.BackgroundTransparency = 1
            textboxFrame.Parent = contentFrame
            
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1, 0, 0, 20)
            label.BackgroundTransparency = 1
            label.Text = name
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.Gotham
            label.TextSize = 13
            label.Parent = textboxFrame
            
            local inputBox = Instance.new("TextBox")
            inputBox.Name = "Input"
            inputBox.Size = UDim2.new(1, 0, 0, 20)
            inputBox.Position = UDim2.new(0, 0, 0, 25)
            inputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            inputBox.BorderSizePixel = 0
            inputBox.Text = default or ""
            inputBox.TextColor3 = Color3.fromRGB(200, 200, 200)
            inputBox.TextXAlignment = Enum.TextXAlignment.Left
            inputBox.Font = Enum.Font.Gotham
            inputBox.TextSize = 13
            inputBox.PlaceholderText = "Enter text..."
            inputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
            inputBox.ClearTextOnFocus = false
            
            -- Add some padding
            local padding = Instance.new("UIPadding")
            padding.PaddingLeft = UDim.new(0, 5)
            padding.Parent = inputBox
            
            inputBox.Parent = textboxFrame
            
            inputBox.FocusLost:Connect(function(enterPressed)
                if callback then
                    callback(inputBox.Text)
                end
            end)
            
            return {
                Frame = textboxFrame,
                SetValue = function(self, value)
                    inputBox.Text = value or ""
                    if callback then callback(inputBox.Text) end
                end,
                GetValue = function(self)
                    return inputBox.Text
                end
            }
        end
        
        return sectionMethods
    end
    
    return tabMethods
end

function ZyncUI:SelectTab(name)
    for _, tab in pairs(self.Tabs) do
        local isSelected = (tab.Name == name)
        tab.Button.BackgroundColor3 = isSelected and Color3.fromRGB(18, 18, 18) or Color3.fromRGB(22, 22, 22)
        tab.Button.TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
        tab.Content.Visible = isSelected
        
        if isSelected then
            self.ActiveTab = tab
        end
    end
end

return ZyncUI
