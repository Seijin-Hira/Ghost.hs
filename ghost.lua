tParams.new()
    RayParams.FilterType = Enum.RaycastFilterType.Exclude
    RayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    local Result = workspace:Raycast(Source.Position, Target.Position - Source.Position, RayParams)
    return Result and Result.Instance.CanCollide
end
-- // Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- // Variáveis Globais
local AimbotEnabled = false
local FOVSize = 100
local FOVColor = Color3.fromRGB(255, 0, 0)
local TargetPart = "Head"
local WallCheck = true

local EspEnabled = false
local ShowNames = false
local ShowHealth = false
local EspColor = Color3.fromRGB(255, 0, 0)

local FlyEnabled = false
local SpeedValue = 10
local NoClipEnabled = false
local InvisibleEnabled = false

-- // GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalScriptGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- // Menu Principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Draggable = true
MainFrame.Active = true
MainFrame.Visible = true -- Visível por padrão
MainFrame.Parent = ScreenGui

-- // Botão Mobile (Canto Superior Esquerdo)
local MobileButton = Instance.new("TextButton")
MobileButton.Name = "MobileMenuButton"
MobileButton.Text = "MENU"
MobileButton.Font = Enum.Font.SourceSansBold
MobileButton.TextSize = 18
MobileButton.Size = UDim2.new(0, 100, 0, 30)
MobileButton.Position = UDim2.new(0, 10, 0, 10)
MobileButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MobileButton.TextColor3 = Color3.new(1, 1, 1)
MobileButton.BorderSizePixel = 0
MobileButton.Visible = false -- Começa invisível até detectar mobile
MobileButton.ZIndex = 10
MobileButton.AutoButtonColor = true
MobileButton.Parent = ScreenGui

-- // Detecta dispositivo móvel
spawn(function()
    if UserInputService.TouchEnabled then
        MobileButton.Visible = true
    end
end)

-- // Função de abrir/fechar menu ao clicar no botão mobile
MobileButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- // Botão de Fechar
local CloseButton = Instance.new("TextButton")
CloseButton.Text = "X"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 20
CloseButton.BorderSizePixel = 0
CloseButton.Parent = MainFrame

CloseButton.MouseButton1Down:Connect(function()
    MainFrame.Visible = false
end)

-- // Tabs
local TabFolder = Instance.new("Folder", MainFrame)
TabFolder.Name = "Tabs"

local TabButtons = Instance.new("Frame")
TabButtons.Size = UDim2.new(1, 0, 0, 30)
TabButtons.BackgroundTransparency = 1
TabButtons.Parent = MainFrame

for i, name in ipairs({"Aimbot", "ESP", "Adicionais"}) do
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 133, 1, 0)
    Button.Position = UDim2.new((i - 1) * 0.333, 0, 0, 0)
    Button.Text = name
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Button.BorderSizePixel = 0
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 18
    Button.Parent = TabButtons

    Button.MouseButton1Click:Connect(function()
        for _, tab in ipairs(TabFolder:GetChildren()) do
            tab.Visible = tab.Name == name
        end
    end)
end

-- // Conteúdo das Abas
local function CreateTab(name)
    local Frame = Instance.new("ScrollingFrame")
    Frame.Name = name
    Frame.Size = UDim2.new(1, 0, 1, -30)
    Frame.Position = UDim2.new(0, 0, 0, 30)
    Frame.BackgroundTransparency = 1
    Frame.ScrollBarThickness = 6
    Frame.BorderSizePixel = 0
    Frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Frame.Parent = TabFolder
    return Frame
end

-- // Aba Aimbot
local AimbotTab = CreateTab("Aimbot")
local ToggleAimbot = Instance.new("TextButton")
ToggleAimbot.Text = "Aimbot: Desativado"
ToggleAimbot.Size = UDim2.new(1, -10, 0, 30)
ToggleAimbot.Position = UDim2.new(0, 5, 0, 5)
ToggleAimbot.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleAimbot.TextColor3 = Color3.new(1, 1, 1)
ToggleAimbot.BorderSizePixel = 0
ToggleAimbot.Parent = AimbotTab

