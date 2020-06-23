stage4bg = Class(object)

function stage4bg:init()
    --
    background.init(self, false)
    --resource
    LoadImageFromFile('stage04a', 'THlib\\background\\stage4bg\\stage04a.png')
    LoadImageFromFile('stage04b', 'THlib\\background\\stage4bg\\stage04b.png')
    LoadImageFromFile('stage04c', 'THlib\\background\\stage4bg\\stage04c.png')
    LoadImageFromFile('stage04d', 'THlib\\background\\stage4bg\\stage04d.png')
    --set 3d camera and fog
    Set3D('eye', 8.5, 8.5, -7.1)

    Set3D('at', -0.0, -0.1, -0.6)
    Set3D('up', 0, 1, 0)
    Set3D('z', 1, 1000)
    Set3D('fovy', 0.6)
    Set3D('fog', 6.70, 11.8, Color(100, 0, 0, 0))
    -----
    self.eye_a = 1.0
    self.eye_b = 3.6
    self.eye_c = -7.1
    -----
    self.speed = 0.005
    self.z = 0
    pre_background = self
    self.alpha = 0
    self.cover = {}
    self.cover.alpha = 0
    self.cover.r = 0
    self.cover.g = 0
    self.cover.b = 0
end

function stage4bg:frame()
    self.z = self.z + self.speed
    if self.timer < 301 then
        self.eye_a = 8.5 - 7.5 * (self.timer / 300)
        self.eye_b = 8.5 - 4.9 * (self.timer / 300)
        Set3D('eye', self.eye_a, self.eye_b, -7.1)
    end
    ---if self.timer==181 then stage4bg.acc_speed(self,0.01,120) end
    if self.timer > 360 then

        self.alpha = 80 - 80 * cos(self.timer - 360)
        self.cover.alpha = 30 - 30 * cos((self.timer - 360) / 1.5)
        task.Do(self)
        if self.timer > 539 then
            self.cover.r = 70 - 70 * cos((self.timer - 540) / 2.3)
        end
        if self.timer > 619 then
            self.cover.b = 100 - 100 * cos((self.timer - 620) / 2.6)
        end
    end
end

function stage4bg:render()
    SetViewMode '3d'

    background.WarpEffectCapture()
    RenderClear(lstg.view3d.fog[3])
    for j = -2, 3 do
        local dz = 6 * j - math.mod(self.z, 6)
        stage4bg.renderground(dz, self)
        stage4bg.rendergroundlight(dz, self.alpha)
        stage4bg.cover(dz, self.cover.alpha, self.cover.r, 0, self.cover.b)
    end

    background.WarpEffectApply()
    SetViewMode 'world'
end

function stage4bg.renderground(z, self)
    local z1 = z + 1
    local z2 = z - 1
    local z3 = z - 3
    local z4 = z + 3
    if self.timer > 180 and self.timer < 361 then
        SetImageState('stage04b', '', Color(255 * (self.timer / 180 - 1), 255, 255, 255))
    end
    if self.timer > 360 then
        SetImageState('stage04b', '', Color(255, 255, 255, 255))
    end
    Render4V('stage04c', -2, 0, z1, 0, 0, z1, 0, 0, z2, -2, 0, z2)
    Render4V('stage04c', -2, 0, z4, 0, 0, z4, 0, 0, z1, -2, 0, z1)
    Render4V('stage04c', -2, 0, z2, 0, 0, z2, 0, 0, z3, -2, 0, z3)

    Render4V('stage04c', 0, 0, z1, 2, 0, z1, 2, 0, z2, 0, 0, z2)
    Render4V('stage04c', 0, 0, z4, 2, 0, z4, 2, 0, z1, 0, 0, z1)
    Render4V('stage04c', 0, 0, z2, 2, 0, z2, 2, 0, z3, 0, 0, z3)

    Render4V('stage04b', -2, 0, z1, 0, 0, z1, 0, 0, z2, -2, 0, z2)
    Render4V('stage04b', -2, 0, z4, 0, 0, z4, 0, 0, z1, -2, 0, z1)
    Render4V('stage04b', -2, 0, z2, 0, 0, z2, 0, 0, z3, -2, 0, z3)

    Render4V('stage04b', 0, 0, z1, 2, 0, z1, 2, 0, z2, 0, 0, z2)
    Render4V('stage04b', 0, 0, z4, 2, 0, z4, 2, 0, z1, 0, 0, z1)
    Render4V('stage04b', 0, 0, z2, 2, 0, z2, 2, 0, z3, 0, 0, z3)

    Render4V('stage04a', -8, 0, z1, -2, 0, z1, -2, 0, z2, -8, 0, z2)
    Render4V('stage04a', -8, 0, z4, -2, 0, z4, -2, 0, z1, -8, 0, z1)
    Render4V('stage04a', -8, 0, z2, -2, 0, z2, -2, 0, z3, -8, 0, z3)

    Render4V('stage04a', 2, 0, z1, 8, 0, z1, 8, 0, z2, 2, 0, z2)
    Render4V('stage04a', 2, 0, z4, 8, 0, z4, 8, 0, z1, 2, 0, z1)
    Render4V('stage04a', 2, 0, z2, 8, 0, z2, 8, 0, z3, 2, 0, z3)
