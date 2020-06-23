--
--class "Iteration" {
--	init = function(self, times, radius, veloc, angle, accel, env, func)
--		env = env or {radius=0,veloc=0,angle=0,accel=0}
--		env = self.env(times, radius, veloc, angle, accel, env)
--		for i = 1, times do
--			func(env(i))
--		end
--	end,
--	env = function(times, radius, veloc, angle, accel, env)
--		return function(index)
--			local rate = (index-1)/(times-1)
--			return {
--				index = index,
--				radius = radius + env.radius,
--				veloc = veloc*rate + env.veloc,
--				angle = angle*rate + env.angle,
--				accel = accel*rate + env.accel,
--			}
--		end
--	end,
--}

local task = task
local SetV = SetV
local SetA = SetA
local cos = cos
local sin = sin

RECTANGULAR = "rectangular"
POLAR = "polar"

clockwise = true
anticlockwise = false

---@class THlib.shooter:THlib.bullet
shooter = Class(bullet)
local shooter = shooter

function shooter:init(img, color, x, y, v, angle, accel, env, other)
    bullet.init(self, img, color, true, true)
    shooter._init(self, x, y, v, angle, accel, env, other)
end

function shooter:_init(x, y, v, angle, accel, env, other)
    if env then
        self.rot = env.angle + angle
        self.v = v + env.veloc
        self.accel = accel + env.accel
    else
        self.rot = angle
        self.v = v
        self.accel = accel
    end
    self.g = 0
    self.maxv = 0
    self.maxvx = 0
    self.maxvy = 0
    self.reflected = true
    for _, v in ipairs(other) do
        shooter.read(self, v)
    end
    if env then
        self.x, self.y = x + env.radius * cos(self.rot), y + env.radius * sin(self.rot)
    else
        self.x, self.y = x, y
    end
    if self.maxvx ~= 0 then
        self.forbidveloc = self.forbidveloc or {}
        self.forbidveloc.vx = self.maxvx
    end
    if not self.time or self.time == 0 then
        SetV(self, self.v, self.rot)
        if self.accel ~= 0 or self.g ~= 0 or self.maxv ~= 0 or self.maxvy ~= 0 then
            SetA(self, self.accel, self.rot, self.maxv, self.g, self.maxvy, self.navi)
        end
        if self.aax or self.ax then
            self.acceleration = self.acceleration or {}
            local accel = self.acceleration
            accel.ax = (accel.ax or 0) + (self.ax or 0)
            accel.ay = (accel.ay or 0) + (self.ay or 0)
        end
    end
end

function shooter:frame()
    shooter._frame(self)
    bullet.frame(self)
end

function shooter:_frame()
    if self.time and self.time ~= 0 and self.time == self.timer then
        SetV(self, self.v, self.rot)
        if self.accel ~= 0 or self.g ~= 0 or self.maxv ~= 0 or self.maxvy ~= 0 then
            SetA(self, self.accel, self.rot, self.maxv, self.g, self.maxvy, self.navi)
        end
        if self.aax or self.ax then
            self.acceleration = self.acceleration or {}
            local accel = self.acceleration
            accel.ax = (accel.ax or 0) + (self.ax or 0)
            accel.ay = (accel.ay or 0) + (self.ay or 0)
        end
    end
    if IsValid(self._dir_con) then
        self.rot = self._dir_con.rot + self.deflection
    end
    if self.aax then
        local accel = self.acceleration
        accel.ax = accel.ax + self.aax
        accel.ay = accel.ay + self.aay
    end
    if self.through then
        local world = lstg.world
        if self.y > world.t then
            self.y = self.y - (world.t - world.b)
            self.through = nil
        end
        if self.y < world.b then
            self.y = self.y + (world.t - world.b)
            self.through = nil
        end
        if self.x > world.r then
            self.x = self.x - (world.r - world.l)
            self.through = nil
        end
        if self.x < world.l then
            self.x = self.x + (world.r - world.l)
            self.through = nil
        end
    end
    straight_495.frame(self)
