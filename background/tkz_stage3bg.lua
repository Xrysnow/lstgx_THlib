tkz_stage3_bg = Class(object)
function tkz_stage3_bg:init()
    --
    background.init(self, false)
    --resource
    LoadImageFromFile('tkz_stage3_a', 'THlib\\background\\tkz_stage3\\stage3_a.png')
    LoadImageFromFile('tkz_stage3_b', 'THlib\\background\\tkz_stage3\\stage3_b.png')
    LoadImageFromFile('tkz_stage3_c', 'THlib\\background\\tkz_stage3\\stage3_c.png')
    LoadImageFromFile('tkz_stage3_d', 'THlib\\background\\tkz_stage3\\stage3_d.png')

    --set 3d camera and fog
    Set3D('eye', 0, 6.8, -10.)
    Set3D('at', 0, -1.2, -4.9)
    Set3D('up', 0, 1, 0)
    Set3D('z', 2, 23.5)
    Set3D('fovy', 0.7)
    Set3D('fog', 6.0, 22.7, Color(200, 50, 0, 170))
    --
    self.speed = 0.02
    self._z = 0
end
function tkz_stage3_bg:frame()
    task.Do(self)
    self._z = self._z + self.speed
end

function tkz_stage3_bg:render()
    SetViewMode'3d'
    background.WarpEffectCapture()
    RenderClear(lstg.view3d.fog[3])

    for j = -2, 10 do
        local dz = 4 * j - math.mod(self._z, 4)

        Render4V('tkz_stage3_a', 0, 0, dz + 2, -4, 0, dz + 2, -4, 0, dz - 2, 0, 0, dz - 2)
        Render4V('tkz_stage3_a', 0, 0, dz + 2.5, 4, 0, dz + 2.5, 4, 0, dz - 1.5, 0, 0, dz - 1.5)
    end
    for j = -2, 10 do
        local dz = 4 * j - math.mod(self._z, 4)
        local Dx = 0.2
        Render4V('tkz_stage3_b', -2.5, 1, dz + 2, -0.5, 1, dz + 2, -0.5, 1, dz - 2, -2.5, 1, dz - 2)
        Render4V('tkz_stage3_b', 2.5 - Dx, 1, dz + 2, 0.5 - Dx, 1, dz + 2, 0.5 - Dx, 1, dz - 2, 2.5 - Dx, 1, dz - 2)
    end
    for j = -2, 10 do
        local dz = 4 * j - math.mod(self._z, 4)
        local Dx = -0.2
        Render4V('tkz_stage3_c', -2.5 - Dx, 1.5, dz + 1.5, -0.5 - Dx, 1.5, dz + 1.5, -0.5 - Dx, 1.5, dz - 2.5, -2.5 - Dx, 1.5, dz - 2.5)
        Render4V('tkz_stage3_c', 2.5 + Dx, 1.5, dz + 2, 0.5 + Dx, 1.5, dz + 1, 0.5 + Dx, 1.5, dz - 2, 2.5 + Dx, 1.5, dz - 2)
    end
    SetImageState('tkz_stage3_d', '', Color(205 + 50 * sin(self.timer), 255, 255, 255))
    for j = -2, 10 do
        local dz = 4 * j - math.mod(self._z, 4)

        Render4V('tkz_stage3_d', -2.5, 2, dz + 2, -0.5, 2, dz + 2, -0.5, 2, dz - 2, -2.5, 2, dz - 2)
        Render4V('tkz_stage3_d', 2.5, 2, dz + 2, 0.5, 2, dz + 1, 0.5, 2, dz - 2, 2.5, 2, dz - 2)

    end
    SetImageState('tkz_stage3_d', '', Color(255, 255, 255, 255))
    for j = -2, 10 do
        local dz = 4 * j - math.mod(self._z, 4)
        Render4V('tkz_stage3_d', -3, 2.6, dz + 2, -1, 2.6, dz + 2, -1, 2.6, dz - 2, -3, 2.6, dz - 2)
        Render4V('tkz_stage3_d', 3, 2.6, dz + 1.5, 1, 2.6, dz + 1.5, 1, 2.6, dz - 2.5, 3, 2.6, dz - 2.5)
    end

    background.WarpEffectApply()
    SetViewMode'world'
end

