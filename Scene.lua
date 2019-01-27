--scene body
class "Scene" {
	init = function(self) end, --constructure (operator)
	frame = function(self) end, --update (operator)
	render = function(self) end, --render (operator)
	del = function(self) end, --destructure (operator)

	['goto'] = function(self, scene)
		Scene.turnto(self, scene)
		table.insert(Scene.stack, scene)
	end, --quit and turn to the next scene, record the current scene
	release = function(self)
		RemoveResource'stage'
	end, --release the resource
	restart = function(self)
		Scene.turnto(self, self:name())
	end, --quit and restart this scene
	retrace = function(self)
		if #Scene.stack ~= 0 then
			Scene.turnto(self, Scene.stack[#Scene.stack])
			table.remove(Scene.stack)
		else
			stage.QuitGame()
		end
	end, --quit and turn to the last scene
	quit = function(self)
		if #Scene.nexter ~= 0 then
			Scene.turnto(self, Scene.nexter[#Scene.nexter])
			table.remove(Scene.nexter)
		else
			stage.QuitGame()
		end
	end, --quit, and if it has the next scene, turn to it, otherwise quit game
	["next"] = function(self, scene)
		table.insert(Scene.nexter, scene)
	end, --set the next scene
	turnto = function(self, scene)
		stage.Set(Scene.new(scene))
	end, --quit and turn to the next scene, record nothing
	self = function(self) return self.stage end, --get the stage
	name = function(self) return self.name end, --get the name

	new = function(scene)
		local obj = {}
		obj.name = scene
		obj.stage = stage.New("Scene"..scene)
		setmetatable(obj, {__index = Scene})
		return obj
	end, --create a scene and initialize
	stack = {},
	nexter = {},
}
--scene operation
