-- Compiled with roblox-ts v3.0.0
-- eslint-disable roblox-ts/lua-truthiness 
-- eslint-disable @typescript-eslint/no-require-imports 
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local _value = getgenv().notoriety
if _value ~= 0 and _value == _value and _value ~= "" and _value then
	error("This script is already running!")
else
	getgenv().notoriety = true
end
--[[
	***********************************************************
	 * CONFIGURATIONS
	 * Description: User-defined settings and configurations
	 * Last updated: Dec. 22, 2024
	 ***********************************************************
]]
--[[
	***********************************************************
	 * VARIABLES
	 * Description: Variables referenced globally in the script
	 * Last updated: Dec. 22, 2024
	 ***********************************************************
]]
local LocalPlayer = Players.LocalPlayer
local PoliceFolder = Workspace:WaitForChild("Police")
local CivilliansFolder = Workspace:WaitForChild("Citizens")
local RS_Package = ReplicatedStorage:WaitForChild("RS_Package")
local DamageRemote = RS_Package:FindFirstChild("Damage", true)
local YellRemote = RS_Package:FindFirstChild("PlayerYell", true)
local StartInteractRemote = RS_Package:FindFirstChild("StartInteraction", true)
local CompleteInteractiontRemote = RS_Package:FindFirstChild("CompleteInteraction", true)
--[[
	***********************************************************
	 * UTILITIES
	 * Description: Helper functions and classes
	 * Last updated: Dec. 22, 2024
	 ***********************************************************
]]
local repo = "https://raw.githubusercontent.com/scripts-ts/LinoriaLib/main/out/"
local _binding = loadstring(game:HttpGet(repo .. "init.lua"))()
local Builder = _binding.Builder
local Window = _binding.Window
local Page = _binding.Page
local ThemeSection = _binding.ThemeSection
local ConfigSection = _binding.ConfigSection
local Groupbox = _binding.Groupbox
local Tabbox = _binding.Tabbox
local Tab = _binding.Tab
local DependencyBox = _binding.DependencyBox
local Label = _binding.Label
local Toggle = _binding.Toggle
local Button = _binding.Button
local Slider = _binding.Slider
local Dropdown = _binding.Dropdown
local MultiDropdown = _binding.MultiDropdown
local Divider = _binding.Divider
local Spacer = _binding.Spacer
local KeyPicker = _binding.KeyPicker
local ColorPicker = _binding.ColorPicker
local library = loadstring(game:HttpGet(repo .. "library.lua"))()
local savemanager = loadstring(game:HttpGet(repo .. "addons/savemanager.lua"))()
local thememanager = loadstring(game:HttpGet(repo .. "addons/thememanager.lua"))()
local Bin
do
	Bin = setmetatable({}, {
		__tostring = function()
			return "Bin"
		end,
	})
	Bin.__index = Bin
	function Bin.new(...)
		local self = setmetatable({}, Bin)
		return self:constructor(...) or self
	end
	function Bin:constructor()
	end
	function Bin:add(item)
		local node = {
			item = item,
		}
		if self.head == nil then
			self.head = node
		end
		if self.tail then
			self.tail.next = node
		end
		self.tail = node
		return item
	end
	function Bin:batch(...)
		local args = { ... }
		for _, item in args do
			local node = {
				item = item,
			}
			if self.head == nil then
				self.head = node
			end
			if self.tail then
				self.tail.next = node
			end
			self.tail = node
		end
		return args
	end
	function Bin:destroy()
		while self.head do
			local item = self.head.item
			if type(item) == "function" then
				item()
			elseif typeof(item) == "RBXScriptConnection" then
				item:Disconnect()
			elseif type(item) == "thread" then
				task.cancel(item)
			elseif item.destroy ~= nil then
				item:destroy()
			elseif item.Destroy ~= nil then
				item:Destroy()
			end
			self.head = self.head.next
		end
	end
	function Bin:isEmpty()
		return self.head == nil
	end
end
local function interact(prompt)
	StartInteractRemote:FireServer(prompt)
	task.wait(0.1)
	CompleteInteractiontRemote:FireServer(prompt)
