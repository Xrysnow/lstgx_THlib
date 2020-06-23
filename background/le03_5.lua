le03_5_background = Class(object)

function le03_5_background:init()
    background.init(self, false)
    LoadImageFromFile('img1', 'THlib\\background\\le03_5\\le03_05_1.png')
    --set camera
    Set3D('eye', 0.00, 0.0, 0)
    Set3D('at', 0.00, 0, 1)
    Set3D('up', 0.00, 0, 0)
    Set3D('fovy', 1.52)
    Set3D('z', 0.01, 10.0)
    Set3D('fog', 1.00, 10.0, Color(0, 0, 0, 0))
    --
    self.zos = 0
    self.speed = 0.025
    --
end

function le03_5_background:frame()
    self.zos = self.zos + self.speed
    Set3D('up', cos(self.timer / 3), sin(self.timer / 3), 0)
end

function le03_5_background:render()
    SetViewMode '3d'
    background.WarpEffectCapture()

    RenderClear(lstg.view3d.fog[3])
    local z = self.zos % 1
    local d = 0.5
    for i = 0, 7 do
        Render4V('img1', -d, -d * 2, 1 + z + i, d, -d * 2, 1 + z + i, d, -d * 2, -1 + z + i, -d, -d * 2, -1 + z + i)
        Render4V('img1', -d * 2, d, 1 + z + i, -d * 2, -d, 1 + z + i, -d * 2, -d, -1 + z + i, -d * 2, d, -1 + z + i)
        Render4V('img1', -d, d * 2, 1 + z + i, d, d * 2, 1 + z + i, d, d * 2, -1 + z + i, -d, d * 2, -1 + z + i)
        Render4V('img1', d * 2, d, 1 + z + i, d * 2, -d, 1 + z + i, d * 2, -d, -1 + z + i, d * 2, d, -1 + z + i)
    end

    background.WarpEffectApply()
    SetViewMode 'world'
end