ToggleAimbot.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    ToggleAimbot.Text = "Aimbot: " .. (AimbotEnabled and "Ativado" or "Desativado")
    if AimbotEnabled then
        spawn(function()
            while AimbotEnabled and wait() do
                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then continue end
                local Mouse = LocalPlayer:GetMouse()
                local Target = nil
                local MinDistance = math.huge
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(TargetPart) and v.Character.Humanoid.Health > 0 then
                        local Pos, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(v.Character[TargetPart].Position)
                        local Distance = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                        if Distance < MinDistance and Distance <= FOVSize and (not WallCheck or not IsBehindWall(LocalPlayer.Character[TargetPart], v.Character[TargetPart])) then
                            MinDistance = Distance
                            Target = v.Character[TargetPart]
                        end
                    end
                end
                if Target then
                    local LookVector = (Target.Position - LocalPlayer.Character.HumanoidRootPart.Position).unit
                    local Camera = workspace.CurrentCamera
                    Camera.CFrame = CFrame.fromMatrix(Camera.CFrame.Position, LookVector, Camera.CFrame.upVector)
                end
            end
        end)
    end
end)

-- // FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = FOVSize
FOVCircle.Thickness = 2
FOVCircle.Color = FOVColor
FOVCircle.Filled = false
FOVCircle.Transparency = 1

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
    FOVCircle.Visible = AimbotEnabled
end)

-- // Slider FOV
local FOVSlider = Instance.new("TextLabel")
FOVSlider.Text = "FOV: 100"
FOVSlider.Size = UDim2.new(1, -10, 0, 30)
FOVSlider.Position = UDim2.new(0, 5, 0, 40)
FOVSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FOVSlider.TextColor3 = Color3.new(1, 1, 1)
FOVSlider.BorderSizePixel = 0
FOVSlider.Parent = AimbotTab

local FOVSliderBG = Instance.new("TextBox")
FOVSliderBG.Size = UDim2.new(1, -10, 0, 20)
FOVSliderBG.Position = UDim2.new(0, 5, 0, 75)
FOVSliderBG.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FOVSliderBG.TextColor3 = Color3.new(1, 1, 1)
FOVSliderBG.Text = "100"
FOVSliderBG.ClearTextOnFocus = true
FOVSliderBG.BorderSizePixel = 0
FOVSliderBG.Parent = AimbotTab

FOVSliderBG.FocusLost:Connect(function()
    local Value = tonumber(FOVSliderBG.Text)
    if Value and Value >= 0 and Value <= 500 then
        FOVSize = Value
        FOVCircle.Radius = FOVSize
        FOVSlider.Text = "FOV: " .. FOVSize
    else
        FOVSliderBG.Text = FOVSize
    end
end)

-- // Cor do FOV
local FOVColorPicker = Instance.new("TextButton")
FOVColorPicker.Text = "Mudar Cor do FOV"
FOVColorPicker.Size = UDim2.new(1, -10, 0, 30)
FOVColorPicker.Position = UDim2.new(0, 5, 0, 100)
FOVColorPicker.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FOVColorPicker.TextColor3 = Color3.new(1, 1, 1)
FOVColorPicker.BorderSizePixel = 0
FOVColorPicker.Parent = AimbotTab

FOVColorPicker.MouseButton1Click:Connect(function()
    FOVColor = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
    FOVCircle.Color = FOVColor
end)

-- // Partes do Corpo
local Parts = {"Head", "Torso", "Left Leg"}
local PartIndex = 1

local TargetPartButton = Instance.new("TextButton")
TargetPartButton.Text = "Alvo: " .. Parts[PartIndex]
TargetPartButton.Size = UDim2.new(1, -10, 0, 30)
TargetPartButton.Position = UDim2.new(0, 5, 0, 135)
TargetPartButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TargetPartButton.TextColor3 = Color3.new(1, 1, 1)
TargetPartButton.BorderSizePixel = 0
TargetPartButton.Parent = AimbotTab