end
--[[
	***********************************************************
	 * COMPONENTS
	 * Description: Classes for specific entities/objects
	 * Last updated: Dec. 22, 2024
	 ***********************************************************
]]
local BaseComponent
do
	BaseComponent = setmetatable({}, {
		__tostring = function()
			return "BaseComponent"
		end,
	})
	BaseComponent.__index = BaseComponent
	function BaseComponent.new(...)
		local self = setmetatable({}, BaseComponent)
		return self:constructor(...) or self
	end
	function BaseComponent:constructor(instance)
		self.instance = instance
		self.bin = Bin.new()
	end
	function BaseComponent:destroy()
		self.bin:destroy()
	end
end
local RigComponent
do
	local super = BaseComponent
	RigComponent = setmetatable({}, {
		__tostring = function()
			return "RigComponent"
		end,
		__index = super,
	})
	RigComponent.__index = RigComponent
	function RigComponent.new(...)
		local self = setmetatable({}, RigComponent)
		return self:constructor(...) or self
	end
	function RigComponent:constructor(instance)
		super.constructor(self, instance)
		local root = instance:WaitForChild("HumanoidRootPart")
		if root == nil then
			error("Root part not found")
		end
		local humanoid = instance:WaitForChild("Humanoid")
		if humanoid == nil then
			error("Humanoid not found")
		end
		self.root = root
		self.humanoid = humanoid
		local bin = self.bin
		bin:batch(humanoid.Died:Connect(function()
			return self:destroy()
		end), instance.Destroying:Connect(function()
			return self:destroy()
		end))
	end
end
local CharacterComponent
do
	local super = RigComponent
	CharacterComponent = setmetatable({}, {
		__tostring = function()
			return "CharacterComponent"
		end,
		__index = super,
	})
	CharacterComponent.__index = CharacterComponent
	function CharacterComponent.new(...)
		local self = setmetatable({}, CharacterComponent)
		return self:constructor(...) or self
	end
	function CharacterComponent:constructor(player, instance)
		super.constructor(self, instance)
		local id = player.Name .. " @" .. player.DisplayName
		local tools = {}
		local backpack = player:WaitForChild("Backpack")
		if not backpack then
			error("[CharacterComponent]: " .. id .. " does not have a backpack!")
		end
		local stamina = instance:WaitForChild("Stamina")
		if not stamina then
			error("[CharacterComponent]: " .. id .. " does not have a stamina property!")
		end
		self.player = player
		self.tools = tools
		self.equipped = nil
		self.backpack = backpack
		self.stamina = stamina
		local _binding_1 = self
		local bin = _binding_1.bin
		bin:batch(backpack.ChildAdded:Connect(function(child)
			return self:_onBackpackChild(child)
		end))
	end
	function CharacterComponent:onEquip()
	end
	function CharacterComponent:_onBackpackChild(tool)
		if not tool:IsA("Tool") then
			return nil
		end
		local tools = self.tools
		local _tool = tool
		if tools[_tool] ~= nil then
			return nil
		end
		local _tool_1 = tool
		tools[_tool_1] = true
		local _binding_1 = self
		local backpack = _binding_1.backpack
		local bin = _binding_1.bin
		local instance = _binding_1.instance
		local previous = backpack
		bin:add(tool.AncestryChanged:Connect(function()
			local parent = tool.Parent
			if parent ~= previous then
				if parent == backpack then
					if self.equipped == tool then
						self.equipped = nil
					end
				elseif parent == instance then
					self.equipped = tool
				end
				previous = parent
				self:onEquip()
			end
		end))
	end
	CharacterComponent.active = {}
end
local AgentComponent
do
	local super = CharacterComponent
	AgentComponent = setmetatable({}, {
		__tostring = function()
			return "AgentComponent"
		end,
		__index = super,
	})
	AgentComponent.__index = AgentComponent
	function AgentComponent.new(...)
		local self = setmetatable({}, AgentComponent)
		return self:constructor(...) or self
	end
	function AgentComponent:constructor(instance)
		super.constructor(self, LocalPlayer, instance)
		self.tool = self.equipped
	end
	function AgentComponent:onEquip()
		if not self.equipped then
			return nil
		end
		if self.tool == self.equipped then
			return nil
		end
		self.tool = self.equipped
	end
