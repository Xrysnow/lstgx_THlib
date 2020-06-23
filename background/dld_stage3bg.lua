stage3bg = Class(object)

function stage3bg:init()
    --
    background.init(self, false)
    --resource
    LoadImageFromFile('stage03a', 'THlib\\background\\stage3bg\\stage03a.png')
    LoadImageFromFile('stage03b', 'THlib\\background\\stage3bg\\stage03b.png')
    LoadImageFromFile('stage03c', 'THlib\\background\\stage3bg\\stage03c.png')
    LoadImageFromFile('stage03d', 'THlib\\background\\stage3bg\\stage03d.png')
    LoadImageFromFile('stage03e', 'THlib\\background\\stage3bg\\stage03e.png')
    LoadImageFromFile('stage3light', 'THlib\\background\\stage3bg\\stage3light.png')
    --set 3d camera and fog
    Set3D('eye', 0, 9.3, -6)
    Set3D('at', 0, 0, -1.1)
    Set3D('up', 0, 1, 0)
    Set3D('z', 1, 100)
    Set3D('fovy', 0.6)
    Set3D('fog', 7.4, 10.5, Color(200, 0, 0, 175))
    --
    self.speed = 0.01
    self.z = 0
end

function stage3bg:frame()
    self.z = self.z + self.speed
    if self.timer > 100 and self.timer < 280 then
        Set3D('eye', 0, 9.3 - 4.2 * sin(0.5 * (self.timer - 100)), -6)
        Set3D('at', 0, 0, -1.1 + 0.9 * sin(0.5 * (self.timer - 100)))
    end
    if self.timer > 300 then
        Set3D('eye', sin((self.timer - 300) / 5), 5.1 + sin((self.timer - 300) / 4), -6)
    end
end

function stage3bg:render()
    SetViewMode '3d'
    background.WarpEffectCapture()

    for j = -2, 3 do
        local dz = 6 * j - math.mod(self.z, 6)
        stage3bg.renderground(dz)
        stage3bg.renderwall_left(dz)
        stage3bg.renderwall_right(dz)
        stage3bg.light_left(self.timer, dz, 1)
        stage3bg.light_left(self.timer, dz, -1)
    end
    for j = -2, 3 do
        local dz = 6 * j - math.mod(self.z, 6)
        stage3bg.rendertop(dz)
    end

    background.WarpEffectApply()
    SetViewMode 'world'
end

function stage3bg.renderground(z)
    Render4V('stage03e', -1, 0, z + 1, 1, 0, z + 1, 1, 0, z - 1, -1, 0, z - 1)
    Render4V('stage03a', -1, 0, z + 3, 1, 0, z + 3, 1, 0, z + 1, -1, 0, z + 1)
    Render4V('stage03a', -1, 0, z - 1, 1, 0, z - 1, 1, 0, z - 3, -1, 0, z - 3)
end

function stage3bg.renderwall_left(z)
    Render4V('stage03d', -1, 1, z + 1, -1, 0, z + 1, -1, 0, z - 1, -1, 1, z - 1)
    Render4V('stage03c', -1, 1, z + 3, -1, 0, z + 3, -1, 0, z + 1, -1, 1, z + 1)
    Render4V('stage03c', -1, 1, z - 1, -1, 0, z - 1, -1, 0, z - 3, -1, 1, z - 3)
end

function stage3bg.renderwall_right(z)
    Render4V('stage03d', 1, 1, z + 1, 1, 0, z + 1, 1, 0, z - 1, 1, 1, z - 1)
    Render4V('stage03c', 1, 1, z + 3, 1, 0, z + 3, 1, 0, z + 1, 1, 1, z + 1)
    Render4V('stage03c', 1, 1, z - 1, 1, 0, z - 1, 1, 0, z - 3, 1, 1, z - 3)
end

function stage3bg.rendertop(z)
    Render4V('stage03b', 2.70, 1.8, z + 1, 0.70, 1.4, z + 1, 0.70, 1.4, z - 1, 2.70, 1.8, z - 1)
    Render4V('stage03b', 2.70, 1.8, z + 3, 0.70, 1.4, z + 3, 0.70, 1.4, z + 1, 2.70, 1.8, z + 1)
    Render4V('stage03b', 2.70, 1.8, z - 1, 0.70, 1.4, z - 1, 0.70, 1.4, z - 3, 2.70, 1.8, z - 3)
    Render4V('stage03b', -2.70, 1.8, z + 1, -0.70, 1.4, z + 1, -0.70, 1.4, z - 1, -2.70, 1.8, z - 1)
    Render4V('stage03b', -2.70, 1.8, z + 3, -0.70, 1.4, z + 3, -0.70, 1.4, z + 1, -2.70, 1.8, z + 1)
    Render4V('stage03b', -2.70, 1.8, z - 1, -0.70, 1.4, z - 1, -0.70, 1.4, z - 3, -2.70, 1.8, z - 3)
end

function stage3bg.light_left(timer, z, x)
    SetImageState('stage3light', 'mul+add', Color(255, 255, 140, 0))
    if timer % 1.5 == 0 then
        Render('stage3light', x, 0.9, 0, 0.3, 0.5, z)
    end
    SetImageState('stage3light', 'mul+add', Color(255, 255, 80, 0))
    if timer % 2 == 0 then
        Render('stage3light', x, 0.9, 0, 0.3, 0.5, z)
    end
    SetImageState('stage3light', 'mul+add', Color(255, 255, 100, 0))
    if timer % 1.7 == 0 then
        Render('stage3light', x, 0.9, 0, 0.3, 0.5, z)
    end
    SetImageState('stage3light', 'mul+add', Color(255, 255, 60, 0))
    if timer % 1.8 == 0 then
        Render('stage3light', x, 0.9, 0, 0.3, 0.5, z)
    end
end