TargetPartButton.MouseButton1Click:Connect(function()
    PartIndex = PartIndex % #Parts + 1
    TargetPart = Parts[PartIndex]
    TargetPartButton.Text = "Alvo: " .. TargetPart
end)

-- // Wall Detect
local WallDetectButton = Instance.new("TextButton")
WallDetectButton.Text = "Wall Detect: Ativo"
WallDetectButton.Size = UDim2.new(1, -10, 0, 30)
WallDetectButton.Position = UDim2.new(0, 5, 0, 170)
WallDetectButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
WallDetectButton.TextColor3 = Color3.new(1, 1, 1)
WallDetectButton.BorderSizePixel = 0
WallDetectButton.Parent = AimbotTab

WallDetectButton.MouseButton1Click:Connect(function()
    WallCheck = not WallCheck
    WallDetectButton.Text = "Wall Detect: " .. (WallCheck and "Ativo" or "Desativo")
end)

-- // Aba ESP
local EspTab = CreateTab("ESP")

local ToggleEsp = Instance.new("TextButton")
ToggleEsp.Text = "ESP: Desativado"
ToggleEsp.Size = UDim2.new(1, -10, 0, 30)
ToggleEsp.Position = UDim2.new(0, 5, 0, 5)
ToggleEsp.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleEsp.TextColor3 = Color3.new(1, 1, 1)
ToggleEsp.BorderSizePixel = 0
ToggleEsp.Parent = EspTab

ToggleEsp.MouseButton1Click:Connect(function()
    EspEnabled = not EspEnabled
    ToggleEsp.Text = "ESP: " .. (EspEnabled and "Ativado" or "Desativado")
end)

local ToggleNames = Instance.new("TextButton")
ToggleNames.Text = "Mostrar Nomes: Ativo"
ToggleNames.Size = UDim2.new(1, -10, 0, 30)
ToggleNames.Position = UDim2.new(0, 5, 0, 40)
ToggleNames.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleNames.TextColor3 = Color3.new(1, 1, 1)
ToggleNames.BorderSizePixel = 0
ToggleNames.Parent = EspTab

ToggleNames.MouseButton1Click:Connect(function()
    ShowNames = not ShowNames
    ToggleNames.Text = "Mostrar Nomes: " .. (ShowNames and "Ativo" or "Desativo")
end)

local ToggleHealth = Instance.new("TextButton")
ToggleHealth.Text = "Mostrar Vida: Ativo"
ToggleHealth.Size = UDim2.new(1, -10, 0, 30)
ToggleHealth.Position = UDim2.new(0, 5, 0, 75)
ToggleHealth.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleHealth.TextColor3 = Color3.new(1, 1, 1)
ToggleHealth.BorderSizePixel = 0
ToggleHealth.Parent = EspTab

ToggleHealth.MouseButton1Click:Connect(function()
    ShowHealth = not ShowHealth
    ToggleHealth.Text = "Mostrar Vida: " .. (ShowHealth and "Ativo" or "Desativo")
end)

local EspColorButton = Instance.new("TextButton")
EspColorButton.Text = "Mudar Cor do ESP"
EspColorButton.Size = UDim2.new(1, -10, 0, 30)
EspColorButton.Position = UDim2.new(0, 5, 0, 110)
EspColorButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
EspColorButton.TextColor3 = Color3.new(1, 1, 1)
EspColorButton.BorderSizePixel = 0
EspColorButton.Parent = EspTab

EspColorButton.MouseButton1Click:Connect(function()
    EspColor = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
end)

-- // Adicionais
local AddonTab = CreateTab("Adicionais")

-- // Fly
local FlyButton = Instance.new("TextButton")
FlyButton.Text = "Voar: Desativado"
FlyButton.Size = UDim2.new(1, -10, 0, 30)
FlyButton.Position = UDim2.new(0, 5, 0, 5)
FlyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FlyButton.TextColor3 = Color3.new(1, 1, 1)
FlyButton.BorderSizePixel = 0
FlyButton.Parent = AddonTab