end

function shooter:read(data)
    local switch = {
        ["aim to player"]      = function()
            self.rot = self.rot + Angle(self, player)
        end,
        ["gravity"]            = function(g, maxv, maxvy, navi)
            self.g = g or 0
            self.maxv = maxv or 0
            self.maxvy = maxvy or 0
            self.navi = navi
        end,
        ["velocity forbid"]    = function(maxv, maxvx, maxvy)
            self.maxv = maxv or 0
            self.maxvx = maxvx or 0
            self.maxvy = maxvy or 0
        end,
        ["stay"]               = function(time)
            self.time = time
        end,
        ["property"]           = function(indes, navi, bound, rebound, through)
            if indes then
                self.group = GROUP_INDES
            end
            self.navi = navi
            self.bound = bound
            self.reflected = not rebound
            self.through = through
        end,
        ["direction"]          = function(omiga, connect, deflection, navi)
            self.omiga = omiga
            self.navi = navi
            self._dir_con = connect
            self.deflection = deflection
        end,
        ["acceleration"]       = function(accel, angle)
            self.ax = (self.ax or 0) + accel * cos(angle)
            self.ay = (self.ay or 0) + accel * sin(angle)
        end,
        ["jerk"]               = function(addition, angle)
            self.aax = addition * cos(angle)
            self.aay = addition * sin(angle)
        end,
        ["moveto"]             = function(x, y, time, cal, mode)
            local ox = x
            local oy = y
            if cal == "polar" then
                ox = x * cos(y)
                oy = x * sin(y)
            end
            self.time = time
            task.New(self, function()
                task.MoveTo(ox, oy, time, mode)
            end)
        end,
        ["rotation"]           = function(radius, direct, navi)
            local w = self.v / radius
            if direct then
                direct = -1
            else
                direct = 1
            end
            self.acceleration = self.acceleration or {}
            task.New(self, function()
                while true do
                    self.acceleration.ax = self.vy * w * (-direct)
                    self.acceleration.ay = self.vx * w * (direct)
                    task._Wait(1)
                end
            end)
            self.navi = navi
        end,
        ["parameter equation"] = function(xf, yf, mode, navi)
            task.New(self, function()
                for i = 1, _infinite do
                    local x, y = xf(i), yf(i)
                    if mode == "polar" then
                        self.x = x * cos(y)
                        self.y = x * sin(y)
                    else
                        self.x, self.y = x, y
                    end
                    task._Wait(1)
                end
            end)
            self.navi = navi
        end,
        ["task on condition"]  = function(condition, _task)
            task.New(self, function()
                while true do
                    if condition(self) then
                        _task(self)
                    end
                    task._Wait(1)
                end
            end)
        end,
        ["task on frame"]      = function(_task)
            task.New(self, function()
                while true do
                    _task(self)
                    task._Wait(1)
                end
            end)
        end,
    }
    switch[data[1]](unpack(data, 2))
end

---@class THlib.bent_laser_shooter:THlib.laser_bent
bent_laser_shooter = Class(laser_bent)

function bent_laser_shooter:init(color, x, y, l, w, v, angle, accel, env, other)
    laser_bent.init(self, color, x, y, l, w)
    shooter._init(self, x, y, v, angle, accel, env, other)
end

function bent_laser_shooter:frame()
    shooter._frame(self)
    laser_bent.frame(self)
end

---@class THlib.laser_shooter:THlib.laser
laser_shooter = Class(laser)

function laser_shooter:init(color, x, y, l1, l2, l3, w, node, v, angle, accel, env, other)
    laser.init(self, color, x, y, angle, l1, l2, l3, w, node)
    shooter._init(self, x, y, v, angle, accel, env, other)
end

function laser_shooter:frame()
    shooter._frame(self)
    laser.frame(self)
end