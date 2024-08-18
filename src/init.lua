--[[

	@ Name: SmoothShiftLock
	@ Author: x33
	@ Version: 1.3.0

	@ Variables:
	└	.enabled - ShiftLock's enabled state.

	@ Methods:
	│	:enable() - Enables the whole module.
	│	:disable() - Disables the whole module.
	│	:isEnabled(): boolean - Returns ShiftLock's enabled state.
	└	:toggleShiftLock(enable: boolean?) - Toggles the ShiftLock, if Enable parameter is provided then ShiftLock will be toggled to it.

--]]

local SmoothShiftLock = {}
SmoothShiftLock.__index = SmoothShiftLock

--// [ Locals: ]

--// Services
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")

--// Utilities
local Maid = require(script:WaitForChild("Maid"))
local Spring = require(script:WaitForChild("Spring"))

--// Instances
local LocalPlayer = Players.LocalPlayer
local PlayerMouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

--// Configuration
local defaultConfig = {
	mobileSupport = false, --// Adds a button to toggle the shift lock for touchscreen devices
	smoothCharacterRotation = true, --// If your character should rotate smoothly or not
	characterRotationSpeed = 3, --// How quickly character rotates smoothly
	transitionSpringDamper = 0.7, --// Camera transition spring damper, test it out to see what works for you
	cameraTransitionInSpeed = 10, --// How quickly locked camera moves to offset position
	cameraTransitionOutSpeed = 14, --// How quickly locked camera moves back from offset position
	lockedCameraOffset = Vector3.new(1.75, 0.25, 0), --// Locked camera offset
	--// Locked mouse icon
	lockedMouseIcon = "rbxasset://textures/MouseLockedCursor.png",
	--// Shift lock keybinds
	shiftLockKeybinds = { Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift },
}

type Config = {
	mobileSupport: boolean,
	smoothCharacterRotation: boolean,
	characterRotationSpeed: number,
	transitionSpringDamper: number,
	cameraTransitionInSpeed: number,
	cameraTransitionOutSpeed: number,
	lockedCameraOffset: Vector3,
	lockedMouseIcon: string,
	shiftLockKeybinds: { Enum.KeyCode },
}

--// [ Constructor: ]
function SmoothShiftLock.new(config: Config?)
	local self = setmetatable({}, SmoothShiftLock)

	--// Configuration
	self.config = {
		mobileSupport = config and config.mobileSupport or defaultConfig.mobileSupport,
		smoothCharacterRotation = config and config.smoothCharacterRotation or defaultConfig.smoothCharacterRotation,
		characterRotationSpeed = config and config.characterRotationSpeed or defaultConfig.characterRotationSpeed,
		transitionSpringDamper = config and config.transitionSpringDamper or defaultConfig.transitionSpringDamper,
		cameraTransitionInSpeed = config and config.cameraTransitionInSpeed or defaultConfig.cameraTransitionInSpeed,
		cameraTransitionOutSpeed = config and config.cameraTransitionOutSpeed or defaultConfig.cameraTransitionOutSpeed,
		lockedCameraOffset = config and config.lockedCameraOffset or defaultConfig.lockedCameraOffset,
		lockedMouseIcon = config and config.lockedMouseIcon or defaultConfig.lockedMouseIcon,
		shiftLockKeybinds = config and config.shiftLockKeybinds or defaultConfig.shiftLockKeybinds,
	}

	--// Utilities
	self._runtimeMaid = Maid.new()
	self._shiftlockMaid = Maid.new()
	self._cameraOffsetSpring = Spring.new(Vector3.new(0, 0, 0))
	self._cameraOffsetSpring.Damper = self.config.transitionSpringDamper

	--// Variables
	self.enabled = false

	--// Setup
	self:enable()

	return self
end