end
local PlayerComponent
do
	local super = BaseComponent
	PlayerComponent = setmetatable({}, {
		__tostring = function()
			return "PlayerComponent"
		end,
		__index = super,
	})
	PlayerComponent.__index = PlayerComponent
	function PlayerComponent.new(...)
		local self = setmetatable({}, PlayerComponent)
		return self:constructor(...) or self
	end
	function PlayerComponent:constructor(instance)
		super.constructor(self, instance)
		self.name = self.instance.Name
		local character = instance.Character
		if character then
			task.spawn(function()
				return self:onCharacterAdded(character)
			end)
		end
		local bin = self.bin
		bin:batch(instance.CharacterAdded:Connect(function(character)
			return self:onCharacterAdded(character)
		end), instance.CharacterRemoving:Connect(function()
			return self:onCharacterRemoving()
		end))
		bin:add(function()
			local _active = PlayerComponent.active
			local _instance = instance
			-- ▼ Map.delete ▼
			local _valueExisted = _active[_instance] ~= nil
			_active[_instance] = nil
			-- ▲ Map.delete ▲
			return _valueExisted
		end)
		local _active = PlayerComponent.active
		local _instance = instance
		local _self = self
		_active[_instance] = _self
	end
	function PlayerComponent:onCharacterAdded(character)
		local _result = self.character
		if _result ~= nil then
			_result:destroy()
		end
		self.character = CharacterComponent.new(self.instance, character)
	end
	function PlayerComponent:onCharacterRemoving()
		local _result = self.character
		if _result ~= nil then
			_result:destroy()
		end
		self.character = nil
	end
	function PlayerComponent:getName()
		return self.name
	end
	function PlayerComponent:getCharacter()
		return self.character
	end
	PlayerComponent.active = {}
end
--[[
	***********************************************************
	 * CONTROLLERS
	 * Description: Singletons that are used once
	 * Last updated: Dec. 22, 2024
	 ***********************************************************
]]
local AgentController
local AgentController = {}
do
	local _container = AgentController
	local _stamina
	local _root
	local _humanoid
	local onAgent = function(char)
		local _result = AgentController.agent
		if _result ~= nil then
			_result:destroy()
		end
		local agent = AgentComponent.new(char)
		AgentController.agent = agent
		AgentController.instance = agent.instance
		_stamina = agent.stamina
		_root = agent.root
		_humanoid = agent.humanoid
		_stamina:GetPropertyChangedSignal("Value"):Connect(function()
			if Toggles["gameplay.movement.infinite_stamina"].Value then
				_stamina.Value = 1000
			end
		end)
	end
	local function __self_revive()
		interact(_root:FindFirstChildWhichIsA("ProximityPrompt"))
	end
	_container.__self_revive = __self_revive
	local function __init()
		LocalPlayer.CharacterAdded:Connect(function(character)
			return onAgent(character)
		end)
		local character = LocalPlayer.Character
		if character then
			onAgent(character)
		end
	end
	_container.__init = __init
end
local RangeController = {}
do
	local _container = RangeController
	local function __init()
		RunService.RenderStepped:Connect(function()
			local equipped = AgentController.agent.tool
			if not equipped then
				return nil
			end
			print(equipped)
			if Toggles["gameplay.gun_mods.enabled"].Value then
				local Settings = equipped:FindFirstChild("Data")
				if not Settings then
					return nil
				end
				local Module = require(Settings)
				Module.ReloadTime = Options["gameplay.gun_mods.reload_time"].Value
				Module.Accuracy = Options["gameplay.gun_mods.accuracy"].Value
				Module.FireDelay = Options["gameplay.gun_mods.delay"].Value
				Module.BulletSpeed = Options["gameplay.gun_mods.speed"].Value
			end
		end)
	end
	_container.__init = __init
end
local NPCController = {}
do
	local _container = NPCController
	local function __init()
		local __namecall
		__namecall = hookmetamethod(game, "__namecall", function(self, ...)
			local args = { ... }
			if not checkcaller() then
				local method = getnamecallmethod()
				if method == "FireServer" then
					if self.Name == "Damage" and Toggles["gameplay.gun_mods.multiplier"].Value then
						for i = 0, 4 do
							__namecall(self, unpack(args))
						end
					end
					if self.Name == "Bullet" and Toggles["gameplay.gun_mods.infinite_bullets"].Value then
						return nil
					end
				end
			end
			return __namecall(self, unpack(args))
		end)
		task.spawn(function()
			-- eslint-disable-next-line no-constant-condition
			while true do
				task.wait()
				task.delay(Options["gameplay.kill_cops.delay"].Value, function()
					if Toggles["gameplay.kill_cops.enabled"].Value then
						local equipped = AgentController.agent.tool
						if not equipped then
							return nil
						end
						for _, police in PoliceFolder:GetChildren() do
							local Humanoid = police:FindFirstChildOfClass("Humanoid")
							local Head = police:FindFirstChild("Head")
							if Humanoid then
								DamageRemote:FireServer("Damage", equipped, Humanoid, 1000, Head, equipped.Name, Vector3.new())
							end
						end
					end
				end)
				task.delay(Options["gameplay.yell_civilians.delay"].Value, function()
					if Toggles["gameplay.yell_civilians.enabled"].Value then
						YellRemote:FireServer(CivilliansFolder:GetChildren())
					end
				end)
			end
		end)
	end
	_container.__init = __init
