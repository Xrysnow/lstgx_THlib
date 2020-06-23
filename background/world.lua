world_background = Class(object)

function world_background:init()
    background.init(self, false)
    LoadTexture('blue_line', 'THlib\\background\\world\\blue_line.png')
    LoadTexture('blue', 'THlib\\background\\world\\blue.png')
    LoadImageFromFile('zhuzi', 'THlib\\background\\world\\zhuzi.png')
    LoadImage('blue_line', 'blue_line', 0, 0, 512, 512)
    LoadImage('blue', 'blue', 0, 0, 512, 512)
    SetImageState('blue', '', Color(50, 255, 255, 255))
    --set camera
    Set3D('eye', 0.00, 0.9, -5.20)
    Set3D('at', 0.00, 4.3, -3.60)
    -----(0.0,0.7,-3.6)---
    Set3D('up', 0.00, 2.90, 5.70)
    Set3D('fovy', 0.72)
    Set3D('z', 0.01, 100.0)
    Set3D('fog', 1.00, 60.0, Color(0, 0, 0, 0))
    --
    self.zos = 0
    self.speed = 0.015
    --
end

function world_background:frame()
    if self.timer <= 180 then
        Set3D('at', 0.00, 4.3 - 3.6 * sin(self.timer / 2), -3.60)
    end
    if self.timer > 600 and self.timer < 2600 then
        Set3D('at',
              0.0 + 0.5 * sin((self.timer - 600) * 0.18),
              0.7 + 0.6 * sin((self.timer - 600) * 0.18),
              -3.6 + 0.6 * sin((self.timer - 600) * 0.18))
    end
    self.zos = self.zos + self.speed
end

function world_background:render()
    SetViewMode '3d'
    background.WarpEffectCapture()
    RenderClear(lstg.view3d.fog[3])

    local z = 2 * self.zos % 1
    for i = -6, 40 do
        for j = -15, 15 do
            --Render4V('blue_line',-1,-1+j,1-z+i, 1,-1+j,1-z+i, 1,-1+j,-1-z+i,-1,-1+j,-1-z+i)--层数
            Render4V('blue', -1 + j, -1, 1 - z + i, 1 + j, -1, 1 - z + i, 1 + j, -1, -1 - z + i, -1 + j, -1, -1 - z + i)
            Render4V('blue_line', -1 + j, -1, 1 - z + i, 1 + j, -1, 1 - z + i, 1 + j, -1, -1 - z + i, -1 + j, -1, -1 - z + i)
        end
    end
    local zz = 5 * self.zos % 5
    for i = -10, 10 do
        for j = 0, 5 do
            Render4V('zhuzi', -16.5 + 3 * j, 1.5, 1 - zz + 5 * i, -16.5 + 3 * j, 1.5, 0.75 - zz + 5 * i, -16.5 + 3 * j, -1, 0.75 - zz + 5 * i, -16.5 + 3 * j, -1, 1 - zz + 5 * i)
            Render4V('zhuzi', 16.5 - 3 * j, 1.5, 1 - zz + 5 * i, 16.5 - 3 * j, 1.5, 0.75 - zz + 5 * i, 16.5 - 3 * j, -1, 0.75 - zz + 5 * i, 16.5 - 3 * j, -1, 1 - zz + 5 * i)
        end
    end

    background.WarpEffectApply()
    SetViewMode 'world'
end