--// [ Module Functions: ]
function SmoothShiftLock:enable()
	self:_refreshCharacterVariables()
	self._runtimeMaid:GiveTask(LocalPlayer.CharacterAdded:Connect(function()
		self:_refreshCharacterVariables()
	end))

	--// Bind Keybinds
	ContextActionService:BindActionAtPriority("ShiftLockSwitchAction", function(Name, State, Input)
		return self:_doShiftLockSwitch(Name, State, Input)
	end, self.config.mobileSupport, Enum.ContextActionPriority.Medium.Value, unpack(self.config.shiftLockKeybinds))

	--// Camera Offset
	self._runtimeMaid:GiveTask(RunService.RenderStepped:Connect(function()
		if self.Head.LocalTransparencyModifier > 0.6 then
			return
		end

		local CameraCFrame = Camera.CoordinateFrame
		local Distance = (self.Head.Position - CameraCFrame.p).magnitude

		--// Camera offset
		if Distance > 1 then
			Camera.CFrame = (Camera.CFrame * CFrame.new(self._cameraOffsetSpring.Position))
			if self.enabled and UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
				self:_updateMouseState()
			end
		end
	end))
end

function SmoothShiftLock:disable()
	self._runtimeMaid:DoCleaning()
	self._shiftlockMaid:DoCleaning()

	--// Unbind Keybinds
	ContextActionService:UnbindAction("ShiftLockSwitchAction")
end

--// [ Internal Functions: ]
function SmoothShiftLock:_refreshCharacterVariables()
	self.Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	self.RootPart = self.Character:WaitForChild("HumanoidRootPart")
	self.Humanoid = self.Character:WaitForChild("Humanoid")
	self.Head = self.Character:WaitForChild("Head")
end

--// Internal function for ContextActionService
function SmoothShiftLock:_doShiftLockSwitch(_, State: Enum.UserInputState)
	if State == Enum.UserInputState.Begin then
		self:toggleShiftLock()
		return Enum.ContextActionResult.Sink
	end

	return Enum.ContextActionResult.Pass
end

--// Update the mouse behaviour
function SmoothShiftLock:_updateMouseState()
	UserInputService.MouseBehavior = (self.enabled and Enum.MouseBehavior.LockCenter) or Enum.MouseBehavior.Default
end

--// Update the mouse icon
function SmoothShiftLock:_updateMouseIcon()
	PlayerMouse.Icon = (self.enabled and self.config.lockedMouseIcon :: string) or ""
end

--// Transition the camera to lock offset
function SmoothShiftLock:_transitionLockOffset()
	if self.enabled then
		self._cameraOffsetSpring.Speed = self.config.cameraTransitionInSpeed
		self._cameraOffsetSpring.Target = self.config.lockedCameraOffset
	else
		self._cameraOffsetSpring.Speed = self.config.cameraTransitionOutSpeed
		self._cameraOffsetSpring.Target = Vector3.new(0, 0, 0)
	end
end

--// [ External Functions: ]
function SmoothShiftLock:isEnabled(): boolean
	return self.enabled
end

--// ShiftLock toggle function
function SmoothShiftLock:toggleShiftLock(enable: boolean?)
	if enable ~= nil then
		self.enabled = enable
	else
		self.enabled = not self.enabled
	end

	self:_updateMouseState()
	self:_updateMouseIcon()
	self:_transitionLockOffset()
	if self.enabled then
		self._shiftlockMaid:GiveTask(RunService.RenderStepped:Connect(function(Delta: number)
			if self.Humanoid and self.RootPart then
				self.Humanoid.AutoRotate = not self.enabled
			end

			--// Rotate the character
			if self.Humanoid.Sit then
				return
			end
			if self.config.smoothCharacterRotation then
				local x, y, z = Camera.CFrame:ToOrientation()
				self.RootPart.CFrame = self.RootPart.CFrame:Lerp(
					CFrame.new(self.RootPart.Position) * CFrame.Angles(0, y, 0),
					Delta * 5 * self.config.characterRotationSpeed
				)
			else
				local x, y, z = Camera.CFrame:ToOrientation()
				self.RootPart.CFrame = CFrame.new(self.RootPart.Position) * CFrame.Angles(0, y, 0)
			end
		end))
	else
		self.Humanoid.AutoRotate = true
		self._shiftlockMaid:DoCleaning()
	end
end

return {
	SmoothShiftLock = SmoothShiftLock,
}