end
--[[
	***********************************************************
	 * INTERFACE
	 * Description: User interface instantiation
	 * Last updated: Dec. 22, 2024
	 ***********************************************************
]]
Builder.new():root("brickmane_hub", "Notoriety"):library(library):withSaveManager(savemanager):withThemeManager(thememanager):windows({ Window.new():title("Brickmane Awakening | Notoriety | v.0.1"):centered(true):autoShow(true):withFadeTime(0):pages({ Page.new():title("Gameplay"):left({ Groupbox.new():title("NPC Utility"):elements({ Toggle.new("gameplay.kill_cops.enabled"):title("Kill All Cops"):tooltip("Automatically kills cops"):default(false), DependencyBox.new():dependsOn("gameplay.kill_cops.enabled", true):elements({ Slider.new("gameplay.kill_cops.delay"):title("Kill All Cops Delay"):suffix(" seconds"):round(1):limits(0, 1):default(0.1):hideMax(true) }), Toggle.new("gameplay.yell_civilians.enabled"):title("Yell at all civillians"):tooltip("Automatically yells at civillians"):default(false), DependencyBox.new():dependsOn("gameplay.yell_civilians.enabled", true):elements({ Slider.new("gameplay.yell_civilians.delay"):title("Yell at all civillians Delay"):suffix(" seconds"):round(1):limits(0, 1):default(0.1):hideMax(true) }) }), Groupbox.new():title("Players Utility"):elements({ Toggle.new("gameplay.movement.infinite_stamina"):title("Infinite Stamina"):tooltip("Disables stamina consumption"):default(false), Button.new("gameplay.player.self_revive"):title("Self-Revive"):tooltip("Revives yourself in an instant"):onClick(function()
	return AgentController.__self_revive()
end) }) }):right({ Groupbox.new():title("Gun Mods"):elements({ Toggle.new("gameplay.gun_mods.enabled"):title("Enabled"):tooltip("Modifies the gun you are holding"):default(false), DependencyBox.new():dependsOn("gameplay.gun_mods.enabled", true):elements({ Slider.new("gameplay.gun_mods.delay"):title("Fire Delay"):suffix(" s"):round(2):limits(0.01, 1):default(0.13):hideMax(true), Slider.new("gameplay.gun_mods.speed"):title("Bullet Speed"):suffix("%"):round(0):limits(1, 200):default(50):hideMax(true), Slider.new("gameplay.gun_mods.accuracy"):title("Accuracy"):suffix("%"):round(0):limits(1, 100):default(1):hideMax(true), Slider.new("gameplay.gun_mods.reload_time"):title("Reload time"):suffix(" seconds"):round(2):limits(0.01, 1):default(1):hideMax(true) }), Toggle.new("gameplay.gun_mods.multiplier"):title("Damage Multiplier"):tooltip("Multiplies the amount of damage your gun does"):default(false), Toggle.new("gameplay.gun_mods.infinite_bullets"):title("Inf Bullets"):tooltip("You never run out of bullets."):default(false) }) }), Page.new():title("Settings"):left({ ThemeSection.new() }):right({ ConfigSection.new(), Groupbox.new():title("Menu Keybind"):elements({ Label.new():text("Keypicker"):extensions({ KeyPicker.new("menu.keybind"):bind("End") }) }) }) }) }):renderUI()
library.ToggleKeybind = Options["menu.keybind"]
--[[
	***********************************************************
	 * INITIALIZATION
	 * Description: Initializes and starts the runtime
	 * Last updated: Dec. 22, 2024
	 ***********************************************************
]]
AgentController.__init()
NPCController.__init()
RangeController.__init()
return "Initialized Successfully"