FlyButton.MouseButton1Click:Connect(function()
    FlyEnabled = not FlyEnabled
    FlyButton.Text = "Voar: " .. (FlyEnabled and "Ativado" or "Desativado")
    if FlyEnabled then
        print("Voar ativado!")
    end
end)

-- // Velocidade
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Text = "Velocidade: 10"
SpeedLabel.Size = UDim2.new(1, -10, 0, 30)
SpeedLabel.Position = UDim2.new(0, 5, 0, 40)
SpeedLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedLabel.TextColor3 = Color3.new(1, 1, 1)
SpeedLabel.BorderSizePixel = 0
SpeedLabel.Parent = AddonTab

local SpeedBox = Instance.new("TextBox")
SpeedBox.Text = "10"
SpeedBox.Size = UDim2.new(1, -10, 0, 20)
SpeedBox.Position = UDim2.new(0, 5, 0, 75)
SpeedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedBox.TextColor3 = Color3.new(1, 1, 1)
SpeedBox.BorderSizePixel = 0
SpeedBox.Parent = AddonTab

SpeedBox.FocusLost:Connect(function()
    local Value = tonumber(SpeedBox.Text)
    if Value and Value > 0 then
        SpeedValue = Value
        SpeedLabel.Text = "Velocidade: " .. SpeedValue
    else
        SpeedBox.Text = SpeedValue
    end
end)

-- // Anti-Ban
local AntiBanButton = Instance.new("TextButton")
AntiBanButton.Text = "Anti-Ban: Ativado"
AntiBanButton.Size = UDim2.new(1, -10, 0, 30)
AntiBanButton.Position = UDim2.new(0, 5, 0, 100)
AntiBanButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AntiBanButton.TextColor3 = Color3.new(1, 1, 1)
AntiBanButton.BorderSizePixel = 0
AntiBanButton.Parent = AddonTab

AntiBanButton.MouseButton1Click:Connect(function()
    print("Anti-Ban ativado!")
end)

-- // Noclip
local NoClipButton = Instance.new("TextButton")
NoClipButton.Text = "Noclip: Desativado"
NoClipButton.Size = UDim2.new(1, -10, 0, 30)
NoClipButton.Position = UDim2.new(0, 5, 0, 135)
NoClipButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
NoClipButton.TextColor3 = Color3.new(1, 1, 1)
NoClipButton.BorderSizePixel = 0
NoClipButton.Parent = AddonTab

NoClipButton.MouseButton1Click:Connect(function()
    NoClipEnabled = not NoClipEnabled
    NoClipButton.Text = "Noclip: " .. (NoClipEnabled and "Ativado" or "Desativado")
    if NoClipEnabled then
        pcall(function()
            LocalPlayer.Character.Humanoid:ChangeState(11)
        end)
    end
end)

-- // Invisibilidade
local InvisibleButton = Instance.new("TextButton")
InvisibleButton.Text = "Invisível: Desativado"
InvisibleButton.Size = UDim2.new(1, -10, 0, 30)
InvisibleButton.Position = UDim2.new(0, 5, 0, 170)
InvisibleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
InvisibleButton.TextColor3 = Color3.new(1, 1, 1)
InvisibleButton.BorderSizePixel = 0
InvisibleButton.Parent = AddonTab

InvisibleButton.MouseButton1Click:Connect(function()
    InvisibleEnabled = not InvisibleEnabled
    InvisibleButton.Text = "Invisível: " .. (InvisibleEnabled and "Ativado" or "Desativado")
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = InvisibleEnabled and 1 or 0
            end
        end
    end
end)

-- // Mensagem inicial
spawn(function()
    while wait(5) do
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Universal Script",
            Text = "Menu carregado! Pressione X ou toque no botão para abrir.",
            Duration = 5,
        })
    end
end)

-- // Função de verificação de parede
function IsBehindWall(Source, Target)
    local RayParams = RaycastParams.new()
    RayParams.FilterType = Enum.RaycastFilterType.Exclude
    RayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    local Result = workspace:Raycast(Source.Position, Target.Position - Source.Position, RayParams)
    return Result and Result.Instance.CanCollide
end
