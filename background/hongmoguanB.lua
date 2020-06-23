hongmoguanB_background = Class(background)

function hongmoguanB_background:init()
    background.init(self, false)
    LoadTexture('hongmoguanB_floor', 'THlib\\background\\hongmoguanB\\floor.png')
    LoadImage('hongmoguanB_floor', 'hongmoguanB_floor', 0, 0, 482, 2780)
    LoadTexture('hongmoguanB_mask', 'THlib\\background\\hongmoguanB\\mask.png')
    LoadImage('hongmoguanB_mask', 'hongmoguanB_mask', 0, 0, 256, 256)
    LoadImageFromFile('hongmoguanB_white', 'THlib\\background\\hongmoguanB\\white.png')
    --
    Set3D('eye', 0.2, 1.1, -0.2)
    Set3D('at', 0, 0.1, 5.2)
    Set3D('up', 0, 1, 0)
    Set3D('fovy', 0.35)
    Set3D('z', 1, 100)
    Set3D('fog', 0.3, 24.2, Color(0x00000000))
    --
    self.zos = 0
    self.speed = 0.0015
end

function hongmoguanB_background:frame()
    self.zos = self.zos + self.speed
end

function hongmoguanB_background:render()
    Set3D('eye', 0.2, 1.1, -0.2)
    Set3D('at', 0, 0.1, 5.2)
    Set3D('up', 0, 1, 0)
    Set3D('fovy', 0.35)
    Set3D('z', 1, 100)
    Set3D('fog', 0.3, 24.2, Color(0x00000000))
    SetViewMode '3d'
    background.WarpEffectCapture()

    Render4V('hongmoguanB_white', -200, -200, 100, 200, -200, 100, 200, 200, 100, -200, 200, 100)
    local z = self.zos % 1
    for i = -4, 4 do
        Render4V('hongmoguanB_floor', -0.8, 0, 5.77 * (1.6 - z) + 5.78 * i, 0.8, 0, 5.77 * (1.6 - z) + 5.78 * i, 0.8, 0, 5.77 * (0 - z) + 5.78 * i, -0.8, 0, 5.77 * (0 - z) + 5.78 * i)
    end

    for i = -12, 24 do
        Render4V('hongmoguanB_mask', -1, 0.2, 1 - 6 * z + i, 1, 0.2, 1 - 6 * z + i, 1, 0.2, 0 - 6 * z + i, -1, 0.2, 0 - 6 * z + i)
        Render4V('hongmoguanB_mask', -0.8, 0.4, 1 - 6 * z + i, 0.8, 0.4, 1 - 6 * z + i, 0.8, 0.4, 0 - 6 * z + i, -0.8, 0.4, 0 - 6 * z + i)
    end

    background.WarpEffectApply()
    SetViewMode 'world'
end