end


----

function stage4bg.rendergroundlight(z, alpha)
    SetImageState('stage04b', 'mul+add', Color(alpha, 255, 255, 255))
    Render4V('stage04b', -2, 0, z + 1, 0, 0, z + 1, 0, 0, z - 1, -2, 0, z - 1)
    Render4V('stage04b', -2, 0, z + 3, 0, 0, z + 3, 0, 0, z + 1, -2, 0, z + 1)
    Render4V('stage04b', -2, 0, z - 1, 0, 0, z - 1, 0, 0, z - 3, -2, 0, z - 3)

    Render4V('stage04b', 0, 0, z + 1, 2, 0, z + 1, 2, 0, z - 1, 0, 0, z - 1)
    Render4V('stage04b', 0, 0, z + 3, 2, 0, z + 3, 2, 0, z + 1, 0, 0, z + 1)
    Render4V('stage04b', 0, 0, z - 1, 2, 0, z - 1, 2, 0, z - 3, 0, 0, z - 3)

end
----

function stage4bg.cover(z, alpha, r, g, b)
    SetImageState('stage04d', 'mul+add', Color(alpha, r, g, b))
    Render4V('stage04d', -8, 0, z + 3, 8, 0, z + 3, 8, 0, z - 3, -8, 0, z - 3)
end
-------------------------------------------------------------------------

function stage4bg:dec_speed(tospeed, _time)
    local step = (self.speed - tospeed) / _time
    task.Clear(self)
    task.New(self, function()
        for i = 1, _time do
            self.speed = self.speed - step
            task.Wait(1)
        end
    end)
end

function stage4bg:acc_speed(tospeed, _time)
    local step = (tospeed - self.speed) / _time
    task.Clear(self)
    task.New(self, function()
        for i = 1, _time do
            self.speed = self.speed + step
            task.Wait(1)
        end
    end)
end

function stage4bg:dec_speed(tospeed, _time)
    local step = (self.speed - tospeed) / _time
    task.Clear(self)
    task.New(self, function()
        for i = 1, _time do
            self.speed = self.speed - step
            task.Wait(1)
        end
    end)
end

function stage4bg:meetboss()
    task.Clear(self)
    task.New(self, function()
        local step = self.eye_a
        local t = 120
        for i = 1, 120 do
            self.eye_a = step * t / 120
            Set3D('eye', self.eye_a, self.eye_b, -7.1)
            t = t - 1
            task.Wait(1)
        end
    end)
end

function stage4bg:seearound()
    task.Clear(self)
    task.New(self, function()
        local t = 120
        local angle = 90
        for i = 1, _infinite do
            self.eye_a = 2.5 * cos(angle)
            self.eye_c = -6.1 - sin(angle)
            Set3D('eye', self.eye_a, 3.6 + 1 - sin(angle), self.eye_c)
            Set3D('at', -0.0, -0.1 + 2 - 2 * sin(angle), -0.6 - sin(angle) + 1)
            angle = angle + 0.2
            task.Wait(1)
        end
    end)
    task.New(self, function()
        for j = 1, 120 do
            Set3D('fog', 6.70, 11.8 + 8 * (j / 120), Color(100, 0, 0, 0))
            task.Wait(1)

        end
    end)
end
-----------------------------------------------------------------------------


